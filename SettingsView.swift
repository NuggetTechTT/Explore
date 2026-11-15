import SwiftUI
import UIKit
import Darwin

// MARK: - Values (taken from the reference photo)

enum SettingsDefaults {
    static let experiences = [
        "Product Zone - iPhone",
        "Product Zone - iPad",
        "Product Zone - Mac",
        "Product Zone - Apple Watch"
    ]
    static let experience = "Product Zone - iPhone"
    static let appLaunch  = "com.apple.ist.DemoDiscoveryApp"
    static let xid        = "10011"
    static let appVersion = "2.0.737"
    static let store      = "R245"
}

enum SettingsKeys {
    static let enrollment         = "settings.enrollment"
    static let experience         = "settings.experience"
    static let appLaunch          = "settings.appLaunch"
    static let autoReset          = "settings.policy.autoReset"
    static let idleTimeout        = "settings.policy.idleTimeout"
    static let singleApp          = "settings.security.singleApp"
    static let blockNotifications = "settings.security.blockNotifications"

    static let all = [enrollment, experience, appLaunch, autoReset, idleTimeout, singleApp, blockNotifications]
}

enum SettingsRoute: Hashable {
    case enrollment, experience, appLaunch, policies, security
}

// MARK: - Enrollment status

enum EnrollmentStatus: String, CaseIterable, Identifiable {
    case enrolled
    case notEnrolled

    var id: String { rawValue }

    var title: String {
        self == .enrolled ? "Enrolled" : "Not enrolled"
    }

    var color: Color {
        self == .enrolled
            ? Color(red: 0.20, green: 0.78, blue: 0.35)   // green
            : Color(red: 1.00, green: 0.62, blue: 0.04)   // orange
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
    static let background = Color(red: 0.87, green: 0.84, blue: 0.96)   // soft lavender like the photo
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

    @AppStorage(SettingsKeys.enrollment) private var enrollment: EnrollmentStatus = .enrolled
    @AppStorage(SettingsKeys.experience) private var experience = SettingsDefaults.experience
    @AppStorage(SettingsKeys.appLaunch)  private var appLaunch  = SettingsDefaults.appLaunch

    @State private var path: [SettingsRoute] = []
    @State private var confirmQuit = false
    @State private var confirmReset = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.enrollment) {
                        HStack(spacing: 12) {
                            Text("Enroll Status")
                                .foregroundStyle(.primary)
                            Spacer(minLength: 8)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(enrollment.color)
                                    .frame(width: 9, height: 9)
                                Text(enrollment.title)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Explore Mode")
                }
                .listRowBackground(SettingsTheme.row)

                Section {
                    NavigationLink(value: SettingsRoute.experience) {
                        ValueRow(title: "Experience", value: experience)
                    }

                    Button {
                        path.append(.appLaunch)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("App Launch")
                                .foregroundStyle(.primary)
                            Text(appLaunch)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }

                    NavigationLink(value: SettingsRoute.policies) {
                        Text("Policies")
                    }

                    NavigationLink(value: SettingsRoute.security) {
                        Text("Device Security")
                    }

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
                case .enrollment: EnrollmentPicker(selection: $enrollment)
                case .experience: ExperiencePicker(selection: $experience)
                case .appLaunch:  AppLaunchEditor(bundleID: $appLaunch)
                case .policies:   PoliciesView()
                case .security:   DeviceSecurityView()
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

private struct EnrollmentPicker: View {
    @Binding var selection: EnrollmentStatus

    var body: some View {
        List {
            Section {
                ForEach(EnrollmentStatus.allCases) { option in
                    Button {
                        Haptics.select()
                        selection = option
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(option.color)
                                .frame(width: 10, height: 10)
                            Text(option.title)
                                .foregroundStyle(.primary)
                            Spacer()
                            if option == selection {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            } footer: {
                Text("The status is shown at the top of the Explore screen.")
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("Enroll Status")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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

private struct PoliciesView: View {
    @AppStorage(SettingsKeys.autoReset)   private var autoReset = true
    @AppStorage(SettingsKeys.idleTimeout) private var idleTimeout = 60

    var body: some View {
        List {
            Section {
                Toggle("Reset after inactivity", isOn: $autoReset)

                if autoReset {
                    Picker("Inactivity timeout", selection: $idleTimeout) {
                        Text("30 seconds").tag(30)
                        Text("1 minute").tag(60)
                        Text("2 minutes").tag(120)
                        Text("5 minutes").tag(300)
                    }
                    .pickerStyle(.menu)
                }
            } footer: {
                Text("Placeholder options for this demo. They don't change anything yet.")
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("Policies")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DeviceSecurityView: View {
    @AppStorage(SettingsKeys.singleApp)          private var singleApp = false
    @AppStorage(SettingsKeys.blockNotifications) private var blockNotifications = true

    var body: some View {
        List {
            Section {
                Toggle("Single-app mode", isOn: $singleApp)
                Toggle("Block notifications", isOn: $blockNotifications)
            } footer: {
                Text("Placeholder options for this demo. They don't change anything yet.")
            }
            .listRowBackground(SettingsTheme.row)
        }
        .settingsStyle()
        .navigationTitle("Device Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}
