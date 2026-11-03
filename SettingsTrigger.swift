import SwiftUI
import UIKit

/// Opens the hidden Settings screen when you hold three fingers on the screen for five seconds.
/// The gesture is attached to the app's window, so it works on every screen and does not
/// interfere with normal taps and scrolling.
final class SettingsTrigger: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    @Published var isPresented = false

    private weak var installedWindow: UIWindow?

    func install(attempt: Int = 0) {
        guard installedWindow == nil else { return }

        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let window else {
            // The window may not be ready yet on first launch, so try again shortly.
            if attempt < 20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.install(attempt: attempt + 1)
                }
            }
            return
        }

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handle(_:)))
        #if targetEnvironment(simulator)
        // The Simulator can only fake two fingers (hold the Option key while clicking).
        recognizer.numberOfTouchesRequired = 2
        #else
        recognizer.numberOfTouchesRequired = 3
        #endif
        recognizer.minimumPressDuration = 5
        recognizer.allowableMovement = 100
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = self

        window.addGestureRecognizer(recognizer)
        installedWindow = window
    }

    @objc private func handle(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began, !isPresented else { return }
        Haptics.success()
        isPresented = true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

/// App root: the home screen, the hidden Settings sheet, and the idle prompt / screen saver.
struct RootView: View {
    @StateObject private var trigger = SettingsTrigger()
    @StateObject private var idle = IdleMonitor()
    @State private var showLaunch = true

    var body: some View {
        ZStack {
            // A new id rebuilds the Home Menu, which is how the app returns "home" after the screen saver.
            HomeView()
                .id(idle.homeResetToken)
                .transition(.identity)

            IdleOverlay(idle: idle)

            // Loading animation (Explore_Load.mov) when the app opens.
            if showLaunch {
                LaunchAnimationView {
                    withAnimation(.easeInOut(duration: 0.6)) { showLaunch = false }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        // Hides the status bar (time, battery, signal) while the screen saver is showing.
        .statusBarHidden(idle.phase == .screensaver || showLaunch)
        .sheet(isPresented: $trigger.isPresented) {
            SettingsView()
        }
        .onAppear {
            trigger.install()
            idle.start()
            ExploreNotification.requestPermission()
        }
        // Notification: sent every 5 minutes while the app is not on screen, removed when the app comes back.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            ExploreNotification.schedule()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            ExploreNotification.cancel()
        }
        // Idle never starts while Settings is open.
        .onReceive(trigger.$isPresented) { idle.isPaused = $0 }
    }
}
