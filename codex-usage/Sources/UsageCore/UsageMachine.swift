public enum UsageState: Equatable, Sendable {
    case idle
    case loading(previous: UsageSnapshot?)
    case ready(UsageSnapshot)
    case failed(UsageFailure, previous: UsageSnapshot?)
    case stopped

    public var snapshot: UsageSnapshot? {
        switch self {
        case .ready(let snapshot): snapshot
        case .loading(let previous), .failed(_, let previous): previous
        case .idle, .stopped: nil
        }
    }

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    public var failure: UsageFailure? {
        if case .failed(let failure, _) = self {
            return failure
        }

        return nil
    }
}

public enum UsageEvent: Sendable {
    case refresh
    case loaded(UsageSnapshot)
    case failed(UsageFailure)
    case cancelled
    case stop
}

public enum UsageEffect: Equatable, Sendable {
    case load
    case cancel
}

public enum UsageMachine {
    public static func transition(_ state: UsageState, _ event: UsageEvent) -> (UsageState, [UsageEffect]) {
        switch (state, event) {
        case (.stopped, _):
            return (state, [])
        case (_, .stop):
            return (.stopped, [.cancel])
        case (.idle, .refresh), (.ready, .refresh), (.failed, .refresh):
            return (.loading(previous: state.snapshot), [.load])
        case (.loading, .loaded(let snapshot)):
            return (.ready(snapshot), [])
        case (.loading(let previous), .failed(let failure)):
            return (.failed(failure, previous: previous), [])
        case (.loading(let previous), .cancelled):
            return (previous.map(UsageState.ready) ?? .idle, [])
        default:
            return (state, [])
        }
    }
}
