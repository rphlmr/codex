import Darwin
import Foundation

public struct CodexClient: Sendable {
    private let executable: URL?
    private let timeout: TimeInterval

    public init(executable: URL? = nil, timeout: TimeInterval = 20) {
        self.executable = executable
        self.timeout = timeout
    }

    public func fetch() async throws -> UsageSnapshot {
        let executable = try executable ?? Self.findExecutable()
        let session = AppServerSession(executable: executable, timeout: timeout)

        return try await withTaskCancellationHandler {
            try Task.checkCancellation()

            return try await Task.detached {
                do {
                    return try session.readUsage()
                } catch {
                    try session.checkStopped()
                    throw error as? UsageFailure ?? .unavailable
                }
            }.value
        } onCancel: {
            session.cancel()
        }
    }

    public static func findExecutable(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        home: URL = FileManager.default.homeDirectoryForCurrentUser
    ) throws -> URL {
        var paths: [String] = []

        if let override = environment["CODEX_USAGE_CLI"], !override.isEmpty {
            paths = [override]
        } else {
            paths = (environment["PATH"] ?? "").split(separator: ":")
                .filter { $0.hasPrefix("/") }
                .map { "\($0)/codex" }
            paths += [
                home.appending(path: ".local/bin/codex").path,
                "/opt/homebrew/bin/codex",
                "/usr/local/bin/codex",
                home.appending(path: ".npm-global/bin/codex").path,
                "/Applications/Codex.app/Contents/Resources/codex",
            ]
        }

        for path in paths where path.hasPrefix("/") {
            var directory: ObjCBool = false

            if FileManager.default.fileExists(atPath: path, isDirectory: &directory),
               !directory.boolValue,
               FileManager.default.isExecutableFile(atPath: path) {
                return URL(filePath: path)
            }
        }

        throw UsageFailure.cliMissing
    }
}

// The lock protects process launch/cancellation across the worker and timeout queues.
// The protocol and its file handles are otherwise owned by the single worker.
private final class AppServerSession: @unchecked Sendable {
    private enum StopReason {
        case cancelled
        case timeout
    }

    private let lock = NSLock()
    private let process = Process()
    private let input = Pipe()
    private let output = Pipe()
    private let timeout: TimeInterval
    private var stopReason: StopReason?

    init(executable: URL, timeout: TimeInterval) {
        self.timeout = timeout
        process.executableURL = executable
        process.arguments = ["app-server", "--listen", "stdio://", "-c", "analytics.enabled=false"]
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        // Avoid loading configuration from the repository containing this app.
        process.currentDirectoryURL = URL(filePath: "/", directoryHint: .isDirectory)

        var environment = ProcessInfo.processInfo.environment
        let executableDirectory = executable.deletingLastPathComponent().path
        environment["PATH"] = [executableDirectory, "/opt/homebrew/bin", "/usr/local/bin",
                               environment["PATH"] ?? "/usr/bin:/bin"].joined(separator: ":")
        process.environment = environment
    }

    func cancel() {
        stop(.cancelled)
    }

    private func stop(_ reason: StopReason) {
        lock.withLock {
            guard stopReason == nil else {
                return
            }

            stopReason = reason
            terminate()
        }
    }

    private func terminate() {
        guard process.isRunning else {
            return
        }

        process.terminate()

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [self] in
            lock.withLock {
                if process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
            }
        }
    }

    func checkStopped() throws {
        try lock.withLock {
            switch stopReason {
            case .cancelled: throw CancellationError()
            case .timeout: throw UsageFailure.timeout
            case nil: break
            }
        }
    }

    func readUsage() throws -> UsageSnapshot {
        try checkStopped()

        // A dead child must yield a write error, never SIGPIPE in the viewer.
        guard fcntl(input.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1) != -1 else {
            throw UsageFailure.unavailable
        }

        try lock.withLock {
            guard stopReason == nil else {
                throw CancellationError()
            }

            do {
                try process.run()
            } catch {
                throw UsageFailure.unavailable
            }
        }

        let deadline = DispatchWorkItem { [self] in stop(.timeout) }
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: deadline)

        defer {
            deadline.cancel()
            try? input.fileHandleForWriting.close()

            lock.withLock {
                terminate()
            }

            process.waitUntilExit()
            try? output.fileHandleForReading.close()
        }

        try write([
            "id": 1,
            "method": "initialize",
            "params": ["clientInfo": ["name": "codex_usage_viewer", "title": "Codex Usage", "version": "1.0.0"]],
        ])

        var buffer = Data()
        var expectedID = 1
        var bytesRead = 0

        while let chunk = try readChunk() {
            try checkStopped()
            bytesRead += chunk.count

            guard bytesRead <= 1_048_576 else {
                throw UsageFailure.invalidResponse
            }

            buffer.append(chunk)

            while let newline = buffer.firstIndex(of: 0x0A) {
                let line = Data(buffer[..<newline])
                buffer.removeSubrange(...newline)

                guard !line.isEmpty else {
                    continue
                }

                guard let message = (try? JSONSerialization.jsonObject(with: line)) as? [String: Any] else {
                    throw UsageFailure.invalidResponse
                }

                // Notifications can arrive between responses. Never interpret them as usage.
                guard message["id"] as? Int == expectedID, message["method"] == nil else {
                    continue
                }

                if let error = message["error"] as? [String: Any] {
                    let text = (error["message"] as? String ?? "").lowercased()
                    let authError = ["not logged", "not signed", "unauthorized", "unauthenticated", "authentication", "chatgpt authentication"]
                        .contains { text.contains($0) }
                    throw authError ? UsageFailure.signInRequired : UsageFailure.unavailable
                }

                guard let result = message["result"] as? [String: Any] else {
                    throw UsageFailure.invalidResponse
                }

                if expectedID == 1 {
                    try write(["method": "initialized"])
                    try write(["id": 2, "method": "account/rateLimits/read"])
                    expectedID = 2
                } else {
                    let data = try JSONSerialization.data(withJSONObject: result)

                    do {
                        let snapshot = try UsageSnapshot.decode(data)
                        try checkStopped()
                        return snapshot
                    } catch let failure as UsageFailure {
                        throw failure
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        throw UsageFailure.invalidResponse
                    }
                }
            }
        }

        try checkStopped()
        throw UsageFailure.unavailable
    }

    private func write(_ message: [String: Any]) throws {
        var data = try JSONSerialization.data(withJSONObject: message)
        data.append(0x0A)
        try input.fileHandleForWriting.write(contentsOf: data)
    }

    private func readChunk() throws -> Data? {
        var bytes = [UInt8](repeating: 0, count: 65_536)

        while true {
            // A pipe read must return as soon as a response is available. Waiting for
            // a full Foundation read buffer deadlocks the initialize/initialized handshake.
            let count = bytes.withUnsafeMutableBufferPointer { buffer in
                Darwin.read(output.fileHandleForReading.fileDescriptor, buffer.baseAddress, buffer.count)
            }

            if count > 0 {
                return Data(bytes.prefix(count))
            }

            if count == 0 {
                return nil
            }

            if errno != EINTR {
                throw UsageFailure.unavailable
            }
        }
    }
}
