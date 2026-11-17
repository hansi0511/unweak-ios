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
    var selectedTab: AppTab = .dashboard
    var journalPath: [JournalRoute] = []
    /// Hidden while a full-focus screen such as a running workout is shown.
    var isTabBarHidden = false

    /// Switches to the journal and opens the given entry.
    func showJournalEntry(_ id: JournalEntry.ID) {
        journalPath = [.entry(id)]
        selectedTab = .journal
    }
}
