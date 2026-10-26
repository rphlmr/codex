import SwiftUI

@main
struct CodexUsageApp: App {
    @NSApplicationDelegateAdaptor(StatusBarController.self) private var controller

    init() {
        LoginItemCommand.runIfRequested()
    }

    var body: some Scene {
        Window("Codex Usage Preview", id: "preview") {
            UsageView(store: controller.store, demo: controller.demo)
                .preferredColorScheme(previewColorScheme)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultLaunchBehavior(controller.demo ? .presented : .suppressed)
        .restorationBehavior(.disabled)
        .commandsRemoved()
    }

    private var previewColorScheme: ColorScheme? {
        guard controller.demo else {
            return nil
        }

        if CommandLine.arguments.contains("--dark") {
            return .dark
        }

        if CommandLine.arguments.contains("--light") {
            return .light
        }

        return nil
    }
}
