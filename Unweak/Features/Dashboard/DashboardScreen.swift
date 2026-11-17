import SwiftUI

/// Dashboard tab: this week, the active goal, the next workout and achievements.
struct DashboardScreen: View {
    @Environment(UserDataStore.self) private var store
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let target = WeeklyTarget.current()
        let stats = JournalStats(entries: store.entries)
        let week = stats.week(containing: .now, target: target)
        let streak = stats.streak(at: .now, target: target)

        ScreenContainer {
            header(week: week, streak: streak)
            WeekBars(week: week)

            if let goal = activeGoal {
                GoalPanel(
                    progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                    catalog: catalog
                ) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.markStageReached(of: goal)
                    }
                }
            }

            if let plan = stats.nextWorkout(in: catalog) {
                NavigationLink {
                    TrainingScreen(plan: plan, catalog: catalog)
                } label: {
                    NextWorkoutCard(plan: plan)
                }
                .buttonStyle(PressFeedbackStyle())
            }

            NavigationLink {
                ComingLaterScreen(title: "Create workout")
            } label: {
                ChipLabel("Create custom workout", systemImage: "plus", style: .dashed, expands: true)
            }
            .buttonStyle(PressFeedbackStyle())

            AchievementsSection(
                progress: catalog.achievements.map { stats.progress(of: $0, target: target) }
            )
        }
    }

    private var activeGoal: Goal? {
        let id = store.data.activeGoalID
        return catalog.goals.first { $0.id == id } ?? catalog.goals.first { $0.isFree }
    }

    private func header(week: WeekSummary, streak: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    MonoLabel("This week")
                    if streak > 0 {
                        MonoLabel("Streak \(streak) weeks", color: Theme.text, bold: true)
                    }
                }
                Text("\(week.workouts) / \(week.target) workouts")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 0)
            NavigationLink {
                SettingsScreen()
            } label: {
                IconButtonLabel(systemImage: "slider.horizontal.3")
            }
            .buttonStyle(PressFeedbackStyle())
            .accessibilityLabel(Text("Settings"))
        }
    }
}

/// Seven day bars, Monday to Sunday: trained in the accent color, today bright, else dark.
private struct WeekBars: View {
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let week: WeekSummary

    var body: some View {
        HStack(spacing: 6) {
            ForEach(week.days, id: \.date) { day in
                VStack(spacing: 6) {
                    Rectangle()
                        .fill(color(for: day))
                        .frame(height: 8)
                        .glow(day.trained ? accent.color : .clear, radius: Theme.Glow.small)
                    Text(verbatim: day.date.formatted(.dateTime.weekday(.short).locale(locale)))
                        .font(.mono)
                        .textCase(.uppercase)
                        .foregroundStyle(day.isToday ? Theme.text : Theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: day.date.formatted(.dateTime.weekday(.wide).locale(locale))))
                .accessibilityValue(day.trained ? Text("Trained") : Text("Not trained"))
            }
        }
    }

    private func color(for day: WeekDay) -> Color {
        if day.trained { return accent.color }
        return day.isToday ? Theme.textSoft : Theme.line
    }
}

/// The active goal: name, state, animation, stage segments and "Stage reached".
private struct GoalPanel: View {
    @Environment(\.accent) private var accent
    let progress: GoalProgress
    let catalog: Catalog
    let onStageReached: () -> Void

    private var goal: Goal { progress.goal }

    var body: some View {
        HUDPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink {
                            ComingLaterScreen(title: "Choose goal")
                        } label: {
                            HStack(spacing: 4) {
                                Text("Next goal")
                                Text(verbatim: "·")
                                Text("Change")
                            }
                            .font(.monoBold)
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(accent.color)
                            .frame(minHeight: Theme.Layout.minTouchTarget)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PressFeedbackStyle())

                        Text(catalog: goal.nameKey)
                            .font(.metric)
                            .foregroundStyle(Theme.text)
                        stateText
                            .font(.text(15))
                            .foregroundStyle(Theme.textSoft)
                    }
                    Spacer(minLength: 0)
                    if let exercise = catalog.exercise(goal.exercise) {
                        StickyManView(exercise.animation)
                            .frame(width: 120, height: 120)
                    }
                }

                SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, label: "Goal progress")

                HStack(spacing: 12) {
                    progressLine
                        .font(.mono)
                        .tracking(1)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.textMuted)
                    Spacer(minLength: 0)
                    if case .stages = goal.kind, !progress.isComplete {
                        Button(action: onStageReached) {
                            ChipLabel("Stage reached", systemImage: "checkmark", style: .dashed)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }
        }
    }

    private var stateText: Text {
        switch goal.kind {
        case .stages:
            if let key = progress.nextStageKey {
                return Text("Next stage: \(Text(catalog: key))")
            }
            return Text("All stages reached")
        case .time(let target):
            if let best = progress.bestSeconds {
                return Text("Best time \(ValueText.seconds(best)) of \(ValueText.seconds(target))")
            }
            return Text("Target \(ValueText.seconds(target)) · no time yet")
        }
    }

    private var progressLine: Text {
        switch goal.kind {
        case .stages(let count):
            let remaining = max(0, count - progress.reachedStages)
            return Text("Stage \(progress.reachedStages) / \(count) · \(remaining) to go")
        case .time:
            return progress.isComplete ? Text("Goal reached") : Text("Keep going")
        }
    }
}

/// Accent card with the suggested next workout.
private struct NextWorkoutCard: View {
    @Environment(\.accent) private var accent
    let plan: WorkoutPlan

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                MonoLabel("Next workout", color: Theme.onAccent, bold: true)
                Text(catalog: plan.nameKey)
                    .font(.buttonTitle)
                    .multilineTextAlignment(.leading)
                ValueText.minutes(plan.estimatedSeconds)
                    .font(.mono)
            }
            Spacer(minLength: 0)
            Image(systemName: "play.fill")
                .font(.system(size: 18, weight: .bold))
                .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                .overlay(Rectangle().strokeBorder(Theme.onAccent, lineWidth: 2))
                .accessibilityHidden(true)
        }
        .foregroundStyle(Theme.onAccent)
        .padding(16)
        .background(accent.color)
        .glow(accent.color, radius: Theme.Glow.medium)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// "4 / 12" and four tiles: achieved ones first, then the next open ones.
private struct AchievementsSection: View {
    @Environment(\.accent) private var accent
    let progress: [AchievementProgress]

    private var achievedCount: Int { progress.filter(\.isAchieved).count }

    private var shown: [AchievementProgress] {
        let achieved = progress.filter(\.isAchieved).suffix(4)
        let open = progress.filter { !$0.isAchieved }.prefix(4 - achieved.count)
        return Array(achieved) + Array(open)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MonoLabel("Achievements")
                Spacer()
                MonoLabel(verbatim: "\(achievedCount) / \(progress.count)", color: Theme.text, bold: true)
                    .accessibilityLabel(Text("\(achievedCount) of \(progress.count)"))
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(shown, id: \.achievement.id) { item in
                    tile(item)
                }
            }
        }
    }

    private func tile(_ item: AchievementProgress) -> some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 4) {
                ValueText.threshold(of: item.achievement)
                    .font(.metric)
                    .foregroundStyle(item.isAchieved ? accent.color : Theme.textMuted)
                Text(catalog: item.achievement.labelKey)
                    .font(.mono)
                    .textCase(.uppercase)
                    .foregroundStyle(item.isAchieved ? Theme.text : Theme.textMuted)
                    .lineLimit(2)
            }
        }
        .opacity(item.isAchieved ? 1 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityValue(item.isAchieved ? Text("Achieved") : Text("Open"))
    }
}

#Preview {
    NavigationStack {
        DashboardScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        DashboardScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
