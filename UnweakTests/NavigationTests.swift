import Foundation
import Testing
@testable import Unweak

@MainActor
struct NavigationTests {
    @Test func showSkillsOpensTheSkillsAreaAtItsRoot() {
        let navigation = AppNavigation()
        navigation.workoutsArea = .workouts
        let before = navigation.workoutsStackID

        navigation.showSkills()

        #expect(navigation.selectedTab == .workouts)
        #expect(navigation.workoutsArea == .skills)
        // A new ID rebuilds the workouts stack, so pushed screens are gone.
        #expect(navigation.workoutsStackID != before)
    }

    @Test func showJournalEntryOpensTheEntry() {
        let navigation = AppNavigation()
        let id = UUID()
        navigation.showJournalEntry(id)
        #expect(navigation.selectedTab == .journal)
        #expect(navigation.journalPath == [.entry(id)])
    }
}
