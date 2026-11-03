import SwiftUI
import AVFoundation
import Combine

/// Loading animation: plays Explore_Load.mov once when the app opens, then fades into the Home Menu.
/// If the video file is missing, it is skipped and the app opens normally.
struct LaunchAnimationView: View {
    /// true  = the video fills the screen (logo bigger, the empty black sides are cropped).
    /// false = the whole square video is shown (logo smaller).
    static let fillScreen = true

    let onFinished: () -> Void

    private let url = Bundle.main.url(forResource: "Explore_Load", withExtension: "mov")

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let url = url {
                PlayOnceVideoView(url: url, fill: Self.fillScreen, onFinished: onFinished)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            if url == nil { onFinished() }
        }
    }
}

/// Plays a muted video one time and calls onFinished when it ends.
struct PlayOnceVideoView: UIViewRepresentable {
    let url: URL
    let fill: Bool
    let onFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    func makeUIView(context: Context) -> LaunchPlayerView {
        let view = LaunchPlayerView()
        view.backgroundColor = .black

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true

        view.playerLayer.player = player
        view.playerLayer.videoGravity = fill ? .resizeAspectFill : .resizeAspect

        context.coordinator.start(player: player, item: item)
        return view
    }

    func updateUIView(_ uiView: LaunchPlayerView, context: Context) {}

    static func dismantleUIView(_ uiView: LaunchPlayerView, coordinator: Coordinator) {
        coordinator.stop()
    }

    final class Coordinator {
        private let onFinished: () -> Void
        private var player: AVPlayer?
        private var cancellable: AnyCancellable?
        private var finished = false

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        func start(player: AVPlayer, item: AVPlayerItem) {
            self.player = player

            cancellable = NotificationCenter.default
                .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in self?.finish() }

            // Safety: if the video can't play for any reason, the app still opens.
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
                self?.finish()
            }

            player.play()
        }

        private func finish() {
            guard !finished else { return }
            finished = true
            onFinished()
        }

        func stop() {
            player?.pause()
            cancellable = nil
            player = nil
        }
    }
}

final class LaunchPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
