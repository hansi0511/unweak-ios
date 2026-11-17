import SwiftUI

/// The six user-selectable accent colors. Lime is the default.
enum Accent: String, CaseIterable, Identifiable, Sendable {
    case lime
    case cyan
    case orange
    case red
    case pink
    case violet

    static let `default`: Accent = .lime

    /// `UserDefaults` key used with `@AppStorage`.
    static let storageKey = "accentColor"

    /// Resolves a stored raw value, falling back to the default for missing or unknown values.
    init(storedValue: String?) {
        self = storedValue.flatMap(Accent.init(rawValue:)) ?? .default
    }

    var id: String { rawValue }

    var hex: UInt32 {
        switch self {
        case .lime: 0xC6F24E
        case .cyan: 0x5CE1FF
        case .orange: 0xFFB547
        case .red: 0xFF7566
        case .pink: 0xFF7AB8
        case .violet: 0xA995FF
        }
    }

    var color: Color { Color(hex: hex) }

    var name: LocalizedStringResource {
        switch self {
        case .lime: "Lime"
        case .cyan: "Cyan"
        case .orange: "Orange"
        case .red: "Red"
        case .pink: "Pink"
        case .violet: "Violet"
        }
    }
}

private struct AccentKey: EnvironmentKey {
    static let defaultValue: Accent = .default
}

extension EnvironmentValues {
    /// The accent color chosen by the user. Set once in `RootView`.
    var accent: Accent {
        get { self[AccentKey.self] }
        set { self[AccentKey.self] = newValue }
    }
}
