import Foundation
import Observation

/// Screens pushed in the journal tab.
enum JournalRoute: Hashable {
    /// An existing entry.
    case entry(JournalEntry.ID)
    /// A new, not yet saved entry for a plan, added with the plus button.
    case newEntry(planID: String)
}

/// App-wide navigation state: the selected tab, the journal path and whether the
/// tab bar is shown. Provided by `RootView` through the environment.
@MainActor
@Observable
final class AppNavigation {
    var selectedTab: AppTab = .me
    var journalPath: [JournalRoute] = []
    /// Area shown in the workouts tab.
    var workoutsArea: WorkoutsArea = .skills
    /// Changing it rebuilds the workouts stack, so that it starts at its root again.
    private(set) var workoutsStackID = UUID()
    /// Hidden while a full-focus screen such as a running workout is shown.
    var isTabBarHidden = false

    /// Switches to the workouts tab, back at its root, with the skills area shown.
    func showSkills() {
        workoutsArea = .skills
        workoutsStackID = UUID()
        selectedTab = .workouts
    }

    /// Switches to the journal and opens the given entry.
    func showJournalEntry(_ id: JournalEntry.ID) {
        journalPath = [.entry(id)]
        selectedTab = .journal
    }
}
