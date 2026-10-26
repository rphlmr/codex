import Foundation

public struct UsageWindow: Decodable, Equatable, Sendable {
    public let usedPercent: Double
    public let windowDurationMins: Int?
    public let resetsAt: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case usedPercent, windowDurationMins, resetsAt
    }

    public init(usedPercent: Double, windowDurationMins: Int?, resetsAt: TimeInterval?) {
        self.usedPercent = usedPercent
        self.windowDurationMins = windowDurationMins
        self.resetsAt = resetsAt
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let percent = try values.decode(Double.self, forKey: .usedPercent)
        let reset = try values.decodeIfPresent(TimeInterval.self, forKey: .resetsAt)

        guard percent.isFinite, percent >= 0,
              reset.map({ $0.isFinite && abs($0) < 253_402_300_800 }) ?? true else {
            throw UsageFailure.invalidResponse
        }

        self.init(
            usedPercent: percent,
            windowDurationMins: try values.decodeIfPresent(Int.self, forKey: .windowDurationMins),
            resetsAt: reset
        )
    }

    public var fraction: Double { min(100, max(0, usedPercent)) / 100 }

    public func title(primary: Bool) -> String {
        switch windowDurationMins {
        case 300: "Current session"
        case 10_080: "This week"
        case let minutes? where minutes > 0 && minutes.isMultiple(of: 1_440):
            "\(minutes / 1_440)-day window"
        case let minutes? where minutes > 0 && minutes.isMultiple(of: 60):
            "\(minutes / 60)-hour window"
        case let minutes? where minutes > 0: "\(minutes)-minute window"
        default: primary ? "Primary limit" : "Secondary limit"
        }
    }

    public func resetDescription(now: Date) -> String {
        guard let resetsAt else {
            return "Reset time unavailable"
        }

        let seconds = resetsAt - now.timeIntervalSince1970

        guard seconds > 0 else {
            return "Reset pending · refresh to update"
        }

        let minutes = Int(ceil(seconds / 60))
        let days = minutes / 1_440
        let hours = (minutes % 1_440) / 60
        let remainder = minutes % 60

        if days > 0 {
            return "Resets in \(days)d \(hours)h"
        }

        if hours > 0 {
            return "Resets in \(hours)h \(remainder)m"
        }

        return "Resets in \(minutes)m"
    }
}

public struct UsageBucket: Decodable, Equatable, Sendable {
    public let limitId: String?
    public let limitName: String?
    public let primary: UsageWindow?
    public let secondary: UsageWindow?
}

public struct UsageSnapshot: Equatable, Sendable {
    public struct Bucket: Identifiable, Equatable, Sendable {
        public let id: String
        public let limits: UsageBucket

        public var title: String {
            if id == "codex" {
                return "Codex"
            }

            return limits.limitName ?? limits.limitId ?? id
        }
    }

    public let buckets: [Bucket]
    public let fetchedAt: Date

    public struct RemainingUsage: Equatable, Sendable {
        public let percent: Double
        public let windowTitle: String
        public let bucketTitle: String
    }

    public var remainingUsage: RemainingUsage? {
        guard let bucket = buckets.first else {
            return nil
        }

        let windows = [(bucket.limits.primary, true), (bucket.limits.secondary, false)]
            .compactMap { window, primary -> RemainingUsage? in
                guard let window else {
                    return nil
                }

                return RemainingUsage(
                    percent: min(100, max(0, 100 - window.usedPercent)),
                    windowTitle: window.title(primary: primary),
                    bucketTitle: bucket.title
                )
            }

        return windows.min { $0.percent < $1.percent }
    }

    public static func decode(_ data: Data, now: Date = .now) throws -> Self {
        struct Response: Decodable {
            let rateLimits: UsageBucket?
            let rateLimitsByLimitId: [String: UsageBucket]?
        }

        let response = try JSONDecoder().decode(Response.self, from: data)
        let buckets: [Bucket]

        if let map = response.rateLimitsByLimitId, !map.isEmpty {
            buckets = map.keys.sorted {
                if $0 == "codex" {
                    return $1 != "codex"
                }

                if $1 == "codex" {
                    return false
                }

                return $0 < $1
            }.compactMap { id in
                map[id].map { Bucket(id: id, limits: $0) }
            }
        } else if let legacy = response.rateLimits {
            buckets = [Bucket(id: legacy.limitId ?? "codex", limits: legacy)]
        } else {
            throw UsageFailure.invalidResponse
        }

        return Self(buckets: buckets, fetchedAt: now)
    }

    public static func sample(now: Date = .now) throws -> Self {
        let payload = """
        {"rateLimits":{"limitId":"codex","primary":{"usedPercent":32,
        "windowDurationMins":300,"resetsAt":\(now.timeIntervalSince1970 + 8_040)},
        "secondary":{"usedPercent":54,"windowDurationMins":10080,
        "resetsAt":\(now.timeIntervalSince1970 + 367_200)}}}
        """

        return try decode(Data(payload.utf8), now: now)
    }
}

public enum UsageFailure: Error, Equatable, Sendable {
    case cliMissing
    case signInRequired
    case timeout
    case invalidResponse
    case unavailable

    public var message: String {
        switch self {
        case .cliMissing: "Install the Codex CLI to view usage."
        case .signInRequired: "Sign in with ChatGPT using codex login in Terminal."
        case .timeout: "Codex took too long to respond. Try refreshing."
        case .invalidResponse: "Couldn't understand the Codex response. Update the CLI and try again."
        case .unavailable: "Couldn't read usage. Check your connection and Codex sign-in, then refresh."
        }
    }
}
