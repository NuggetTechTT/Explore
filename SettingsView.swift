import SwiftUI
import UIKit
import Darwin

// MARK: - Values (taken from the reference photo)

enum SettingsDefaults {
    static let experiences = [
        "Product Zone - iPhone"
    ]
    static let experience = "Product Zone - iPhone"
    static let appLaunch  = "com.apple.ist.DemoDiscoveryApp"
    static let xid        = "10011"
    static let appVersion = "2.0.737"
    static let store      = "Vil's Apple Store"
}

enum SettingsKeys {
    static let experience         = "settings.experience"
    static let appLaunch          = "settings.appLaunch"
    static let exploreMode        = "settings.exploreMode"

    static let all = [experience, appLaunch, exploreMode]
}

enum SettingsRoute: Hashable {
    case experience, exploreMode, appLaunch
}

// MARK: - Explore Mode

enum ExploreMode: String, CaseIterable, Identifiable {
    case standalone = "Standalone"
    case demoUnit   = "DemoUnit"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .standalone: return "Without DemoLoop app"
        case .demoUnit:   return "With DemoLoop app"
        }
    }

    /// The mode that is saved right now (Standalone until you choose otherwise).
    static var current: ExploreMode {
        let saved = UserDefaults.standard.string(forKey: SettingsKeys.exploreMode) ?? ""
        return ExploreMode(rawValue: saved) ?? .standalone
    }
}

// MARK: - Real device info (shown in the DEVICE section)

enum DeviceInfo {
    static var osVersion: String { UIDevice.current.systemVersion }

    static var osBuild: String {
        #if targetEnvironment(simulator)
        if let build = ProcessInfo.processInfo.environment["SIMULATOR_RUNTIME_BUILD_VERSION"] {
            return build
        }
        #endif
        var size = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        guard size > 0 else { return "—" }
        var buffer = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &buffer, &size, nil, 0)
        return String(cString: buffer)
    }

    static var osDescription: String { "Version \(osVersion) (Build \(osBuild))" }
}

// MARK: - Look

enum SettingsTheme {
    static let background = Color(red: 0.90, green: 0.90, blue: 0.90)   // soft lavender like the photo
    static let row        = Color.white.opacity(0.60)
}

extension View {
    func settingsStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(SettingsTheme.background.ignoresSafeArea())
    }
}

// MARK: - Settings screen

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(SettingsKeys.experience) private var experience = SettingsDefaults.experience
    @AppStorage(SettingsKeys.appLaunch)  private var appLaunch  = SettingsDefaults.appLaunch
    @AppStorage(SettingsKeys.exploreMode) private var exploreMode = ExploreMode.standalone.rawValue

    @State private var path: [SettingsRoute] = []
    @State private var confirmQuit = false
    @State private var confirmReset = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.experience) {
                        ValueRow(title: "Experience", value: experience)
                    }

                    NavigationLink(value: SettingsRoute.exploreMode) {
                        ValueRow(title: "Explore Mode", value: exploreMode)
                    }

                    // Plain row (not a button): nothing happens when it is tapped.
                    VStack(alignment: .leading, spacing: 3) {
                        Text("App Launch")
                            .foregroundStyle(.primary)
                        Text(appLaunch)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ValueRow(title: "XID", value: SettingsDefaults.xid)
                    ValueRow(title: "App Version", value: SettingsDefaults.appVersion)
                    ValueRow(title: "Store", value: SettingsDefaults.store)
                }
                .listRowBackground(SettingsTheme.row)

                Section("Device") {
                    ValueRow(title: "iOS", value: DeviceInfo.osDescription)
                }
                .listRowBackground(SettingsTheme.row)

                Section {
                    Button("Quit Application", role: .destructive) {
                        confirmQuit = true
                    }
                    Button("Reset App Setup", role: .destructive) {
                        confirmReset = true
                    }
                }
                .listRowBackground(SettingsTheme.row)
            }
            .settingsStyle()
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .experience:  ExperiencePicker(selection: $experience)
                case .exploreMode: ExploreModePicker(selection: $exploreMode)
                case .appLaunch:   AppLaunchEditor(bundleID: $appLaunch)
                }
            }
            .confirmationDialog("Quit Application?", isPresented: $confirmQuit, titleVisibility: .visible) {
                Button("Quit", role: .destructive) { exit(0) }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Reset App Setup?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { resetSetup() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All settings on this screen return to their defaults.")
            }
        }
        .preferredColorScheme(.light)
    }

    private func resetSetup() {
        for key in SettingsKeys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }
        Haptics.success()
        dismiss()
    }
}

// MARK: - Reusable row

private struct ValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Detail screens

private struct ExperiencePicker: View {
    @Binding var selection: String

    var body: some View {
        List {
            Section {
                ForEach(SettingsDefaults.experiences, id: \.self) { option in
                    Button {
                        Haptics.select()
                        selection = option
                    } label: {
                        HStack {
                            Text(option).foregroundStyle(.primary)
                            Spacer()
                            if option == selection {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("Experience")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExploreModePicker: View {
    @Binding var selection: String

    var body: some View {
        List {
            Section {
                ForEach(ExploreMode.allCases) { mode in
                    Button {
                        Haptics.select()
                        selection = mode.rawValue
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mode.rawValue)
                                    .foregroundStyle(.primary)
                                Text(mode.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if mode.rawValue == selection {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            } footer: {
                Text("DemoUnit turns off Explore's own screen saver, because the DemoLoop app handles it.")
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("Explore Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AppLaunchEditor: View {
    @Binding var bundleID: String

    var body: some View {
        List {
            Section {
                TextField("Bundle identifier", text: $bundleID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
            } header: {
                Text("App Launch")
            } footer: {
                Text("Bundle identifier of the app that launches for this experience.")
            }
            .listRowBackground(SettingsTheme.row)

            Section {
                Button("Restore Default") {
                    bundleID = SettingsDefaults.appLaunch
                }
                .disabled(bundleID == SettingsDefaults.appLaunch)
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("App Launch")
        .navigationBarTitleDisplayMode(.inline)
    }
}
