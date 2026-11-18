import SwiftUI

/// The three tabs of the bottom navigation.
enum AppTab: CaseIterable, Identifiable {
    case me
    case workouts
    case journal

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .me: "Me"
        case .workouts: "Workouts"
        case .journal: "Journey"
        }
    }

    var systemImage: String {
        switch self {
        case .me: "person"
        case .workouts: "figure.strengthtraining.functional"
        case .journal: "map"
        }
    }
}

/// Hosts the three tabs and the custom HUD tab bar. Each tab keeps its own
/// navigation stack alive while another tab is shown.
struct RootView: View {
    @AppStorage(Accent.storageKey) private var accent: Accent = .default
    @AppStorage(AppLanguage.storageKey) private var storedLanguage = ""
    @State private var navigation = AppNavigation()
    @State private var store = UserDataStore(fileURL: UserDataStore.defaultFileURL)
    @State private var reminders = ReminderSettings()
    @State private var subscription = SubscriptionStore()

    private var language: AppLanguage { AppLanguage.resolve(stored: storedLanguage) }

    var body: some View {
        @Bindable var navigation = navigation
        VStack(spacing: 0) {
            ZStack {
                ForEach(AppTab.allCases) { tab in
                    let isActive = tab == navigation.selectedTab
                    stack(for: tab, journalPath: $navigation.journalPath)
                        .opacity(isActive ? 1 : 0)
                        .allowsHitTesting(isActive)
                        .accessibilityHidden(!isActive)
                }
            }
            if !navigation.isTabBarHidden {
                HUDTabBar(selection: $navigation.selectedTab)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .environment(navigation)
        .environment(store)
        .environment(reminders)
        .environment(subscription)
        .environment(\.accent, accent)
        .environment(\.locale, language.locale)
        .tint(accent.color)
        .preferredColorScheme(.dark)
        .task {
            // Re-apply the reminders at launch, e.g. after the system cleared them.
            await ReminderScheduler.apply(reminders.schedule, language: language)
        }
    }

    /// The journal stack is driven by a path so that a finished workout can open its entry.
    @ViewBuilder
    private func stack(for tab: AppTab, journalPath: Binding<[JournalRoute]>) -> some View {
        switch tab {
        case .me: NavigationStack { MeScreen() }
        case .workouts: NavigationStack { WorkoutsScreen() }.id(navigation.workoutsStackID)
        case .journal: NavigationStack(path: journalPath) { JournalScreen() }
        }
    }
}

/// Bottom navigation: 76 pt high, accent bar and color on the selected tab.
struct HUDTabBar: View {
    @Environment(\.accent) private var accent
    @Binding private var selection: AppTab

    init(selection: Binding<AppTab>) {
        _selection = selection
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .frame(height: Theme.Layout.tabBarHeight)
        .background(Theme.surface.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.line).frame(height: 1)
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(height: 24)
                    .accessibilityHidden(true)
                Text(tab.title)
                    .font(.textSemibold(12))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? accent.color : Theme.textMuted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                if isSelected {
                    Rectangle()
                        .fill(accent.color)
                        .frame(width: 32, height: 2)
                        .glow(accent.color, radius: Theme.Glow.small)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    RootView()
}

#Preview("German") {
    RootView()
        .environment(\.locale, Locale(identifier: "de"))
}
