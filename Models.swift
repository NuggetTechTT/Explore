import SwiftUI

// MARK: - Basic option types

struct ColorOption: Identifiable, Hashable {
    let id: String
    let name: String
    let color: Color
}

struct StorageOption: Identifiable, Hashable {
    let gb: Int
    let price: Int

    var id: Int { gb }
    var label: String { gb >= 1024 ? "\(gb / 1024)TB" : "\(gb)GB" }
}

// MARK: - Spec table

enum SpecSection: String, CaseIterable, Identifiable {
    case display     = "Display"
    case performance = "Performance"
    case design      = "Design"
    case camera      = "Camera"
    case battery     = "Battery & Connectivity"

    var id: String { rawValue }
}

enum SpecKey: CaseIterable, Identifiable {
    case size, display, refreshRate, brightness
    case chip
    case material, weight, button
    case mainCamera, ultraWide, telephoto
    case battery, port

    var id: Self { self }

    var title: String {
        switch self {
        case .size:        return "Screen size"
        case .display:     return "Display"
        case .refreshRate: return "Refresh rate"
        case .brightness:  return "Brightness"
        case .chip:        return "Chip"
        case .material:    return "Material"
        case .weight:      return "Weight"
        case .button:      return "Controls"
        case .mainCamera:  return "Main camera"
        case .ultraWide:   return "Ultra Wide"
        case .telephoto:   return "Telephoto"
        case .battery:     return "Battery life"
        case .port:        return "Connector"
        }
    }

    var section: SpecSection {
        switch self {
        case .size, .display, .refreshRate, .brightness: return .display
        case .chip:                                       return .performance
        case .material, .weight, .button:                 return .design
        case .mainCamera, .ultraWide, .telephoto:         return .camera
        case .battery, .port:                             return .battery
        }
    }
}

// MARK: - Phone model

struct PhoneModel: Identifiable, Hashable {
    let id: String
    let name: String
    /// SF Symbol that matches the phone's design generation:
    /// "iphone.gen1" = Home button (SE 3 and older)
    /// "iphone.gen2" = notch (iPhone 14 and older)
    /// "iphone"      = Dynamic Island (iPhone 14 Pro and newer)
    let symbol: String
    let colors: [ColorOption]
    let storage: [StorageOption]
    let appleCarePrice: Int
    let specs: [SpecKey: String]

    var startingPrice: Int { storage.map(\.price).min() ?? 0 }

    static func == (lhs: PhoneModel, rhs: PhoneModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Data (US launch pricing, used for demonstration)

extension PhoneModel {

    // Symbols by generation
    static let symbolHomeButton    = "iphone.gen1"
    static let symbolNotch         = "iphone.gen2"
    static let symbolDynamicIsland = "iphone"

    // MARK: Colors

    static let proColors: [ColorOption] = [
        ColorOption(id: "blue",    name: "Blue Titanium",    color: Color(red: 0.26, green: 0.36, blue: 0.49)),
        ColorOption(id: "natural", name: "Natural Titanium", color: Color(red: 0.62, green: 0.59, blue: 0.54)),
        ColorOption(id: "white",   name: "White Titanium",   color: Color(red: 0.87, green: 0.87, blue: 0.86)),
        ColorOption(id: "black",   name: "Black Titanium",   color: Color(red: 0.20, green: 0.21, blue: 0.22))
    ]

    static let standard15Colors: [ColorOption] = [
        ColorOption(id: "blue",   name: "Blue",   color: Color(red: 0.62, green: 0.74, blue: 0.86)),
        ColorOption(id: "pink",   name: "Pink",   color: Color(red: 0.90, green: 0.74, blue: 0.76)),
        ColorOption(id: "yellow", name: "Yellow", color: Color(red: 0.93, green: 0.87, blue: 0.58)),
        ColorOption(id: "green",  name: "Green",  color: Color(red: 0.70, green: 0.79, blue: 0.70)),
        ColorOption(id: "black",  name: "Black",  color: Color(red: 0.22, green: 0.22, blue: 0.23))
    ]

    static let pro14Colors: [ColorOption] = [
        ColorOption(id: "purple", name: "Deep Purple", color: Color(red: 0.36, green: 0.33, blue: 0.44)),
        ColorOption(id: "gold",   name: "Gold",        color: Color(red: 0.85, green: 0.78, blue: 0.65)),
        ColorOption(id: "silver", name: "Silver",      color: Color(red: 0.88, green: 0.88, blue: 0.89)),
        ColorOption(id: "black",  name: "Space Black", color: Color(red: 0.17, green: 0.17, blue: 0.18))
    ]

    static let standard14Colors: [ColorOption] = [
        ColorOption(id: "blue",     name: "Blue",     color: Color(red: 0.62, green: 0.74, blue: 0.86)),
        ColorOption(id: "purple",   name: "Purple",   color: Color(red: 0.78, green: 0.73, blue: 0.88)),
        ColorOption(id: "yellow",   name: "Yellow",   color: Color(red: 0.97, green: 0.90, blue: 0.45)),
        ColorOption(id: "midnight", name: "Midnight", color: Color(red: 0.14, green: 0.16, blue: 0.20)),
        ColorOption(id: "starlight", name: "Starlight", color: Color(red: 0.93, green: 0.91, blue: 0.87)),
        ColorOption(id: "red",      name: "(PRODUCT)RED", color: Color(red: 0.75, green: 0.08, blue: 0.13))
    ]

    static let iPhone13Colors: [ColorOption] = [
        ColorOption(id: "blue",     name: "Blue",     color: Color(red: 0.55, green: 0.68, blue: 0.80)),
        ColorOption(id: "pink",     name: "Pink",     color: Color(red: 0.93, green: 0.80, blue: 0.80)),
        ColorOption(id: "midnight", name: "Midnight", color: Color(red: 0.14, green: 0.16, blue: 0.20)),
        ColorOption(id: "starlight", name: "Starlight", color: Color(red: 0.93, green: 0.91, blue: 0.87)),
        ColorOption(id: "green",    name: "Green",    color: Color(red: 0.30, green: 0.40, blue: 0.33)),
        ColorOption(id: "red",      name: "(PRODUCT)RED", color: Color(red: 0.75, green: 0.08, blue: 0.13))
    ]

    static let seColors: [ColorOption] = [
        ColorOption(id: "midnight", name: "Midnight", color: Color(red: 0.14, green: 0.16, blue: 0.20)),
        ColorOption(id: "starlight", name: "Starlight", color: Color(red: 0.93, green: 0.91, blue: 0.87)),
        ColorOption(id: "red",      name: "(PRODUCT)RED", color: Color(red: 0.75, green: 0.08, blue: 0.13))
    ]

    // MARK: iPhone 15 family — Dynamic Island

    static let iPhone15Pro = PhoneModel(
        id: "15pro",
        name: "iPhone 15 Pro",
        symbol: symbolDynamicIsland,
        colors: proColors,
        storage: [
            StorageOption(gb: 128,  price: 999),
            StorageOption(gb: 256,  price: 1099),
            StorageOption(gb: 512,  price: 1299),
            StorageOption(gb: 1024, price: 1499)
        ],
        appleCarePrice: 199,
        specs: [
            .size: "6.1\"",
            .display: "Super Retina XDR OLED with Always-On",
            .refreshRate: "ProMotion up to 120Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A17 Pro",
            .material: "Titanium",
            .weight: "187 g",
            .button: "Action button",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "3x Telephoto",
            .battery: "Up to 23 hours video",
            .port: "USB-C (USB 3)"
        ]
    )

    static let iPhone15ProMax = PhoneModel(
        id: "15promax",
        name: "iPhone 15 Pro Max",
        symbol: symbolDynamicIsland,
        colors: proColors,
        storage: [
            StorageOption(gb: 256,  price: 1199),
            StorageOption(gb: 512,  price: 1399),
            StorageOption(gb: 1024, price: 1599)
        ],
        appleCarePrice: 229,
        specs: [
            .size: "6.7\"",
            .display: "Super Retina XDR OLED with Always-On",
            .refreshRate: "ProMotion up to 120Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A17 Pro",
            .material: "Titanium",
            .weight: "221 g",
            .button: "Action button",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "5x Telephoto",
            .battery: "Up to 29 hours video",
            .port: "USB-C (USB 3)"
        ]
    )

    static let iPhone15 = PhoneModel(
        id: "15",
        name: "iPhone 15",
        symbol: symbolDynamicIsland,
        colors: standard15Colors,
        storage: [
            StorageOption(gb: 128, price: 799),
            StorageOption(gb: 256, price: 899),
            StorageOption(gb: 512, price: 1099)
        ],
        appleCarePrice: 149,
        specs: [
            .size: "6.1\"",
            .display: "Super Retina XDR OLED",
            .refreshRate: "60Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A16 Bionic",
            .material: "Aluminum",
            .weight: "171 g",
            .button: "Ring/Silent switch",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "—",
            .battery: "Up to 20 hours video",
            .port: "USB-C (USB 2)"
        ]
    )

    static let iPhone15Plus = PhoneModel(
        id: "15plus",
        name: "iPhone 15 Plus",
        symbol: symbolDynamicIsland,
        colors: standard15Colors,
        storage: [
            StorageOption(gb: 128, price: 899),
            StorageOption(gb: 256, price: 999),
            StorageOption(gb: 512, price: 1199)
        ],
        appleCarePrice: 169,
        specs: [
            .size: "6.7\"",
            .display: "Super Retina XDR OLED",
            .refreshRate: "60Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A16 Bionic",
            .material: "Aluminum",
            .weight: "201 g",
            .button: "Ring/Silent switch",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "—",
            .battery: "Up to 26 hours video",
            .port: "USB-C (USB 2)"
        ]
    )

    // MARK: iPhone 14 Pro family — Dynamic Island

    static let iPhone14Pro = PhoneModel(
        id: "14pro",
        name: "iPhone 14 Pro",
        symbol: symbolDynamicIsland,
        colors: pro14Colors,
        storage: [
            StorageOption(gb: 128,  price: 999),
            StorageOption(gb: 256,  price: 1099),
            StorageOption(gb: 512,  price: 1299),
            StorageOption(gb: 1024, price: 1499)
        ],
        appleCarePrice: 199,
        specs: [
            .size: "6.1\"",
            .display: "Super Retina XDR OLED with Always-On",
            .refreshRate: "ProMotion up to 120Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A16 Bionic",
            .material: "Stainless steel",
            .weight: "206 g",
            .button: "Ring/Silent switch",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "3x Telephoto",
            .battery: "Up to 23 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    static let iPhone14ProMax = PhoneModel(
        id: "14promax",
        name: "iPhone 14 Pro Max",
        symbol: symbolDynamicIsland,
        colors: pro14Colors,
        storage: [
            StorageOption(gb: 128,  price: 1099),
            StorageOption(gb: 256,  price: 1199),
            StorageOption(gb: 512,  price: 1399),
            StorageOption(gb: 1024, price: 1599)
        ],
        appleCarePrice: 229,
        specs: [
            .size: "6.7\"",
            .display: "Super Retina XDR OLED with Always-On",
            .refreshRate: "ProMotion up to 120Hz",
            .brightness: "2000 nits peak (outdoor)",
            .chip: "A16 Bionic",
            .material: "Stainless steel",
            .weight: "240 g",
            .button: "Ring/Silent switch",
            .mainCamera: "48MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "3x Telephoto",
            .battery: "Up to 29 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    // MARK: iPhone 14 and older — notch

    static let iPhone14 = PhoneModel(
        id: "14",
        name: "iPhone 14",
        symbol: symbolNotch,
        colors: standard14Colors,
        storage: [
            StorageOption(gb: 128, price: 799),
            StorageOption(gb: 256, price: 899),
            StorageOption(gb: 512, price: 1099)
        ],
        appleCarePrice: 149,
        specs: [
            .size: "6.1\"",
            .display: "Super Retina XDR OLED",
            .refreshRate: "60Hz",
            .brightness: "1200 nits peak (HDR)",
            .chip: "A15 Bionic",
            .material: "Aluminum",
            .weight: "172 g",
            .button: "Ring/Silent switch",
            .mainCamera: "12MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "—",
            .battery: "Up to 20 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    static let iPhone14Plus = PhoneModel(
        id: "14plus",
        name: "iPhone 14 Plus",
        symbol: symbolNotch,
        colors: standard14Colors,
        storage: [
            StorageOption(gb: 128, price: 899),
            StorageOption(gb: 256, price: 999),
            StorageOption(gb: 512, price: 1199)
        ],
        appleCarePrice: 169,
        specs: [
            .size: "6.7\"",
            .display: "Super Retina XDR OLED",
            .refreshRate: "60Hz",
            .brightness: "1200 nits peak (HDR)",
            .chip: "A15 Bionic",
            .material: "Aluminum",
            .weight: "203 g",
            .button: "Ring/Silent switch",
            .mainCamera: "12MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "—",
            .battery: "Up to 26 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    static let iPhone13 = PhoneModel(
        id: "13",
        name: "iPhone 13",
        symbol: symbolNotch,
        colors: iPhone13Colors,
        storage: [
            StorageOption(gb: 128, price: 799),
            StorageOption(gb: 256, price: 899),
            StorageOption(gb: 512, price: 1099)
        ],
        appleCarePrice: 149,
        specs: [
            .size: "6.1\"",
            .display: "Super Retina XDR OLED",
            .refreshRate: "60Hz",
            .brightness: "1200 nits peak (HDR)",
            .chip: "A15 Bionic",
            .material: "Aluminum",
            .weight: "174 g",
            .button: "Ring/Silent switch",
            .mainCamera: "12MP Main",
            .ultraWide: "12MP Ultra Wide",
            .telephoto: "—",
            .battery: "Up to 19 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    // MARK: iPhone SE 3 and older — Home button

    static let iPhoneSE3 = PhoneModel(
        id: "se3",
        name: "iPhone SE (3rd gen)",
        symbol: symbolHomeButton,
        colors: seColors,
        storage: [
            StorageOption(gb: 64,  price: 429),
            StorageOption(gb: 128, price: 479),
            StorageOption(gb: 256, price: 579)
        ],
        appleCarePrice: 129,
        specs: [
            .size: "4.7\"",
            .display: "Retina HD LCD",
            .refreshRate: "60Hz",
            .brightness: "625 nits typical",
            .chip: "A15 Bionic",
            .material: "Aluminum",
            .weight: "144 g",
            .button: "Home button, Ring/Silent switch",
            .mainCamera: "12MP Main",
            .ultraWide: "—",
            .telephoto: "—",
            .battery: "Up to 15 hours video",
            .port: "Lightning (USB 2)"
        ]
    )

    static let all: [PhoneModel] = [
        iPhone15Pro, iPhone15ProMax, iPhone15, iPhone15Plus,
        iPhone14Pro, iPhone14ProMax, iPhone14, iPhone14Plus,
        iPhone13, iPhoneSE3
    ]
}
