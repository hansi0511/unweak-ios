import Foundation
import Testing
@testable import Unweak

@MainActor
struct NavigationTests {
    @Test func showSkillsOpensTheSkillsAreaAtItsRoot() {
        let navigation = AppNavigation()
        navigation.workoutsPath = [.area(.pull)]

        navigation.showSkills()

        #expect(navigation.selectedTab == .workouts)
        // Only the skills are on the stack; screens pushed before are gone.
        #expect(navigation.workoutsPath == [.skills])
    }
}
