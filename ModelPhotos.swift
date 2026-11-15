import SwiftUI
import UIKit

/// Finds the photo for a phone model in a given color.
/// Photos live in ModelPhotos.xcassets and are named  phone_<model id>_<color id>
/// for example:  phone_15pro_blue   phone_14_yellow   phone_se3_red
enum ModelPhotos {
    static func name(model: PhoneModel, color: ColorOption) -> String {
        "phone_\(model.id)_\(color.id)"
    }

    /// nil when there is no photo for that color (the app then shows its old drawn picture instead).
    static func image(model: PhoneModel, color: ColorOption) -> UIImage? {
        UIImage(named: name(model: model, color: color))
    }
}

/// A model photo that fades out toward the bottom, into the black background (like Apple's demo app).
struct FadedPhoto: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .mask(fade)
    }

    /// Where the fade starts and ends, from the top (0) to the bottom (1) of the photo.
    /// Raise `fadeStart` to keep more of the phone visible; lower it for a longer fade.
    private static let fadeStart: CGFloat = 0.45
    private static let fadeEnd: CGFloat = 0.98

    private var fade: some View {
        let stops: [Gradient.Stop] = [
            Gradient.Stop(color: .black, location: 0.0),
            Gradient.Stop(color: .black, location: Self.fadeStart),
            Gradient.Stop(color: .clear, location: Self.fadeEnd)
        ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }
}
