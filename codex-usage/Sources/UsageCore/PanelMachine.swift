import Foundation

public enum PanelState: Equatable, Sendable {
    case hidden
    case visible(UUID)
}

public enum PanelEvent: Sendable {
    case show(UUID)
    case toggle(UUID)
    case outsideClick(UUID)
    case dismiss
}

public enum PanelEffect: Equatable, Sendable {
    case show
    case hide
}

public enum PanelMachine {
    public static func transition(_ state: PanelState, _ event: PanelEvent) -> (PanelState, [PanelEffect]) {
        switch (state, event) {
        case (.hidden, .show(let id)), (.hidden, .toggle(let id)):
            return (.visible(id), [.show])
        case (.visible, .toggle), (.visible, .dismiss):
            return (.hidden, [.hide])
        case (.visible(let current), .outsideClick(let id)) where current == id:
            return (.hidden, [.hide])
        default:
            return (state, [])
        }
    }
}
