import SwiftUI
import UIKit

// MARK: - Colors

enum Theme {
    static let background    = Color.black
    static let card          = Color(red: 0.10, green: 0.10, blue: 0.12)
    static let tile          = Color(red: 0.13, green: 0.14, blue: 0.17)
    static let stroke        = Color.white.opacity(0.14)
    static let accent        = Color(red: 0.00, green: 0.48, blue: 1.00)   // Blue
    static let accentSoft    = Color(red: 0.42, green: 0.64, blue: 0.96)
    static let secondaryText = Color(white: 0.62)
}

// MARK: - Haptics

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Money

enum Money {
    /// 1199 -> "$1,199"
    static func dollars(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        return "$" + (formatter.string(from: NSNumber(value: value)) ?? "\(value)")
    }

    /// Monthly payment, truncated to cents the way Apple shows it (1199 / 24 -> "$49.95").
    static func monthly(_ value: Int, months: Int = 24) -> String {
        let cents = max(0, value) * 100 / months
        let remainder = cents % 100
        return "$\(cents / 100)." + (remainder < 10 ? "0\(remainder)" : "\(remainder)")
    }
}

// MARK: - Reusable styles

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CardStyle: ViewModifier {
    var radius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(radius: CGFloat = 18) -> some View {
        modifier(CardStyle(radius: radius))
    }

    /// Fade + slide-up entrance used on the home screen.
    func reveal(_ visible: Bool, delay: Double, offset: CGFloat = 24) -> some View {
        self
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : offset)
            .animation(.spring(response: 0.7, dampingFraction: 0.85).delay(delay), value: visible)
    }
}

// MARK: - Animation (iOS 16-compatible stand-in for the iOS 17 `.snappy`)

extension Animation {
    static var snap: Animation {
        .spring(response: 0.35, dampingFraction: 0.85)
    }
}

// MARK: - Color helper

extension Color {
    /// True for light colors (used to pick a readable icon color on top of a swatch).
    var isLight: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (0.299 * r + 0.587 * g + 0.114 * b) > 0.62
    }
}

// MARK: - Extra haptic

extension Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
