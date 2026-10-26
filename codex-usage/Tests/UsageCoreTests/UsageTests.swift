import Foundation
import Testing
@testable import UsageCore

@Test func prefersMeteredBucketsAndKeepsUnavailableWindowsAbsent() throws {
    let data = Data("""
    {"rateLimits":{"primary":{"usedPercent":99}},"rateLimitsByLimitId":{
      "other":{"limitName":"Another model","secondary":{"usedPercent":40}},
      "codex":{"primary":{"usedPercent":0,"windowDurationMins":300,"resetsAt":null}}
    }}
    """.utf8)
    let snapshot = try UsageSnapshot.decode(data)

    #expect(snapshot.buckets.map(\.id) == ["codex", "other"])
    #expect(snapshot.buckets.first?.limits.primary?.usedPercent == 0)
    #expect(snapshot.buckets.first?.limits.secondary == nil)
    #expect(snapshot.buckets.last?.title == "Another model")
    #expect(snapshot.buckets.last?.limits.primary == nil)
}

@Test func supportsLegacyPayloadAndDoesNotInventMissingData() throws {
    let snapshot = try UsageSnapshot.decode(Data("""
    {"rateLimits":{"primary":null,"secondary":null}}
    """.utf8))

    #expect(snapshot.buckets.count == 1)
    #expect(snapshot.buckets[0].limits.primary == nil)
    #expect(throws: (any Error).self) {
        try UsageSnapshot.decode(Data("{}".utf8))
    }
    #expect(throws: (any Error).self) {
        try UsageSnapshot.decode(Data("{\"rateLimits\":{\"primary\":{}}}".utf8))
    }
}

@Test func labelsReportedWindowsAndDoesNotAssumeAWeeklyLimit() {
    let short = UsageWindow(usedPercent: 25, windowDurationMins: 15, resetsAt: nil)
    let session = UsageWindow(usedPercent: 32, windowDurationMins: 300, resetsAt: nil)
    let weekly = UsageWindow(usedPercent: 54, windowDurationMins: 10_080, resetsAt: nil)

    #expect(short.title(primary: true) == "15-minute window")
    #expect(session.title(primary: true) == "Current session")
    #expect(weekly.title(primary: false) == "This week")
    #expect(short.resetDescription(now: .now) == "Reset time unavailable")
}

@Test func resetCountdownDoesNotClaimStaleDataHasReset() {
    let now = Date(timeIntervalSince1970: 1_000)
    let expired = UsageWindow(usedPercent: 100, windowDurationMins: 300, resetsAt: 999)
    let soon = UsageWindow(usedPercent: 32, windowDurationMins: 300, resetsAt: 1_001)
    let later = UsageWindow(usedPercent: 54, windowDurationMins: 10_080, resetsAt: 368_200)

    #expect(expired.resetDescription(now: now) == "Reset pending · refresh to update")
    #expect(expired.fraction == 1)
    #expect(soon.resetDescription(now: now) == "Resets in 1m")
    #expect(later.resetDescription(now: now) == "Resets in 4d 6h")
}

@Test func refreshMachineRejectsOverlapAndPreservesStaleData() throws {
    let snapshot = try UsageSnapshot.sample()
    let (loading, effects) = UsageMachine.transition(.ready(snapshot), .refresh)
    let (duplicate, duplicateEffects) = UsageMachine.transition(loading, .refresh)
    let (failed, _) = UsageMachine.transition(loading, .failed(.timeout))
    let (retry, retryEffects) = UsageMachine.transition(failed, .refresh)
    let (recovered, _) = UsageMachine.transition(retry, .loaded(snapshot))

    #expect(effects == [.load])
    #expect(duplicate == loading)
    #expect(duplicateEffects.isEmpty)
    #expect(failed.snapshot == snapshot)
    #expect(failed.failure == .timeout)
    #expect(retryEffects == [.load])
    #expect(recovered == .ready(snapshot))
}

@Test func shutdownIgnoresLateResponses() throws {
    let snapshot = try UsageSnapshot.sample()
    let (stopped, effects) = UsageMachine.transition(.loading(previous: nil), .stop)
    let (late, lateEffects) = UsageMachine.transition(stopped, .loaded(snapshot))

    #expect(effects == [.cancel])
    #expect(late == .stopped)
    #expect(lateEffects.isEmpty)
    #expect(UsageMachine.transition(.loading(previous: snapshot), .cancelled).0 == .ready(snapshot))
}

@Test func executableOverrideDoesNotSilentlyUseAnotherCLI() {
    #expect(throws: UsageFailure.cliMissing) {
        try CodexClient.findExecutable(environment: ["CODEX_USAGE_CLI": "/does-not-exist/codex"])
    }
}

@Test func menuBarShowsTheMostConstrainedRemainingCodexWindow() throws {
    let snapshot = try UsageSnapshot.sample()

    #expect(snapshot.remainingUsage?.percent == 46)
    #expect(snapshot.remainingUsage?.windowTitle == "This week")
    #expect(snapshot.remainingUsage?.bucketTitle == "Codex")
}

@Test func menuBarUsesAvailableWindowsAndKeepsMissingDataUnknown() throws {
    let singleWindow = try UsageSnapshot.decode(Data("""
    {"rateLimits":{"primary":null,"secondary":{"usedPercent":1,"windowDurationMins":10080}}}
    """.utf8))
    let noWindows = try UsageSnapshot.decode(Data("{\"rateLimits\":{}}".utf8))
    let exceeded = try UsageSnapshot.decode(Data("""
    {"rateLimits":{"primary":{"usedPercent":110}}}
    """.utf8))

    #expect(singleWindow.remainingUsage?.percent == 99)
    #expect(noWindows.remainingUsage == nil)
    #expect(exceeded.remainingUsage?.percent == 0)
}

@Test func modelSpecificQuotasDoNotReplaceTheCodexStatusPercentage() throws {
    let snapshot = try UsageSnapshot.decode(Data("""
    {"rateLimitsByLimitId":{
      "another-model":{"primary":{"usedPercent":100}},
      "codex":{"primary":{"usedPercent":25}}
    }}
    """.utf8))

    #expect(snapshot.remainingUsage?.percent == 75)
}

@Test func rejectsInvalidPercentagesAndUnboundedResetTimestamps() {
    for invalid in [
        "{\"rateLimits\":{\"primary\":{\"usedPercent\":-1}}}",
        "{\"rateLimits\":{\"primary\":{\"usedPercent\":32,\"resetsAt\":1e100}}}",
    ] {
        #expect(throws: UsageFailure.invalidResponse) {
            try UsageSnapshot.decode(Data(invalid.utf8))
        }
    }
}
