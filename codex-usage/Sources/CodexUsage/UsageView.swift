import AppKit
import SwiftUI
import UsageCore

struct UsageView: View {
    let store: UsageStore
    let demo: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Codex Usage")
                .font(.headline)

            TimelineView(.periodic(from: .now, by: 60)) { context in
                if let snapshot = store.state.snapshot {
                    if snapshot.buckets.count > 2 {
                        ScrollView {
                            usage(snapshot, now: max(context.date, snapshot.fetchedAt))
                        }
                        .frame(height: 360)
                    } else {
                        usage(snapshot, now: max(context.date, snapshot.fetchedAt))
                    }
                } else if let failure = store.state.failure {
                    Text(failure.message)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                } else {
                    Text("Reading Codex usage…")
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
            }

            Divider()

            TimelineView(.periodic(from: .now, by: 30)) { context in
                Button {
                    store.send(.refresh)
                } label: {
                    HStack {
                        Text(store.state.isLoading ? "Refreshing…" : "Refresh")

                        Spacer()

                        Text(refreshDescription(now: context.date))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: .capsule)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                }
                .buttonStyle(MenuActionStyle())
                .disabled(store.state.isLoading)
                .keyboardShortcut("r")
                .accessibilityLabel("Refresh usage")
                .accessibilityValue(refreshDescription(now: context.date))
                .help(refreshHelp)
            }

            if demo {
                Text("Preview · sample data")
                    .font(.caption)
                    .foregroundStyle(.primary)
            } else if let failure = store.state.failure, store.state.snapshot != nil {
                Text(failure.message)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            Divider()

            Button {
                store.send(.stop)
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Text("Quit Codex Usage")
                    Spacer()
                }
            }
            .buttonStyle(MenuActionStyle())
            .keyboardShortcut("q")
        }
        .padding(12)
        .frame(width: 280)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
        .containerBackground(.clear, for: .window)
    }

    private func refreshDescription(now: Date) -> String {
        guard let snapshot = store.state.snapshot else {
            return "Not refreshed"
        }

        if now.timeIntervalSince(snapshot.fetchedAt) < 60 {
            return "Updated just now"
        }

        let age = snapshot.fetchedAt.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
        return "Updated \(age)"
    }

    private var refreshHelp: String {
        guard let snapshot = store.state.snapshot else {
            return "Refresh Codex usage"
        }

        return "Last updated \(snapshot.fetchedAt.formatted(date: .abbreviated, time: .standard)). Refreshes every 5 minutes."
    }

    private func usage(_ snapshot: UsageSnapshot, now: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(snapshot.buckets) { bucket in
                VStack(alignment: .leading, spacing: 12) {
                    if snapshot.buckets.count > 1 || bucket.id != "codex" {
                        Text(bucket.title)
                            .font(.subheadline.weight(.semibold))
                    }

                    if let primary = bucket.limits.primary {
                        UsageRow(window: primary, primary: true, now: now)
                    }

                    if let secondary = bucket.limits.secondary {
                        UsageRow(window: secondary, primary: false, now: now)
                    }

                    if bucket.limits.primary == nil && bucket.limits.secondary == nil {
                        Text("Usage limits aren't available for this account.")
                            .font(.callout)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

private struct UsageRow: View {
    let window: UsageWindow
    let primary: Bool
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(window.title(primary: primary))
                Spacer()
                Text("\(window.usedPercent.formatted(.number.precision(.fractionLength(0...1))))% used")
                    .monospacedDigit()
            }
            .font(.subheadline)

            ProgressView(value: window.fraction)
                .scaleEffect(x: 1, y: 1.35)
                .padding(.vertical, 2)
                .tint(.accentColor)
                .accessibilityLabel(window.title(primary: primary))
                .accessibilityValue("\(window.usedPercent.formatted()) percent used")

            Text(window.resetDescription(now: now))
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

private struct MenuActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ActionLabel(configuration: configuration)
    }

    private struct ActionLabel: View {
        let configuration: ButtonStyleConfiguration
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.isFocused) private var isFocused
        @State private var isHovered = false

        private var isHighlighted: Bool {
            isEnabled && (isHovered || isFocused || configuration.isPressed)
        }

        var body: some View {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .foregroundStyle(.primary)
                .background(
                    isHighlighted
                        ? Color.accentColor.opacity(configuration.isPressed ? 0.3 : 0.18)
                        : .clear,
                    in: .rect(cornerRadius: 6)
                )
                .contentShape(.rect)
                .opacity(isEnabled ? 1 : 0.45)
                .onHover { isHovered = $0 }
                .padding(.horizontal, -6)
        }
    }
}
