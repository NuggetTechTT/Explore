import SwiftUI

struct PricingView: View {
    enum Payment: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case full    = "Pay in full"

        var id: String { rawValue }
    }

    struct TradeIn: Identifiable, Hashable {
        let id: String
        let name: String
        let credit: Int
    }

    // Demo values only.
    static let tradeIns: [TradeIn] = [
        TradeIn(id: "14pro", name: "iPhone 14 Pro", credit: 450),
        TradeIn(id: "13",    name: "iPhone 13",     credit: 270),
        TradeIn(id: "12",    name: "iPhone 12",     credit: 170),
        TradeIn(id: "11",    name: "iPhone 11",     credit: 100)
    ]

    @State private var model = PhoneModel.iPhone15Pro
    @State private var storageIndex = 0
    @State private var colorIndex = 0
    @State private var payment: Payment = .monthly
    @State private var useTradeIn = false
    @State private var tradeIn = PricingView.tradeIns[0]
    @State private var appleCare = false
    @State private var showDemoAlert = false

    // MARK: Derived values

    private var storage: StorageOption { model.storage[min(storageIndex, model.storage.count - 1)] }
    private var finish: ColorOption { model.colors[min(colorIndex, model.colors.count - 1)] }
    private var credit: Int { useTradeIn ? tradeIn.credit : 0 }
    private var total: Int {
        max(0, storage.price - credit) + (appleCare ? model.appleCarePrice : 0)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                modelChips
                preview
                colorSection
                storageSection
                paymentSection
                tradeInSection
                careSection
                footnote
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .navigationTitle("Pricing")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Demo only", isPresented: $showDemoAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This is a design demo, so nothing is actually purchased.")
        }
    }

    // MARK: Sections

    private var modelChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PhoneModel.all) { option in
                    Button {
                        Haptics.select()
                        withAnimation(.snap) {
                            model = option
                            storageIndex = 0
                            colorIndex = 0
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 14, weight: .medium))
                            Text(option.name)
                                .font(.subheadline.weight(.semibold))
                        }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(option == model ? Theme.accent : Theme.card)
                            )
                            .overlay(
                                Capsule().strokeBorder(Theme.stroke, lineWidth: option == model ? 0 : 1)
                            )
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }

    private var preview: some View {
        VStack(spacing: 14) {
            previewPicture

            VStack(spacing: 4) {
                Text(model.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("\(finish.name) · \(storage.label)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.35), value: finish.id)
    }

    /// The real photo for this model and color. If there is no photo, the old drawn picture is used.
    @ViewBuilder
    private var previewPicture: some View {
        if let photo = ModelPhotos.image(model: model, color: finish) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 14)
                .id(ModelPhotos.name(model: model, color: finish))
                .transition(.opacity)
        } else {
            drawnPicture
        }
    }

    private var drawnPicture: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(finish.color)
                    .overlay {
                        LinearGradient(
                            colors: [Color.white.opacity(0.28), Color.clear, Color.black.opacity(0.30)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 38, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
                    .shadow(color: finish.color.opacity(0.55), radius: 30, x: 0, y: 12)

                Image(systemName: model.symbol)
                    .font(.system(size: 84, weight: .light))
                    .foregroundStyle(finish.color.isLight ? Color.black.opacity(0.75) : Color.white)
            }
            .frame(width: 160, height: 160)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Finish", detail: finish.name)

            HStack(spacing: 16) {
                ForEach(Array(model.colors.enumerated()), id: \.element.id) { index, option in
                    Button {
                        Haptics.select()
                        withAnimation(.snap) { colorIndex = index }
                    } label: {
                        Circle()
                            .fill(option.color)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.25), lineWidth: 1))
                            .padding(4)
                            .overlay(
                                Circle()
                                    .strokeBorder(Theme.accent, lineWidth: 2)
                                    .opacity(index == colorIndex ? 1 : 0)
                            )
                    }
                    .buttonStyle(PressableStyle())
                    .accessibilityLabel(option.name)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Storage")

            ForEach(Array(model.storage.enumerated()), id: \.element.id) { index, option in
                let selected = index == storageIndex

                Button {
                    Haptics.select()
                    withAnimation(.snap) { storageIndex = index }
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.headline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if payment == .monthly {
                                Text("From \(Money.monthly(option.price))/mo.")
                                    .font(.subheadline.weight(.semibold))
                                Text("for 24 mo. or \(Money.dollars(option.price))")
                                    .font(.caption)
                                    .foregroundStyle(Theme.secondaryText)
                            } else {
                                Text(Money.dollars(option.price))
                                    .font(.subheadline.weight(.semibold))
                                Text("or \(Money.monthly(option.price))/mo. for 24 mo.")
                                    .font(.caption)
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selected ? Theme.accent : Theme.stroke, lineWidth: selected ? 2 : 1)
                    )
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Payment")

            Picker("Payment", selection: $payment.animation(.snap)) {
                ForEach(Payment.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var tradeInSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $useTradeIn.animation(.snap)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trade in your iPhone")
                        .font(.headline)
                    Text("Get credit toward your new iPhone.")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .tint(Theme.accent)
            .foregroundStyle(.white)

            if useTradeIn {
                HStack {
                    Text("Your device")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Menu {
                        ForEach(PricingView.tradeIns) { option in
                            Button("\(option.name) – \(Money.dollars(option.credit)) credit") {
                                Haptics.select()
                                tradeIn = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(tradeIn.name) · −\(Money.dollars(tradeIn.credit))")
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2.weight(.bold))
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accentSoft)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private var careSection: some View {
        Toggle(isOn: $appleCare.animation(.snap)) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Add AppleCare+")
                    .font(.headline)
                Text("\(Money.dollars(model.appleCarePrice)) one-time · accidental damage coverage")
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .tint(Theme.accent)
        .foregroundStyle(.white)
        .padding(16)
        .cardStyle()
    }

    private var footnote: some View {
        Text("*Monthly pricing shown for 24-month financing with qualifying credit. Prices are US launch prices. Trade-in values and AppleCare+ prices are estimates for this demo.")
            .font(.caption2)
            .foregroundStyle(Theme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().overlay(Theme.stroke)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(payment == .monthly ? "\(Money.monthly(total))/mo." : Money.dollars(total))
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text(payment == .monthly
                         ? "for 24 mo. · or \(Money.dollars(total))"
                         : "\(model.name) · \(storage.label)")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                .animation(.snap, value: total)

                Spacer()

                Button {
                    Haptics.tap()
                    showDemoAlert = true
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Theme.accent))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: Helpers

    private func sectionTitle(_ title: String, detail: String? = nil) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
            if let detail {
                Text(detail)
                    .font(.title3)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer(minLength: 0)
        }
    }
}
