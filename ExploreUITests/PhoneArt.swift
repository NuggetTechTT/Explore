import SwiftUI

// A vector iPhone 15 Pro back, drawn entirely in SwiftUI (no image assets needed).
// `base` is the body color, so the same art works for every color option.

struct PhoneBack: View {
    static let aspect: CGFloat = 2.05      // height / width

    var base: Color

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let outer = w * 0.17
            let inner = outer * 0.92

            ZStack(alignment: .topLeading) {
                // Titanium frame
                RoundedRectangle(cornerRadius: outer, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.60), base, Color.white.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Back glass
                RoundedRectangle(cornerRadius: inner, style: .continuous)
                    .fill(base)
                    .overlay {
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), Color.white.opacity(0.02), Color.black.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: inner, style: .continuous))
                    .padding(w * 0.025)

                // Camera plateau
                CameraPlate(base: base)
                    .frame(width: w * 0.5, height: w * 0.5)
                    .offset(x: w * 0.075, y: w * 0.075)
            }
            .shadow(color: Color.black.opacity(0.5), radius: w * 0.05, x: 0, y: w * 0.03)
        }
    }
}

struct CameraPlate: View {
    var base: Color

    var body: some View {
        GeometryReader { g in
            let p = g.size.width
            let lens = p * 0.36
            let corner = p * 0.28

            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(base)
                    .overlay {
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.35), radius: p * 0.04, x: 0, y: p * 0.02)

                CameraLens(size: lens).position(x: p * 0.30, y: p * 0.29)
                CameraLens(size: lens).position(x: p * 0.30, y: p * 0.71)
                CameraLens(size: lens).position(x: p * 0.71, y: p * 0.50)

                // Flash
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.96, blue: 0.82), Color(red: 0.85, green: 0.78, blue: 0.55)],
                            center: .center,
                            startRadius: 0,
                            endRadius: p * 0.06
                        )
                    )
                    .overlay(Circle().strokeBorder(Color.black.opacity(0.35), lineWidth: 1))
                    .frame(width: p * 0.11, height: p * 0.11)
                    .position(x: p * 0.72, y: p * 0.16)

                // LiDAR scanner
                Circle()
                    .fill(Color.black)
                    .overlay(
                        Circle()
                            .fill(Color(red: 0.12, green: 0.14, blue: 0.24))
                            .padding(p * 0.018)
                    )
                    .frame(width: p * 0.11, height: p * 0.11)
                    .position(x: p * 0.72, y: p * 0.84)
            }
            .frame(width: p, height: p)
        }
    }
}

struct CameraLens: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Metal ring
            Circle().fill(
                AngularGradient(
                    colors: [
                        Color(white: 0.88), Color(white: 0.38), Color(white: 0.92),
                        Color(white: 0.34), Color(white: 0.88)
                    ],
                    center: .center
                )
            )
            Circle().fill(Color.black).padding(size * 0.07)
            // Glass
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.22, green: 0.28, blue: 0.50),
                            Color(red: 0.05, green: 0.06, blue: 0.14),
                            Color.black
                        ],
                        center: UnitPoint(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: size * 0.42
                    )
                )
                .padding(size * 0.14)
            Circle()
                .strokeBorder(Color.white.opacity(0.12), lineWidth: max(1, size * 0.015))
                .padding(size * 0.30)
            // Reflections
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.09, height: size * 0.09)
                .offset(x: -size * 0.15, y: -size * 0.17)
            Circle()
                .fill(Color(red: 0.40, green: 0.50, blue: 0.90).opacity(0.35))
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.12, y: size * 0.14)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.45), radius: size * 0.08, x: 0, y: size * 0.05)
    }
}

/// Top part of the phone only, fading out at the bottom (like the hero image in the Explore app).
struct CroppedPhone: View {
    var base: Color
    var width: CGFloat
    var visibleHeight: CGFloat

    var body: some View {
        PhoneBack(base: base)
            .frame(width: width, height: width * PhoneBack.aspect)
            .frame(width: width, height: visibleHeight, alignment: .top)
            .clipped()
            .mask(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .black, location: 0.0),
                        Gradient.Stop(color: .black, location: 0.7),
                        Gradient.Stop(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}
