import SwiftUI
import UIKit
import UIKit.UIGestureRecognizerSubclass
import CoreMotion
import Combine
import AVFoundation

// MARK: - Settings you can change

enum IdleConfig {
    /// Seconds with no touch and no movement before "Are You Still Here?" appears.
    static let secondsBeforePrompt: TimeInterval = 30

    /// Length of the "Are You Still Here?" countdown.
    static let promptSeconds: TimeInterval = 5

    /// How much the device has to move to count as "moved".
    /// Lower numbers = more sensitive. (acceleration in g, rotation in radians/second)
    static let motionAcceleration = 0.08
    static let motionRotation     = 0.40
}

// MARK: - State

enum IdlePhase {
    case active       // normal use
    case prompt       // "Are You Still Here?" + 5 second timer
    case screensaver  // screen saver
}

/// Watches for touches (anywhere in the app) and for the device being moved.
/// active -> (idle) -> prompt -> (5 s) -> screensaver
/// touch or movement: prompt -> active (stay where you are), screensaver -> active + back to Home Menu.
final class IdleMonitor: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    @Published private(set) var phase: IdlePhase = .active
    @Published private(set) var promptStart = Date()
    /// Changes every time the app should jump back to the Home Menu.
    @Published private(set) var homeResetToken = 0

    /// Set to true while another screen (like Settings) is open, so idle never triggers there.
    var isPaused = false {
        didSet { lastActivity = Date() }
    }

    private var lastActivity = Date()
    private var started = false
    private let motion = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()
    private weak var installedWindow: UIWindow?

    func start() {
        guard !started else { return }
        started = true

        installTouchObserver()

        if motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = 1.0 / 30.0
            motion.startDeviceMotionUpdates()
        }

        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.noteActivity() }
            .store(in: &cancellables)
    }

    deinit {
        motion.stopDeviceMotionUpdates()
    }

    /// Called for every touch and every movement.
    func noteActivity() {
        lastActivity = Date()

        switch phase {
        case .active:
            break
        case .prompt:
            setPhase(.active)
        case .screensaver:
            homeResetToken += 1      // rebuilds the Home Menu behind the screen saver
            setPhase(.active)
        }
    }

    // MARK: Timer

    private func tick() {
        if isPaused {
            lastActivity = Date()
            return
        }

        // DemoUnit (with DemoLoop app): the internal prompt and screen saver stay off.
        if ExploreMode.current == .demoUnit {
            lastActivity = Date()
            if phase != .active { setPhase(.active) }
            return
        }

        // Device moved?
        if let d = motion.deviceMotion {
            let a = d.userAcceleration
            let r = d.rotationRate
            let accel = (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot()
            let spin  = (r.x * r.x + r.y * r.y + r.z * r.z).squareRoot()
            if accel > IdleConfig.motionAcceleration || spin > IdleConfig.motionRotation {
                noteActivity()
                return
            }
        }

        let now = Date()
        switch phase {
        case .active:
            if now.timeIntervalSince(lastActivity) >= IdleConfig.secondsBeforePrompt {
                promptStart = now
                setPhase(.prompt)
            }
        case .prompt:
            if now.timeIntervalSince(promptStart) >= IdleConfig.promptSeconds {
                setPhase(.screensaver)
            }
        case .screensaver:
            break
        }
    }

    private func setPhase(_ new: IdlePhase) {
        guard new != phase else { return }

        let animation: Animation
        switch new {
        case .prompt:      animation = .easeInOut(duration: 0.55)
        case .screensaver: animation = .easeInOut(duration: 1.0)
        case .active:      animation = .easeInOut(duration: 0.65)
        }
        withAnimation(animation) { phase = new }
    }

    // MARK: Touch observer (same idea as SettingsTrigger: attached to the app's window)

    private func installTouchObserver(attempt: Int = 0) {
        guard installedWindow == nil else { return }

        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let window else {
            if attempt < 20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.installTouchObserver(attempt: attempt + 1)
                }
            }
            return
        }

        let recognizer = ActivityRecognizer(target: nil, action: nil)
        recognizer.onActivity = { [weak self] in self?.noteActivity() }
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = self

        window.addGestureRecognizer(recognizer)
        installedWindow = window
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

/// Only reports "something touched the screen". It never blocks or changes normal taps and scrolling.
private final class ActivityRecognizer: UIGestureRecognizer {
    var onActivity: (() -> Void)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) { onActivity?() }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) { onActivity?() }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        onActivity?()
        state = .failed
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}

// MARK: - Overlay (goes on top of the Home Menu)

struct IdleOverlay: View {
    @ObservedObject var idle: IdleMonitor

    var body: some View {
        ZStack {
            if idle.phase == .screensaver {
                ScreenSaverView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            if idle.phase == .prompt {
                AreYouStillHereView(start: idle.promptStart)
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
        }
        // While the prompt or screen saver is showing, it catches the touch so nothing underneath gets tapped.
        .allowsHitTesting(idle.phase != .active)
    }
}

// MARK: - "Are You Still Here?"

struct AreYouStillHereView: View {
    let start: Date

    private let ringSize: CGFloat = 124

    var body: some View {
        ZStack {
            Color.black.opacity(0.74).ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Are You Still Here?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Redrawn every frame, so the ring and the number move smoothly.
                TimelineView(.animation) { context in
                    let elapsed = context.date.timeIntervalSince(start)
                    let progress = min(1, max(0, elapsed / IdleConfig.promptSeconds))
                    let remaining = max(0, IdleConfig.promptSeconds - elapsed)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.16), lineWidth: 6)

                        Circle()
                            .trim(from: 0, to: 1 - progress)
                            .stroke(Theme.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(remaining.rounded(.up)))")
                            .font(.system(size: 46, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                    .frame(width: ringSize, height: ringSize)
                }

                Text("Touch the screen to continue")
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Screen saver

/// Plays your own video, looping and muted, full screen:
///     Explore.app/demoloop/Demo.mov
/// If that file is not found, it shows the floating iPhone screen saver instead.
struct ScreenSaverView: View {
    private let videoURL = ScreenSaverView.findVideo()

    /// Looks for demoloop/Demo.mov inside the app. If the demoloop folder was added to Xcode as a plain
    /// group (files flattened into the app root), Demo.mov is found there instead.
    static func findVideo() -> URL? {
        let inFolder = Bundle.main.bundleURL
            .appendingPathComponent("demoloop", isDirectory: true)
            .appendingPathComponent("Demo.mov")
        if FileManager.default.fileExists(atPath: inFolder.path) { return inFolder }
        return Bundle.main.url(forResource: "Demo", withExtension: "mov")
    }

    var body: some View {
        if let videoURL {
            ZStack {
                Color.black
                LoopingVideoView(url: videoURL)
            }
            .ignoresSafeArea()
        } else {
            FloatingPhoneSaver()
        }
    }
}

/// Fills the screen with a looping, muted video (aspect fill).
struct LoopingVideoView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.configure(url: url)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: ()) {
        uiView.stop()
    }
}

final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    func configure(url: URL) {
        backgroundColor = .black

        let queue = AVQueuePlayer()
        queue.isMuted = true
        looper = AVPlayerLooper(player: queue, templateItem: AVPlayerItem(url: url))

        playerLayer.videoGravity = .resizeAspectFill   // .resizeAspect = whole video visible, with black bars
        playerLayer.player = queue
        player = queue
        queue.play()
    }

    func stop() {
        player?.pause()
        looper?.disableLooping()
        playerLayer.player = nil
        player = nil
        looper = nil
    }
}

// MARK: - Backup screen saver (used only when Demo.mov is missing)

/// A slow, calm screen saver: the iPhone floats gently over a softly pulsing glow.
struct FloatingPhoneSaver: View {
    private let model = PhoneModel.iPhone15Pro
    private let photo: UIImage? = UIImage(named: "iPhone15ProHero")

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                TimelineView(.animation) { context in
                    scene(time: context.date.timeIntervalSinceReferenceDate, size: geo.size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }

    // Split into small pieces with explicit types so the compiler can type-check quickly.

    private func scene(time t: Double, size: CGSize) -> some View {
        let glow: Double = 0.20 + 0.14 * ((sin(t * 0.55) + 1.0) / 2.0)
        let hint: Double = 0.40 + 0.40 * ((sin(t * 1.6) + 1.0) / 2.0)
        let breathe: CGFloat = CGFloat(1.0 + 0.025 * sin(t * 0.45))
        let dx: CGFloat = CGFloat(20.0 * sin(t * 0.21))
        let dy: CGFloat = CGFloat(26.0 * cos(t * 0.17))

        return ZStack {
            glowView(opacity: glow, size: size)

            phone(in: size)
                .scaleEffect(breathe)
                .offset(x: dx, y: dy)

            hintView(opacity: hint)
        }
    }

    private func glowView(opacity: Double, size: CGSize) -> some View {
        let colors: [Color] = [Theme.accent.opacity(opacity), Color.clear]
        return RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 10,
            endRadius: size.width * 0.95
        )
    }

    private func hintView(opacity: Double) -> some View {
        VStack {
            Spacer()
            Text("Touch to explore")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white)
                .opacity(opacity)
                .padding(.bottom, 64)
        }
    }

    @ViewBuilder
    private func phone(in size: CGSize) -> some View {
        if let photo = photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.62)
                .mask(fadeMask)
        } else {
            PhoneBack(base: model.colors[0].color)
                .frame(
                    width: size.width * 0.5,
                    height: size.width * 0.5 * PhoneBack.aspect
                )
        }
    }

    private var fadeMask: some View {
        let stops: [Gradient.Stop] = [
            Gradient.Stop(color: .black, location: 0.0),
            Gradient.Stop(color: .black, location: 0.70),
            Gradient.Stop(color: .clear, location: 1.0)
        ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }
}
