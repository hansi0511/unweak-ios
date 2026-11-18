import CoreText
import SwiftUI

/// Bundled font files (SIL Open Font License), identified by their PostScript names.
enum AppFont: String, CaseIterable, Sendable {
    // The Google Fonts static instance of Space Grotesk Bold carries this PostScript name.
    case spaceGroteskBold = "SpaceGroteskLight-Bold"
    case interRegular = "Inter-Regular"
    case interSemiBold = "Inter-SemiBold"
    case monoMedium = "JetBrainsMono-Medium"
    case monoBold = "JetBrainsMono-Bold"
}

enum FontRegistry {
    /// Registers the bundled fonts on first access. Touched by every `Font` style below,
    /// so fonts are available in the app, in Xcode Previews and in tests.
    static let registerOnce: Void = registerAll()

    /// Registers every bundled `.ttf` for this process. Safe to call more than once:
    /// fonts that are already registered are skipped by Core Text.
    static func registerAll(in bundle: Bundle = .main) {
        let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls {
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

/// Text styles from `docs/DESIGN.md`. All scale with Dynamic Type.
extension Font {
    private static func app(_ font: AppFont, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        _ = FontRegistry.registerOnce
        return .custom(font.rawValue, size: size, relativeTo: style)
    }

    /// Space Grotesk Bold 32 – screen titles.
    static var screenTitle: Font { app(.spaceGroteskBold, size: 32, relativeTo: .largeTitle) }
    /// Space Grotesk Bold 40 – exercise names.
    static var exerciseTitle: Font { app(.spaceGroteskBold, size: 40, relativeTo: .largeTitle) }
    /// Space Grotesk Bold 22 – metrics and large numbers.
    static var metric: Font { app(.spaceGroteskBold, size: 22, relativeTo: .title2) }
    /// Space Grotesk Bold 18 – primary button titles.
    static var buttonTitle: Font { app(.spaceGroteskBold, size: 18, relativeTo: .headline) }
    /// Space Grotesk Bold in any size, e.g. 26 to 28 for card and screen headlines in V2.
    static func grotesk(_ size: CGFloat) -> Font {
        app(.spaceGroteskBold, size: size, relativeTo: size >= 24 ? .title : .headline)
    }

    /// Inter Regular, 13 to 17 – body text and lists.
    static func text(_ size: CGFloat = 15) -> Font {
        app(.interRegular, size: size, relativeTo: .body)
    }

    /// Inter Semibold, 13 to 17 – emphasized body text and list titles.
    static func textSemibold(_ size: CGFloat = 15) -> Font {
        app(.interSemiBold, size: size, relativeTo: .body)
    }

    /// Fixed size, not scaled by Dynamic Type. Only for images with a fixed layout,
    /// such as the share cards.
    static func fixed(_ font: AppFont, size: CGFloat) -> Font {
        _ = FontRegistry.registerOnce
        return .custom(font.rawValue, fixedSize: size)
    }

    /// JetBrains Mono Medium 12 – labels and metadata (use with `MonoLabel`).
    static var mono: Font { app(.monoMedium, size: 12, relativeTo: .caption) }
    /// JetBrains Mono Bold 12 – badges and secondary button titles.
    static var monoBold: Font { app(.monoBold, size: 12, relativeTo: .caption) }
}
