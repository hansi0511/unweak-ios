import SwiftUI

/// Achievements (Design V2, `V2-Erfolge`): "4 of 12 done" and all achievements in three
/// columns, achieved ones first; open ones are dimmed. An achieved tile opens Share.
struct AchievementsScreen: View {
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @State private var shareContent: ShareContent?
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let progress = catalog.achievements.map { stats.progress(of: $0, target: reminders.weeklyTarget) }
        let achieved = progress.filter(\.isAchieved).count

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                BackButton()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Achievements")
                        .font(.grotesk(36))
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                    Text("\(achieved) of \(progress.count) done")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                }
            }

            if store.data.duelWins > 0 {
                duelWinnerBadge(store.data.duelWins)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(progress.achievedFirst, id: \.achievement.id) { item in
                    if item.isAchieved {
                        Button {
                            shareContent = .achievement(item.achievement)
                        } label: {
                            tile(item)
                        }
                        .buttonStyle(PressFeedbackStyle())
                        .accessibilityHint(Text("Share achievement"))
                    } else {
                        tile(item)
                    }
                }
            }

            if achieved > 0 {
                Text("Tap an achievement to share it.")
                    .font(.text(14))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }

    /// "Duel winner" with how often, from won duels (docs/SOCIAL.md).
    private func duelWinnerBadge(_ wins: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "rosette")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(League.gold.color)
                .accessibilityHidden(true)
            Text("Duel winner")
                .font(.textSemibold(16))
                .foregroundStyle(Theme.text)
            Spacer(minLength: 0)
            Text(verbatim: "× \(wins)")
                .font(.grotesk(22))
                .foregroundStyle(accent.color)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(League.gold.color, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Duel winner"))
        .accessibilityValue(Text("Won \(wins) times"))
    }

    private func tile(_ item: AchievementProgress) -> some View {
        VStack(spacing: 4) {
            ValueText.threshold(of: item.achievement)
                .font(.grotesk(26))
                .foregroundStyle(item.isAchieved ? accent.color : Theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(catalog: item.achievement.labelKey)
                .font(.text(13))
                .foregroundStyle(item.isAchieved ? Theme.text : Theme.textMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(item.isAchieved ? accent.color : Theme.line, lineWidth: 1))
        .opacity(item.isAchieved ? 1 : 0.5)
        .accessibilityElement(children: .combine)
        .accessibilityValue(item.isAchieved ? Text("Achieved") : Text("Open"))
    }
}

#Preview {
    NavigationStack {
        AchievementsScreen()
    }
    .previewEnvironment()
}
