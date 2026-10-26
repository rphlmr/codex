import AVFoundation
import Observation

@Observable
@MainActor
final class PlayerModel {
    var isPlaying = false
    var isBuffering = false
    var hasError = false
    var errorMessage: String?

    private let player = AVPlayer()
    private var observation: NSKeyValueObservation?

    func load(_ url: URL) {
        hasError = false
        isBuffering = true
        player.replaceCurrentItem(with: AVPlayerItem(url: url))

        observation = player.observe(\.timeControlStatus) { [weak self] player, _ in
            let status = player.timeControlStatus

            Task { @MainActor in
                self?.isBuffering = status == .waitingToPlayAtSpecifiedRate
                self?.isPlaying = status == .playing
            }
        }
    }

    func play() {
        isPlaying = true
        player.play()
    }

    func pause() {
        isPlaying = false
        player.pause()
    }

    func fail(_ message: String) {
        hasError = true
        errorMessage = message
    }
}
