import SwiftUI

enum Route: Hashable {
    case compare, pricing, features
}

struct HomeView: View {
    @State private var path: [Route] = []
    @State private var appeared = false

    private let model = PhoneModel.iPhone15Pro

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.background.ignoresSafeArea()

                // Soft blue glow behind the phone
                RadialGradient(
                    colors: [Theme.accent.opacity(0.28), Color.clear],
                    center: .bottom,
                    startRadius: 10,
                    endRadius: 460
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.top, 28)
                        .reveal(appeared, delay: 0.05)

                    tiles
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        .reveal(appeared, delay: 0.15)

                    discoverButton
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                        .reveal(appeared, delay: 0.25)

                    hero
                        .padding(.top, 8)
                        .reveal(appeared, delay: 0.35, offset: 70)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .compare:  CompareView()
                case .pricing:  PricingView()
                case .features: FeaturesView()
                }
            }
        }
        .onAppear { appeared = true }
    }

    // MARK: Pieces

    private var header: some View {
        VStack(spacing: 10) {
            Text("Let’s explore\n\(model.name)")
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("From \(Money.dollars(model.startingPrice)) or \(Money.monthly(model.startingPrice))/mo. for 24 mo.*")
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
        }
    }

    private var tiles: some View {
        HStack(spacing: 12) {
            HomeTile(title: "Compare models", action: { go(.compare) }) {
                CompareIcon()
            }
            HomeTile(title: "See pricing", action: { go(.pricing) }) {
                Image(systemName: "tag")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.white)
            }
        }
    }

    private var discoverButton: some View {
        Button {
            go(.features)
        } label: {
            Text("Discover new features")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.tile)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Theme.stroke, lineWidth: 1)
                )
        }
        .buttonStyle(PressableStyle())
    }

    /// Name of the photo in Assets.xcassets (drag iPhone15ProHero.png into the asset catalog).
    private static let heroImageName = "iPhone15ProHero"

    /// How wide the phone is, as a fraction of the screen width (1.0 = edge to edge).
    /// Lower = smaller phone, higher = bigger.
    private static let heroScale: CGFloat = 0.93

    private var hero: some View {
        GeometryReader { geo in
            Group {
                if let photo = UIImage(named: Self.heroImageName) {
                    // Real photo, top of the phone with the camera system, centered
                    let photoWidth = geo.size.width * Self.heroScale
                    Image(uiImage: photo)
                        .resizable()
                        .frame(
                            width: photoWidth,
                            height: photoWidth * photo.size.height / photo.size.width
                        )
                } else {
                    // Fallback: the phone drawn in SwiftUI
                    PhoneBack(base: model.colors[0].color)
                        .frame(
                            width: geo.size.width * Self.heroScale,
                            height: geo.size.width * Self.heroScale * PhoneBack.aspect
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .clipped()
            .mask(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .black, location: 0.0),
                        Gradient.Stop(color: .black, location: 0.72),
                        Gradient.Stop(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }

    private func go(_ route: Route) {
        Haptics.tap()
        path.append(route)
    }
}

// MARK: - Tile

struct HomeTile<Icon: View>: View {
    let title: String
    let action: () -> Void
    let icon: Icon

    init(title: String, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.action = action
        self.icon = icon()
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                icon.frame(height: 40)
                Text(title)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.tile)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }
}

/// Two outlined phones, like the "Compare models" icon in Apple's app.
struct CompareIcon: View {
    var body: some View {
        HStack(spacing: 6) {
            phone
            phone
        }
    }

    private var phone: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .stroke(Color.white, lineWidth: 1.6)
            .frame(width: 19, height: 34)
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white)
                    .frame(width: 7, height: 2)
                    .padding(.top, 4)
            }
    }
}
