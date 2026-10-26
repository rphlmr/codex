import AppKit
import Observation
import OSLog
import SwiftUI
import UsageCore

@MainActor
final class StatusBarController: NSObject, NSApplicationDelegate {
    let store: UsageStore
    let demo: Bool

    private var statusItem: NSStatusItem?
    private var panel: UsagePanel?
    private var polling: Task<Void, Never>?

    override init() {
        demo = CommandLine.arguments.contains("--demo")

        if demo {
            store = UsageStore { try UsageSnapshot.sample() }
        } else {
            let client = CodexClient()
            store = UsageStore { try await client.fetch() }
        }

        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if demo {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate()
        } else {
            NSApp.setActivationPolicy(.accessory)
            configureStatusItem()
        }

        polling = Task { [store] in await store.poll() }

        if !demo && CommandLine.arguments.contains("--show-usage") {
            Task { @MainActor in showPopover() }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        demo
    }

    func applicationWillTerminate(_ notification: Notification) {
        panel?.orderOut(nil)
        polling?.cancel()
        store.send(.stop)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !demo {
            showPopover()
        }

        return demo
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        if let button = item.button {
            button.image = loadIcon()
            button.imagePosition = .imageLeading
            button.font = .monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            button.target = self
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityLabel("Codex Usage")
        }

        panel = UsagePanel(store: store)

        observeUsage()
    }

    private func loadIcon() -> NSImage {
        let icon: NSImage

        if let url = Bundle.main.url(forResource: "CodexMark", withExtension: "png"),
           let bundledIcon = NSImage(contentsOf: url) {
            icon = bundledIcon
        } else {
            Logger(subsystem: "dev.rphlmr.codex-usage", category: "startup")
                .error("CodexMark.png is missing or invalid; using the terminal symbol.")
            icon = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Codex Usage")
                ?? NSImage(size: NSSize(width: 18, height: 18))
        }

        icon.size = NSSize(width: 18, height: 18)
        icon.isTemplate = true
        return icon
    }

    private func observeUsage() {
        withObservationTracking {
            let usage = store.state.snapshot?.remainingUsage
            let percentage = usage.map {
                "\($0.percent.formatted(.number.precision(.fractionLength(0...1))))%"
            } ?? "—"
            let title = store.state.failure == nil ? percentage : "⚠︎ \(percentage)"
            statusItem?.button?.title = " \(title)"

            if let usage {
                let description = "\(usage.bucketTitle): \(percentage) remaining · \(usage.windowTitle)"
                statusItem?.button?.toolTip = store.state.failure == nil
                    ? description : "\(description) · Last known usage; refresh failed"
            } else {
                statusItem?.button?.toolTip = store.state.failure?.message ?? "Reading Codex usage"
            }

            statusItem?.button?.setAccessibilityValue("\(percentage) remaining")
        } onChange: { [weak self] in
            Task { @MainActor in self?.observeUsage() }
        }
    }

    @objc private func togglePopover() {
        guard let panel, let button = statusItem?.button else {
            return
        }

        panel.toggle(relativeTo: button)
    }

    private func showPopover() {
        guard let panel, let button = statusItem?.button else {
            return
        }

        panel.show(relativeTo: button)
    }
}
