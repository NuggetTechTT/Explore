import Foundation

/// Stopgap definition so IdleScreensaver.swift compiles.
/// Only add this file if searching the project for "enum ExploreMode" finds nothing.
enum ExploreMode: String, CaseIterable, Identifiable {
    case standard
    case demoUnit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .demoUnit: return "Demo Unit"
        }
    }

    static let storageKey = "settings.exploreMode"

    /// The mode saved on this device (defaults to .standard).
    static var current: ExploreMode {
        get {
            ExploreMode(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .standard
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }
}
