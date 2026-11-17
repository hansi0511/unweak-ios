import Testing
import UIKit
@testable import Unweak

@MainActor
struct FontTests {
    @Test func everyFontFileIsBundled() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        #expect(urls.count == AppFont.allCases.count)
    }

    @Test(arguments: AppFont.allCases)
    func fontIsAvailableAfterRegistration(_ font: AppFont) {
        _ = FontRegistry.registerOnce
        #expect(UIFont(name: font.rawValue, size: 12) != nil)
    }

    @Test func registeringTwiceIsHarmless() {
        FontRegistry.registerAll()
        FontRegistry.registerAll()
        #expect(UIFont(name: AppFont.interRegular.rawValue, size: 12) != nil)
    }
}
