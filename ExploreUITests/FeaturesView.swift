import SwiftUI

struct Feature: Identifiable {
    let id: String
    let symbol: String
    let eyebrow: String
    let title: String
    let points: [String]

    static let all: [Feature] = [
        Feature(
            id: "titanium",
            symbol: "iphone.gen3",
            eyebrow: "Design",
            title: "Titanium.\nSo strong. So light. So Pro.",
            points: [
                "Aerospace-grade titanium frame",
                "The lightest Pro models ever",
                "Contoured edges for a comfortable grip"
            ]
        ),
        Feature(
            id: "chip",
            symbol: "cpu.fill",
            eyebrow: "Performance",
            title: "A17 Pro.\nA monster win for gaming.",
            points: [
                "Faster 6-core GPU with hardware ray tracing",
                "Next-generation Neural Engine",
                "Console-level games, right on your iPhone"
            ]
        ),
        Feature(
            id: "action",
            symbol: "hand.tap.fill",
            eyebrow: "Action button",
            title: "Your shortcut to what you love.",
            points: [
                "Replaces the Ring/Silent switch",
                "Camera, flashlight, Shortcuts and more",
                "Press and hold to trigger your action"
            ]
        ),
        Feature(
            id: "camera",
            symbol: "camera.aperture",
            eyebrow: "Camera",
            title: "A Pro camera system.\nThe 48MP Main camera.",
            points: [
                "Choose 24 mm, 28 mm or 35 mm Main presets",
                "Optical zoom up to 3x (5x on Pro Max)",
                "Next-generation portraits"
            ]
        ),
        Feature(
            id: "usbc",
            symbol: "cable.connector",
            eyebrow: "Connectivity",
            title: "USB-C.\nOne cable for everything.",
            points: [
                "USB 3 speeds for fast transfers",
                "Charge AirPods and Apple Watch",
                "Use one cable for iPhone, Mac and iPad"
            ]
        ),
        Feature(
            id: "battery",
            symbol: "battery.100",
            eyebrow: "Battery",
            title: "All-day battery life.",
            points: [
                "Up to 23 hours of video playback",
                "Up to 29 hours on iPhone 15 Pro Max",
                "Fast charge with a 20W adapter or higher"
            ]
        )
    ]
}

struct FeaturesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private var isLast: Bool { page == Feature.all.count - 1 }

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $page) {
                ForEach(Array(Feature.all.enumerated()), id: \.element.id) { index, feature in
                    FeatureCard(feature: feature)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageDots

            Button {
                Haptics.tap()
                if isLast {
                    dismiss()
                } else {
                    withAnimation(.snap) { page += 1 }
                }
            } label: {
                Text(isLast ? "Done" : "Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Capsule().fill(Theme.accent))
            }
            .buttonStyle(PressableStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("New features")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<Feature.all.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == page ? 22 : 8, height: 8)
            }
        }
        .animation(.snap, value: page)
    }
}

private struct FeatureCard: View {
    let feature: Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 0)

            Image(systemName: feature.symbol)
                .font(.system(size: 72, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Theme.accentSoft],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Theme.accent.opacity(0.6), radius: 24)
                .padding(.bottom, 8)

            Text(feature.eyebrow)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.accentSoft)

            Text(feature.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(feature.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.accent)
                        Text(point)
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .font(.subheadline)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.19, blue: 0.31), Color(red: 0.04, green: 0.06, blue: 0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Theme.stroke, lineWidth: 1)
        )
    }
}
