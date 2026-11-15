# Explore for iPhone

A SwiftUI recreation of Apple's retail **Explore** demo app, built for iPhone and focused on the **iPhone 15 Pro**. It follows the original's look and flow: a dark Home menu with a large hero phone, side-by-side model comparison, a pricing configurator, and a feature tour.

> **Unofficial project.** This is a fan-made design and learning project. It is not affiliated with, endorsed by, or sponsored by Apple Inc. Apple, iPhone, and related names and images are trademarks of Apple Inc. Prices, trade-in values, and AppleCare+ amounts are demo values. Nothing is ever purchased.

<!-- Add screenshots here, for example:
<p align="center">
  <img src="Screenshots/home.png" width="240">
  <img src="Screenshots/pricing.png" width="240">
  <img src="Screenshots/compare.png" width="240">
</p>
-->

## Features

### Home
- "Let's explore iPhone 15 Pro" header with the starting price and 24-month price
- Tiles for **Compare models**, **See pricing**, and **Discover new features**
- Hero photo of the iPhone 15 Pro that fades into the black background
- Short launch animation when the app opens

### Compare models
- Spec table that compares iPhone models side by side
- Sections for Display, Performance, Design, Camera, and Battery & Connectivity
- Model photos that fade into the background

### See pricing
- **Model chips** along the top, using SF Symbols that match each phone's design (Home button, notch, Dynamic Island)
- **Real model photos** for the main preview, sized by phone type (base, Pro, Plus / Pro Max, SE)
- Finish selector that swaps the photo for each color
- Storage options with monthly and full prices
- Monthly (24-month) or Pay in full
- Trade-in estimate and optional AppleCare+
- Bottom bar with the running total and a Continue button (demo only)

### Discover new features
- Feature tour for the iPhone 15 Pro: titanium design, A17 Pro, Action button, and more

### Demo unit behavior
- **Idle detection:** after 30 seconds with no touch and no movement, an "Are You Still Here?" prompt appears with a 5-second countdown, then a screen saver. Touching or moving the device returns to the Home menu.
- **Hidden Settings:** hold three fingers on the screen for five seconds to open a Settings screen (enrollment, experience, app launch, policies, security).
- **Standard / Demo Unit** modes.

## Supported models

iPhone 15 Pro, 15 Pro Max, 15, 15 Plus, 14 Pro, 14 Pro Max, 14, 14 Plus, 13, and SE (3rd generation), each with its own colors, storage options, and photos.

## Requirements

- Xcode (a recent version)
- iOS 16.2 or later
- iPhone only
- Swift 5

## Getting started

1. Clone the repository.
   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   cd <your-repo>
   ```
2. Open `Explore.xcodeproj` in Xcode.
3. Select your own team and a unique bundle identifier under **Signing & Capabilities**.
4. Choose an iPhone simulator or your device and press **Run**.

## Project structure

| File | What it does |
|---|---|
| `ExploreiPhoneApp.swift` | App entry point |
| `HomeView.swift` | Home menu and hero phone |
| `CompareView.swift` | Model comparison |
| `PricingView.swift` | Pricing configurator |
| `Models.swift` | Phone models, colors, storage options, specs, prices |
| `ModelPhotos.swift` | Finds the photo for a model and color, and the fade effect |
| `PhoneArt.swift` | Photo sizing and trimming, plus a drawn phone as a fallback |
| `ModelPhotos.xcassets` | Photos named `phone_<model>_<color>` |
| `IdleScreensaver.swift` | Idle detection and screen saver |
| `SettingsView.swift`, `SettingsTrigger.swift` | Hidden Settings screen and its gesture |
| `LaunchAnimation.swift` | Opening animation |
| `Theme.swift` | Colors, haptics, and shared styles |

## Customizing

- **Home phone size:** change `heroScale` in `HomeView.swift` (lower is smaller).
- **Pricing phone size:** change `widthStandard`, `widthLarge`, and `widthSE` in `ModelPhoto` (`PhoneArt.swift`).
- **Idle timing:** change `secondsBeforePrompt` and `promptSeconds` in `IdleConfig` (`IdleScreensaver.swift`).
- **Adding a photo:** add an image set to `ModelPhotos.xcassets` named `phone_<model id>_<color id>`, for example `phone_15pro_blue`. If a photo is missing, the app draws a phone instead.

## License

Add your license here. Apple's names, logos, and product images belong to Apple Inc.
