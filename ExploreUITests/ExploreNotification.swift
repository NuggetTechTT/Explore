import UIKit
import UserNotifications

/// The notification from the Explore app:
/// "Open this app to learn about products on display and see pricing"
///
/// When the app leaves the screen (Home button, lock, another app) it starts sending this notification
/// every 5 minutes. When the app comes back, it stops and the notification is removed.
enum ExploreNotification {
    static let identifier = "explore.openThisApp"
    static let title      = "Explore"
    static let message    = "Open this app to learn about products on display and see pricing"

    /// How often the notification is sent while the app is not on screen (in seconds).
    /// 300 = 5 minutes. iOS needs at least 60 seconds for a repeating notification.
    static let repeatEvery: TimeInterval = 300

    /// Asks for permission (iOS shows its "Allow Notifications?" question only the first time).
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { _, _ in }
    }

    static func schedule() {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeatEvery, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
