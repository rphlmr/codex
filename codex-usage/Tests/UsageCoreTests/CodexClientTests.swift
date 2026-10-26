import Darwin
import Foundation
import Testing
@testable import UsageCore

private struct FakeCLI {
    let directory: URL
    let executable: URL

    init(body: String) throws {
        directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        executable = directory.appending(path: "codex")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let script = "#!/usr/bin/python3\nimport json, sys, time, os, signal\n" + body
        try Data(script.utf8).write(to: executable)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: executable.path)
    }

    func remove() throws {
        try FileManager.default.removeItem(at: directory)
    }
}

private let handshake = """
assert sys.argv[1:4] == ['app-server', '--listen', 'stdio://']
request = json.loads(sys.stdin.readline())
assert request['method'] == 'initialize'
print(json.dumps({'id': request['id'], 'result': {'userAgent': 'fixture'}}), flush=True)
assert json.loads(sys.stdin.readline())['method'] == 'initialized'
request = json.loads(sys.stdin.readline())
assert request == {'id': 2, 'method': 'account/rateLimits/read'}

"""

@Test func clientCompletesHandshakeAndIgnoresNotifications() async throws {
    let cli = try FakeCLI(body: handshake + """
    print(json.dumps({'method': 'account/rateLimits/updated', 'params': {}}), flush=True)
    payload = json.dumps({'id': 2, 'result': {'rateLimits': {'primary': {
        'usedPercent': 32, 'windowDurationMins': 300, 'resetsAt': 1900000000}}}})
    sys.stdout.write(payload[:12]); sys.stdout.flush()
    time.sleep(0.01)
    print(payload[12:], flush=True)
    sys.stdin.read()
    """)
    defer {
        try? cli.remove()
    }

    let snapshot = try await CodexClient(executable: cli.executable).fetch()

    #expect(snapshot.buckets.first?.limits.primary?.usedPercent == 32)
    #expect(snapshot.buckets.first?.limits.primary?.windowDurationMins == 300)
}

@Test func clientReportsMissingSignIn() async throws {
    let cli = try FakeCLI(body: handshake + """
    print(json.dumps({'id': 2, 'error': {'code': -32000,
        'message': 'ChatGPT authentication required'}}), flush=True)
    sys.stdin.read()
    """)
    defer {
        try? cli.remove()
    }

    await #expect(throws: UsageFailure.signInRequired) {
        try await CodexClient(executable: cli.executable).fetch()
    }
}

@Test func clientTimesOutAndReapsUnresponsiveChild() async throws {
    let cli = try FakeCLI(body: """
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    with open(os.path.join(os.path.dirname(__file__), 'pid'), 'w') as f:
        f.write(str(os.getpid()))
    time.sleep(30)
    """)
    defer {
        try? cli.remove()
    }

    await #expect(throws: UsageFailure.timeout) {
        try await CodexClient(executable: cli.executable, timeout: 2).fetch()
    }

    let pid = try String(contentsOf: cli.directory.appending(path: "pid"), encoding: .utf8)
    let processID = try #require(Int32(pid))
    #expect(kill(processID, 0) == -1)
}

@Test func cancellationTerminatesTheRequest() async throws {
    let cli = try FakeCLI(body: "time.sleep(30)\n")
    defer {
        try? cli.remove()
    }
    let request = Task {
        try await CodexClient(executable: cli.executable).fetch()
    }

    try await Task.sleep(for: .milliseconds(100))
    request.cancel()

    await #expect(throws: CancellationError.self) {
        try await request.value
    }
}

@Test func malformedProtocolOutputIsRejected() async throws {
    let cli = try FakeCLI(body: "print('not-json', flush=True)\nsys.stdin.read()\n")
    defer {
        try? cli.remove()
    }

    await #expect(throws: UsageFailure.invalidResponse) {
        try await CodexClient(executable: cli.executable).fetch()
    }
}

@Test func excessiveProtocolOutputIsBounded() async throws {
    let cli = try FakeCLI(body: "sys.stdout.write('x' * 1100000)\nsys.stdout.flush()\nsys.stdin.read()\n")
    defer {
        try? cli.remove()
    }

    await #expect(throws: UsageFailure.invalidResponse) {
        try await CodexClient(executable: cli.executable).fetch()
    }
}
