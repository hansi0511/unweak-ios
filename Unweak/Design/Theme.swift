import SwiftUI

/// Fixed colors and layout metrics from `docs/DESIGN.md`.
/// The app is always dark; only the accent color is user-selectable (see `Accent`).
enum Theme {
    // MARK: Colors

    static let background = Color(hex: 0x07090C)
    static let surface = Color(hex: 0x0B1015)
    static let surfaceSelected = Color(hex: 0x111920)
    static let line = Color(hex: 0x1E2A33)
    static let lineStrong = Color(hex: 0x3A4954)
    static let text = Color(hex: 0xEAF2F5)
    static let textSoft = Color(hex: 0xC3CED6)
    static let textMuted = Color(hex: 0x9FB0BC)
    static let subscription = Color(hex: 0xFFB547)
    static let danger = Color(hex: 0xFF8A8A)
    /// Text and icons placed on an accent-colored surface.
    static let onAccent = Color(hex: 0x07090C)

    // MARK: Layout

    enum Layout {
        static let screenEdge: CGFloat = 20
        static let blockSpacing: CGFloat = 24
        static let blockSpacingTight: CGFloat = 18
        static let tabBarHeight: CGFloat = 76
        static let minTouchTarget: CGFloat = 44
        static let primaryButtonHeight: CGFloat = 60
        static let selectHeight: CGFloat = 44
        static let gridSpacing: CGFloat = 24
        static let cornerMarkLength: CGFloat = 18
        static let cornerMarkWidth: CGFloat = 2
    }

    /// Glow strength: 40 % opacity, radius between 10 and 28.
    enum Glow {
        static let opacity: Double = 0.4
        static let small: CGFloat = 10
        static let medium: CGFloat = 18
        static let large: CGFloat = 28
    }
}

/// Red, green and blue components (0...1) of a 24-bit hex color.
struct RGB: Equatable {
    let red: Double
    let green: Double
    let blue: Double

    init(hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }
}

extension Color {
    /// Creates an sRGB color from a 24-bit hex value such as `0xC6F24E`.
    init(hex: UInt32) {
        let rgb = RGB(hex: hex)
        self.init(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: 1)
    }
}

extension View {
    /// Accent glow. Use only on primary buttons, active bars and Sticky Man.
    func glow(_ color: Color, radius: CGFloat = Theme.Glow.medium) -> some View {
        shadow(color: color.opacity(Theme.Glow.opacity), radius: radius)
    }
}
