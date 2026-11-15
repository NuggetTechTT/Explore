import SwiftUI

struct CompareView: View {
    @State private var left = PhoneModel.iPhone15Pro
    @State private var right = PhoneModel.iPhone15
    @State private var differencesOnly = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Toggle("Show differences only", isOn: $differencesOnly.animation(.snap))
                    .tint(Theme.accent)
                    .font(.subheadline)
                    .foregroundStyle(.white)

                ForEach(SpecSection.allCases) { section in
                    sectionView(section)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .navigationTitle("Compare models")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Header (stays pinned while scrolling)

    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                ModelColumn(model: $left)
                ModelColumn(model: $right)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider().overlay(Theme.stroke)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: Sections

    @ViewBuilder
    private func sectionView(_ section: SpecSection) -> some View {
        let keys = SpecKey.allCases.filter { key in
            key.section == section && (!differencesOnly || left.specs[key] != right.specs[key])
        }

        if !keys.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(section.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 0) {
                    ForEach(keys) { key in
                        SpecRow(
                            title: key.title,
                            left: left.specs[key] ?? "—",
                            right: right.specs[key] ?? "—"
                        )
                        if key != keys.last {
                            Divider().overlay(Theme.stroke)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .cardStyle()
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Column header with model picker

private struct ModelColumn: View {
    @Binding var model: PhoneModel

    var body: some View {
        VStack(spacing: 8) {
            picture

            Menu {
                Picker("Model", selection: $model) {
                    ForEach(PhoneModel.all) { option in
                        Label(option.name, systemImage: option.symbol).tag(option)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(model.name)
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(Theme.accentSoft)
            }

            Text("From \(Money.dollars(model.startingPrice))")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    /// Photo of the model (first color). If there is no photo, the phone symbol is shown.
    @ViewBuilder
    private var picture: some View {
        if let first = model.colors.first, let photo = ModelPhotos.image(model: model, color: first) {
            FadedPhoto(image: photo)
                .frame(height: 96)
                .id(ModelPhotos.name(model: model, color: first))
                .transition(.opacity)
        } else {
            Image(systemName: model.symbol)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.accentSoft)
                .frame(height: 56)
        }
    }
}

// MARK: - One comparison row

private struct SpecRow: View {
    let title: String
    let left: String
    let right: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.secondaryText)

            HStack(alignment: .top, spacing: 12) {
                Text(left).frame(maxWidth: .infinity)
                Text(right).frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
    }
}
