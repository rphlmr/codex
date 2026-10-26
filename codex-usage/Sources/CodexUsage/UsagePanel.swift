import AppKit
import SwiftUI
import UsageCore

@MainActor
final class UsagePanel: NSPanel, NSWindowDelegate {
    private let host: NSHostingController<UsageView>
    private var sizeObservation: NSKeyValueObservation?
    private var outsideClickMonitor: Any?
    private weak var anchor: NSView?
    private var presentation: PanelState = .hidden

    init(store: UsageStore) {
        host = NSHostingController(rootView: UsageView(store: store, demo: false))
        host.sizingOptions = [.preferredContentSize]

        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        isOpaque = false
        title = "Codex Usage"
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        delegate = self
        isReleasedWhenClosed = false
        level = .statusBar
        collectionBehavior = [.transient, .fullScreenAuxiliary]

        contentView = host.view
        host.view.wantsLayer = true
        host.view.layer?.backgroundColor = NSColor.clear.cgColor
        host.view.layer?.cornerRadius = 12
        host.view.layer?.cornerCurve = .continuous
        host.view.layer?.masksToBounds = true

        sizeObservation = host.observe(\.preferredContentSize, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor in self?.updateSizeAndPosition() }
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    func show(relativeTo anchor: NSView) {
        self.anchor = anchor
        send(.show(UUID()))
    }

    func toggle(relativeTo anchor: NSView) {
        self.anchor = anchor
        send(.toggle(UUID()))
    }

    private func send(_ event: PanelEvent) {
        let (next, effects) = PanelMachine.transition(presentation, event)
        presentation = next

        for effect in effects {
            switch effect {
            case .show:
                updateSizeAndPosition()
                makeKeyAndOrderFront(nil)
                invalidateShadow()

                if case .visible(let id) = next, presentation == next, isVisible {
                    outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                        Task { @MainActor in self?.dismissIfOutside(presentationID: id) }
                    }
                }
            case .hide:
                if let outsideClickMonitor {
                    NSEvent.removeMonitor(outsideClickMonitor)
                    self.outsideClickMonitor = nil
                }

                super.orderOut(nil)
            }
        }
    }

    override func orderOut(_ sender: Any?) {
        send(.dismiss)
    }

    override func cancelOperation(_ sender: Any?) {
        send(.dismiss)
    }

    func windowDidResignKey(_ notification: Notification) {
        guard !isKeyWindow, !isOverAnchor(NSEvent.mouseLocation),
              NSApp.currentEvent?.window !== anchor?.window else {
            return
        }

        send(.dismiss)
    }

    private func dismissIfOutside(presentationID: UUID) {
        let point = NSEvent.mouseLocation

        if frame.contains(point) || isOverAnchor(point) {
            return
        }

        send(.outsideClick(presentationID))
    }

    private func isOverAnchor(_ point: NSPoint) -> Bool {
        guard let anchor, let window = anchor.window else {
            return false
        }

        return window.convertToScreen(anchor.convert(anchor.bounds, to: nil)).contains(point)
    }

    private func updateSizeAndPosition() {
        let size = host.sizeThatFits(in: NSSize(width: 280, height: 800))

        if size.width > 0 && size.height > 0 && contentView?.frame.size != size {
            setContentSize(size)
            invalidateShadow()
        }

        guard let anchor, let window = anchor.window, let screen = window.screen else {
            return
        }

        let buttonFrame = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
        let visibleFrame = screen.visibleFrame
        let x = min(max(buttonFrame.midX - frame.width / 2, visibleFrame.minX), visibleFrame.maxX - frame.width)
        let y = max(visibleFrame.minY, buttonFrame.minY - frame.height - 6)
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
