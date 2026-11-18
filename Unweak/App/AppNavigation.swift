import Foundation
import Observation

/// Screens pushed in the journal tab.
enum JournalRoute: Hashable {
    /// An existing entry.
    case entry(JournalEntry.ID)
    /// A new, not yet saved entry for a plan, added with the plus button.
    case newEntry(planID: String)
}

/// Screens pushed in the workouts tab.
enum WorkoutsRoute: Hashable {
    case skills
    /// The workouts of one area (push, pull, legs, core).
    case area(ExerciseCategory)
}

/// App-wide navigation state: the selected tab, the workouts and journal paths and whether the
/// tab bar is shown. Provided by `RootView` through the environment.
@MainActor
@Observable
final class AppNavigation {
    var selectedTab: AppTab = .me
    var journalPath: [JournalRoute] = []
    var workoutsPath: [WorkoutsRoute] = []
    /// Hidden while a full-focus screen such as a running workout is shown.
    var isTabBarHidden = false

    /// Switches to the workouts tab and shows the skills, with nothing else on the stack.
    func showSkills() {
        workoutsPath = [.skills]
        selectedTab = .workouts
    }

    /// Switches to the journal and opens the given entry.
    func showJournalEntry(_ id: JournalEntry.ID) {
        journalPath = [.entry(id)]
        selectedTab = .journal
    }
}
