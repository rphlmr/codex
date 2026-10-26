import Foundation
import Observation
import UsageCore

@Observable @MainActor
final class UsageStore {
    private(set) var state: UsageState = .idle
    private let load: @Sendable () async throws -> UsageSnapshot
    private var request: Task<Void, Never>?

    init(load: @escaping @Sendable () async throws -> UsageSnapshot) {
        self.load = load
    }

    func send(_ event: UsageEvent) {
        let (next, effects) = UsageMachine.transition(state, event)
        state = next

        for effect in effects {
            switch effect {
            case .load:
                request = Task { [weak self, load] in
                    do {
                        let snapshot = try await load()
                        try Task.checkCancellation()
                        self?.send(.loaded(snapshot))
                    } catch is CancellationError {
                        self?.send(.cancelled)
                    } catch {
                        self?.send(.failed(error as? UsageFailure ?? .unavailable))
                    }
                }
            case .cancel:
                request?.cancel()
                request = nil
            }
        }
    }

    func poll() async {
        while !Task.isCancelled {
            send(.refresh)

            do {
                try await Task.sleep(for: .seconds(300))
            } catch {
                send(.stop)
                return
            }
        }
    }
}
