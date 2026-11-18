import SwiftUI

/// A running duel (`V2-Duell`): days left, the question, both avatars facing each other
/// (the opponent mirrored) with their scores, one bar per day for each side, the prize,
/// "Start workout" and "Start a new duel".
struct DuelScreen: View {
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(LeagueStore.self) private var league
    @State private var isChallenging = false
    let duelID: String
    private let catalog: Catalog

    init(duelID: String, catalog: Catalog = .main) {
        self.duelID = duelID
        self.catalog = catalog
    }

    var body: some View {
        let now = Date.now
        ScreenContainer {
            if let duel = league.duels.first(where: { $0.id == duelID }) {
                content(duel, now: now)
            } else {
                BackButton()
                Text("This duel has ended.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
            }
        }
        .sheet(isPresented: $isChallenging) {
            ChallengeScreen()
        }
    }

    @ViewBuilder
    private func content(_ duel: Duel, now: Date) -> some View {
        let mine = duel.mySide(entries: store.entries, stageDates: store.data.stageReachedDates)
        let theirs = duel.opponentSide
        let me = LeagueAvatar.mine(store: store, catalog: catalog, weeklyTarget: reminders.weeklyTarget)

        HStack {
            BackButton()
            Spacer()
            DaysLeftText(days: duel.daysLeft(at: now))
                .font(.text(14))
                .foregroundStyle(Theme.textMuted)
        }

        VStack(alignment: .leading, spacing: 6) {
            Text("Duel")
                .font(.grotesk(36))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            Text(duel.kind.question)
                .font(.text(16))
                .foregroundStyle(Theme.textSoft)
        }

        HStack(alignment: .center, spacing: 6) {
            side(avatar: me, name: Text("You"), score: score(mine.score, kind: duel.kind), isMe: true)
            Text(verbatim: "VS")
                .font(.grotesk(20))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
            side(avatar: duel.opponent.avatar, name: Text(verbatim: duel.opponent.name), score: score(theirs.score, kind: duel.kind), isMe: false)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))

        VStack(spacing: 10) {
            dayBars(Text("You"), days: mine.days, color: accent.color, duel: duel, now: now)
            dayBars(Text(verbatim: duel.opponent.name), days: theirs.days, color: duel.opponent.avatar.style.color.color, duel: duel, now: now)
            HStack(spacing: 12) {
                Color.clear.frame(width: 70, height: 1)
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(verbatim: weekdayName(index, from: duel.start))
                            .font(.text(12))
                            .foregroundStyle(Theme.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .accessibilityHidden(true)
        }

        HStack(spacing: 12) {
            Image(systemName: "rosette")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(League.gold.color)
                .accessibilityHidden(true)
            Text("Prize: “Duel winner” badge")
                .font(.text(15))
                .foregroundStyle(Theme.text)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)

        VStack(spacing: 8) {
            if let plan = nextPlan() {
                NavigationLink {
                    TrainingScreen(plan: plan, catalog: catalog)
                } label: {
                    Text("Start workout")
                        .font(.buttonTitle)
                        .foregroundStyle(Theme.onAccent)
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
                        .background(accent.color)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .glow(accent.color, radius: Theme.Glow.medium)
            }
            Button {
                isChallenging = true
            } label: {
                Text("Start a new duel")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }

    private func side(avatar: LeagueAvatar, name: Text, score: Text, isMe: Bool) -> some View {
        VStack(spacing: 8) {
            LeagueAvatarView(avatar: avatar, size: 100, isMirrored: !isMe)
                .glow(isMe ? accent.color : .clear, radius: Theme.Glow.small)
            name
                .font(isMe ? .textSemibold(15) : .text(15))
                .foregroundStyle(isMe ? accent.color : Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            score
                .font(.grotesk(48))
                .foregroundStyle(isMe ? accent.color : Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// Workouts and stages as numbers, the plank as a time.
    private func score(_ value: Int, kind: DuelKind) -> Text {
        kind == .longestPlank ? ValueText.seconds(value) : Text(verbatim: "\(value)")
    }

    private func dayBars(_ name: Text, days: [Bool], color: Color, duel: Duel, now: Date) -> some View {
        let elapsed = Int((now.timeIntervalSince(duel.start) / 86_400).rounded(.down))
        return HStack(spacing: 12) {
            name
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
                .lineLimit(1)
                .frame(width: 70, alignment: .leading)
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    let done = index < days.count && days[index]
                    Rectangle()
                        .fill(done ? color : (index > elapsed ? Theme.surfaceSelected : Theme.line))
                        .frame(height: 10)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue(Text("\(days.filter { $0 }.count) of 7 days"))
    }

    /// Short weekday name of the duel's day `index` (0 = first day).
    private func weekdayName(_ index: Int, from start: Date) -> String {
        let calendar = Calendar.trainingWeek
        let day = calendar.date(byAdding: .day, value: index, to: start) ?? start
        return ReminderText.shortName(calendar.component(.weekday, from: day), locale: locale)
    }

    private func nextPlan() -> WorkoutPlan? {
        let goals = subscription.access.canUseSkills ? store.activeGoals(in: catalog) : []
        return JournalStats(entries: store.entries)
            .nextWorkout(in: catalog, access: subscription.access, preferring: goals.flatMap(\.plans))
    }
}

#Preview {
    NavigationStack {
        DuelScreen(duelID: "sample-duel")
    }
    .previewEnvironment()
}
