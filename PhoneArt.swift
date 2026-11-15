import SwiftUI
import UIKit

// A vector iPhone back, drawn entirely in SwiftUI (no image assets needed).
// `base` is the body color and `lenses` is the number of rear cameras (3 = Pro, 2 = standard, 1 = SE).

private let phoneFadeMask = LinearGradient(
    stops: [
        Gradient.Stop(color: .black, location: 0.0),
        Gradient.Stop(color: .black, location: 0.72),
        Gradient.Stop(color: .clear, location: 1.0)
    ],
    startPoint: .top,
    endPoint: .bottom
)

struct PhoneBack: View {
    static let aspect: CGFloat = 2.05      // height / width

    var base: Color
    var lenses: Int = 3

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let outer = w * 0.17
            let inner = outer * 0.92

            ZStack(alignment: .topLeading) {
                // Frame
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

                // Cameras
                if lenses >= 2 {
                    let plate = lenses >= 3 ? w * 0.5 : w * 0.44
                    CameraPlate(base: base, lenses: lenses)
                        .frame(width: plate, height: plate)
                        .offset(x: w * 0.075, y: w * 0.075)
                } else {
                    singleLens(w)
                }
            }
            .shadow(color: Color.black.opacity(0.5), radius: w * 0.05, x: 0, y: w * 0.03)
        }
    }

    private func singleLens(_ w: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            CameraLens(size: w * 0.18)
                .offset(x: w * 0.09, y: w * 0.09)
            Circle()
                .fill(Color(red: 0.95, green: 0.92, blue: 0.80))
                .overlay(Circle().strokeBorder(Color.black.opacity(0.35), lineWidth: 1))
                .frame(width: w * 0.06, height: w * 0.06)
                .offset(x: w * 0.33, y: w * 0.105)
        }
    }
}

struct CameraPlate: View {
    var base: Color
    var lenses: Int = 3

    var body: some View {
        GeometryReader { g in
            let p = g.size.width
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

                if lenses >= 3 {
                    // Pro: three lenses, flash and LiDAR scanner
                    let lens = p * 0.36
                    CameraLens(size: lens).position(x: p * 0.30, y: p * 0.29)
                    CameraLens(size: lens).position(x: p * 0.30, y: p * 0.71)
                    CameraLens(size: lens).position(x: p * 0.71, y: p * 0.50)

                    flash(p).position(x: p * 0.72, y: p * 0.16)

                    Circle()
                        .fill(Color.black)
                        .overlay(
                            Circle()
                                .fill(Color(red: 0.12, green: 0.14, blue: 0.24))
                                .padding(p * 0.018)
                        )
                        .frame(width: p * 0.11, height: p * 0.11)
                        .position(x: p * 0.72, y: p * 0.84)
                } else {
                    // Standard: two lenses on a diagonal, flash at the top right
                    let lens = p * 0.40
                    CameraLens(size: lens).position(x: p * 0.31, y: p * 0.31)
                    CameraLens(size: lens).position(x: p * 0.69, y: p * 0.69)
                    flash(p).position(x: p * 0.73, y: p * 0.22)
                }
            }
            .frame(width: p, height: p)
        }
    }

    private func flash(_ p: CGFloat) -> some View {
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

/// Top part of the drawn phone only, fading out at the bottom.
struct CroppedPhone: View {
    var base: Color
    var width: CGFloat
    var visibleHeight: CGFloat
    var lenses: Int = 3

    var body: some View {
        PhoneBack(base: base, lenses: lenses)
            .frame(width: width, height: width * PhoneBack.aspect)
            .frame(width: width, height: visibleHeight, alignment: .top)
            .clipped()
            .mask(phoneFadeMask)
    }
}

/// Fade used for model photos: solid at the top, gone by the bottom (like Apple's demo app).
private let photoFadeMask = LinearGradient(
    stops: [
        Gradient.Stop(color: .black, location: 0.0),
        Gradient.Stop(color: .black, location: 0.45),
        Gradient.Stop(color: .clear, location: 0.98)
    ],
    startPoint: .top,
    endPoint: .bottom
)

/// Cuts the empty transparent border off a photo so every phone sits at the same spot
/// and can be sized by the phone itself, not by the empty space around it.
enum PhotoTrim {
    private static let cache = NSCache<NSString, UIImage>()

    static func trimmed(_ image: UIImage, key: String) -> UIImage {
        if let cached = cache.object(forKey: key as NSString) { return cached }
        let result = crop(image) ?? image
        cache.setObject(result, forKey: key as NSString)
        return result
    }

    private static func crop(_ image: UIImage) -> UIImage? {
        guard let cg = image.cgImage else { return nil }
        let w = cg.width
        let h = cg.height
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        var drew = false
        pixels.withUnsafeMutableBytes { buffer in
            guard let ctx = CGContext(
                data: buffer.baseAddress,
                width: w, height: h,
                bitsPerComponent: 8, bytesPerRow: w * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
            drew = true
        }
        guard drew else { return nil }

        var minX = w, maxX = -1, minY = h, maxY = -1
        for y in 0..<h {
            for x in 0..<w where pixels[(y * w + x) * 4 + 3] > 16 {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
        guard maxX >= minX, maxY >= minY else { return nil }

        let rect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        guard let out = cg.cropping(to: rect) else { return nil }
        return UIImage(cgImage: out, scale: image.scale, orientation: image.imageOrientation)
    }
}

/// Main photo for a model + color.
/// Uses the real photo from ModelPhotos.xcassets (phone_<modelID>_<colorID>, for example
/// phone_15promax_blue) when one exists, otherwise the drawn phone.
struct ModelPhoto: View {
    let model: PhoneModel
    let finish: ColorOption
    var width: CGFloat            // room available for the phone
    var visibleHeight: CGFloat    // height of the area the phone sits in

    // How wide the phone itself is drawn, in points. Make these smaller or bigger to taste.
    static let widthStandard: CGFloat = 112   // base and Pro iPhones (6.1")
    static let widthLarge: CGFloat    = 120   // Plus and Pro Max iPhones (6.7")
    static let widthSE: CGFloat       = 100   // iPhone SE

    static func phoneWidth(for model: PhoneModel) -> CGFloat {
        if model.id.hasPrefix("se") { return widthSE }
        if model.id.hasSuffix("max") || model.id.hasSuffix("plus") { return widthLarge }
        return widthStandard
    }

    static func photo(for model: PhoneModel, finish: ColorOption) -> UIImage? {
        guard let image = ModelPhotos.image(model: model, color: finish) else { return nil }
        return PhotoTrim.trimmed(image, key: ModelPhotos.name(model: model, color: finish))
    }

    var body: some View {
        if let photo = Self.photo(for: model, finish: finish) {
            let phoneWidth = Self.phoneWidth(for: model)
            let phoneHeight = phoneWidth * photo.size.height / photo.size.width
            Image(uiImage: photo)
                .resizable()
                .frame(width: phoneWidth, height: phoneHeight)
                .mask(photoFadeMask)
                .frame(width: phoneWidth, height: visibleHeight, alignment: .top)
                .clipped()
                .frame(width: width, height: visibleHeight)
        } else {
            CroppedPhone(
                base: finish.color,
                width: width * 0.58,
                visibleHeight: visibleHeight,
                lenses: model.cameraCount
            )
            .frame(width: width, height: visibleHeight)
        }
    }
}
