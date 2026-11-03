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
