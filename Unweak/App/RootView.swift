import SwiftUI

/// The three tabs of the bottom navigation.
enum AppTab: CaseIterable, Identifiable {
    case dashboard
    case workouts
    case journal

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .dashboard: "Dashboard"
        case .workouts: "Workouts"
        case .journal: "Journal"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .workouts: "figure.strengthtraining.functional"
        case .journal: "list.bullet.rectangle"
        }
    }
}

/// Hosts the three tabs and the custom HUD tab bar. Each tab keeps its own
/// navigation stack alive while another tab is shown.
struct RootView: View {
    @AppStorage(Accent.storageKey) private var accent: Accent = .default
    @State private var selection: AppTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(AppTab.allCases) { tab in
                    let isActive = tab == selection
                    NavigationStack {
                        content(for: tab)
                    }
                    .opacity(isActive ? 1 : 0)
                    .allowsHitTesting(isActive)
                    .accessibilityHidden(!isActive)
                }
            }
            HUDTabBar(selection: $selection)
        }
        .background(Theme.background.ignoresSafeArea())
        .environment(\.accent, accent)
        .tint(accent.color)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .dashboard: DashboardScreen()
        case .workouts: WorkoutsScreen()
        case .journal: JournalScreen()
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
                    .font(.monoBold)
                    .tracking(1)
                    .textCase(.uppercase)
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
