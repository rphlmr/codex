import Darwin
import Foundation
import ServiceManagement

@MainActor
enum LoginItemCommand {
    static func runIfRequested() {
        let arguments = CommandLine.arguments
        let enable = arguments.contains("--enable-login-item")
        let disable = arguments.contains("--disable-login-item")

        guard enable || disable || arguments.contains("--login-status") else {
            return
        }

        guard !(enable && disable) else {
            fail("Choose either --enable-login-item or --disable-login-item.")
        }

        let service = SMAppService.mainApp

        do {
            if enable && service.status != .enabled && service.status != .requiresApproval {
                try service.register()
            } else if disable && service.status != .notRegistered {
                try service.unregister()
            }
        } catch {
            fail("Couldn't update launch at login: \(error.localizedDescription)")
        }

        switch service.status {
        case .enabled:
            print("Launch at login: enabled")
            exit(0)
        case .notRegistered:
            print("Launch at login: disabled")
            exit(enable ? 1 : 0)
        case .requiresApproval:
            print("Launch at login: needs your approval in macOS Login Items.")
            exit(2)
        case .notFound:
            fail("macOS couldn't find the installed app for launch at login.")
        @unknown default:
            fail("macOS returned an unknown launch-at-login status.")
        }
    }

    private static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("\(message)\n".utf8))
        exit(1)
    }
}
