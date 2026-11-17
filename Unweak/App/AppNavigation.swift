import Observation

/// App-wide navigation state: the selected tab and whether the tab bar is shown.
/// Provided by `RootView` through the environment.
@MainActor
@Observable
final class AppNavigation {
    var selectedTab: AppTab = .dashboard
    /// Hidden while a full-focus screen such as a running workout is shown.
    var isTabBarHidden = false
}
