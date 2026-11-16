import Testing
@testable import Unweak

struct AccentTests {
    @Test func defaultIsLime() {
        #expect(Accent.default == .lime)
    }

    @Test func offersSixColors() {
        #expect(Accent.allCases.count == 6)
    }

    @Test func hexValuesMatchDesign() {
        #expect(Accent.lime.hex == 0xC6F24E)
        #expect(Accent.cyan.hex == 0x5CE1FF)
        #expect(Accent.orange.hex == 0xFFB547)
        #expect(Accent.red.hex == 0xFF7566)
        #expect(Accent.pink.hex == 0xFF7AB8)
        #expect(Accent.violet.hex == 0xA995FF)
    }

    @Test(arguments: Accent.allCases)
    func storedValueRoundTrips(_ accent: Accent) {
        #expect(Accent(storedValue: accent.rawValue) == accent)
    }

    @Test(arguments: [nil, "", "teal", "Lime"] as [String?])
    func missingOrUnknownStoredValueFallsBackToDefault(_ stored: String?) {
        #expect(Accent(storedValue: stored) == .default)
    }
}

struct RGBTests {
    @Test func splitsHexIntoComponents() {
        let rgb = RGB(hex: 0xC6F24E)
        #expect(rgb.red == 198.0 / 255)
        #expect(rgb.green == 242.0 / 255)
        #expect(rgb.blue == 78.0 / 255)
    }

    @Test func blackAndWhite() {
        #expect(RGB(hex: 0x000000) == RGB(hex: 0))
        let white = RGB(hex: 0xFFFFFF)
        #expect(white.red == 1 && white.green == 1 && white.blue == 1)
    }
}
