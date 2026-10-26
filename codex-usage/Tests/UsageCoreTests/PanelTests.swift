import Foundation
import Testing
@testable import UsageCore

@Test func toggleOpensTheHiddenPanelAndClosesTheVisiblePanel() {
    let id = UUID()
    let (opened, effects) = PanelMachine.transition(.hidden, .toggle(id))
    let (closed, closeEffects) = PanelMachine.transition(opened, .toggle(UUID()))

    #expect(opened == .visible(id))
    #expect(effects == [.show])
    #expect(closed == .hidden)
    #expect(closeEffects == [.hide])
}

@Test func delayedOutsideClickCannotCloseANewPresentation() {
    let oldID = UUID()
    let newID = UUID()
    let (closed, _) = PanelMachine.transition(.visible(oldID), .dismiss)
    let (reopened, _) = PanelMachine.transition(closed, .show(newID))
    let (afterStaleClick, staleEffects) = PanelMachine.transition(reopened, .outsideClick(oldID))
    let (afterCurrentClick, currentEffects) = PanelMachine.transition(reopened, .outsideClick(newID))

    #expect(afterStaleClick == reopened)
    #expect(staleEffects.isEmpty)
    #expect(afterCurrentClick == .hidden)
    #expect(currentEffects == [.hide])
}

@Test func reopeningAnAlreadyVisiblePanelDoesNotReplaceItsPresentation() {
    let state = PanelState.visible(UUID())
    let (next, effects) = PanelMachine.transition(state, .show(UUID()))

    #expect(next == state)
    #expect(effects.isEmpty)
    #expect(PanelMachine.transition(.hidden, .dismiss).1.isEmpty)
}
