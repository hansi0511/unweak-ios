import SwiftUI

/// "Me" tab: the avatar, the weekly target, the skill being learned (Pro) and the next
/// workout. Free: a teaser for the skills takes the place of the skill.
struct MeScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingPaywall = false
    @State private var shareContent: ShareContent?
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let target = reminders.weeklyTarget
        let stats = JournalStats(entries: store.entries)
        let week = stats.week(containing: .now, target: target)
        let streak = stats.streak(at: .now, target: target)
        let unlocks = AvatarUnlocks(stats: stats, catalog: catalog, weeklyTarget: target) {
            store.reachedStages(of: $0)
        }
        let goal = activeGoal

        ScreenContainer {
            header(week: week, streak: streak)

            AvatarCard(style: store.data.avatar, unlocks: unlocks, catalog: catalog)

            Card {
                WeekTargetPanel(week: week, streak: streak)
            }

            if let goal {
                SkillPanel(
                    progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                    catalog: catalog
                ) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.markStageReached(of: goal)
                    }
                }
            }

            // Pro: from the skill being learned. Free: from the free workouts.
            if let plan = stats.nextWorkout(in: catalog, access: subscription.access, preferring: goal?.plans ?? []) {
                NavigationLink {
                    TrainingScreen(plan: plan, catalog: catalog)
                } label: {
                    NextWorkoutCard(plan: plan)
                }
                .buttonStyle(PressFeedbackStyle())
            }

            if goal == nil {
                // Free version: skills are Pro, so a teaser takes the place of the skill.
                Button {
                    isShowingPaywall = true
                } label: {
                    SkillTeaser()
                }
                .buttonStyle(PressFeedbackStyle())
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }

    /// The active skill; none in the free version (skills are Pro).
    private var activeGoal: Goal? {
        guard subscription.access.canUseSkills else { return nil }
        let id = store.data.activeGoalID
        return catalog.goals.first { $0.id == id } ?? catalog.goals.first
    }

    private func header(week: WeekSummary, streak: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Me")
                .font(.screenTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            if week.workouts > 0 || streak > 0 {
                IconButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share week") {
                    shareContent = .streakCard(week: week, weeks: streak)
                }
            }
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

/// The avatar with its body name, what comes next and "Customize".
private struct AvatarCard: View {
    let style: AvatarStyle
    let unlocks: AvatarUnlocks
    let catalog: Catalog

    var body: some View {
        let current = unlocks.body(for: style)
        HStack(alignment: .center, spacing: 16) {
            AvatarView(style: style, body: current, extra: unlocks.extra(for: style))
                .frame(width: 132, height: 132)
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel("Your avatar")
                Text(current.name)
                    .font(.metric)
                    .foregroundStyle(Theme.text)
                nextText
                    .font(.text(13))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
                NavigationLink {
                    AvatarEditorScreen(catalog: catalog)
                } label: {
                    ChipLabel("Customize", systemImage: "paintbrush.pointed")
                }
                .buttonStyle(PressFeedbackStyle())
            }
            Spacer(minLength: 0)
        }
    }

    /// How the avatar grows next.
    private var nextText: Text {
        guard let next = unlocks.nextBody else { return Text("You are a legend!") }
        if let missing = unlocks.workoutsToNextBody {
            return Text("\(missing) more workouts to \(Text(next.name))")
        }
        return Text("Master a skill to become a legend")
    }
}

/// This week against the weekly target: count, one segment per planned workout,
/// the streak and how many workouts are still missing.
private struct WeekTargetPanel: View {
    @Environment(\.accent) private var accent
    let week: WeekSummary
    let streak: Int

    private var remaining: Int { max(0, week.target - week.workouts) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                MonoLabel("This week")
                if streak > 0 {
                    MonoLabel("Streak \(streak) weeks", color: Theme.text, bold: true)
                }
            }
            Text("\(week.workouts) / \(week.target) workouts")
                .font(.metric)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            SegmentedProgress(total: week.target, filled: week.workouts, height: 8, label: "Weekly target")
            Group {
                if remaining == 0 {
                    Text("Weekly target reached")
                        .foregroundStyle(accent.color)
                } else {
                    Text("\(remaining) to go for your weekly target")
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .font(.mono)
            .tracking(1)
            .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The skill the user works towards: name with "Change", the current stage ("Now")
/// next to the skill itself ("Goal"), both animated, then the stage segments and
/// "Stage reached".
private struct SkillPanel: View {
    @Environment(\.accent) private var accent
    let progress: GoalProgress
    let catalog: Catalog
    let onStageReached: () -> Void

    private var goal: Goal { progress.goal }

    var body: some View {
        HUDPanel {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    NavigationLink {
                        GoalPickerScreen(catalog: catalog)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Your skill")
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
                        .accessibilityAddTraits(.isHeader)
                }

                HStack(alignment: .top, spacing: 8) {
                    column(label: "Now", animation: catalog.currentAnimation(for: progress)) {
                        nowText
                    }
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textMuted)
                        .padding(.top, 50)
                        .accessibilityHidden(true)
                    column(label: "Goal", animation: catalog.animation(for: goal)) {
                        goalText
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

    /// Animation with a small label above and a caption below.
    private func column(label: LocalizedStringKey, animation: StickyAnimation, @ViewBuilder caption: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            MonoLabel(label)
            StickyManView(animation)
                .frame(height: 110)
                .frame(maxWidth: .infinity)
            caption()
                .font(.text(13))
                .foregroundStyle(Theme.textSoft)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// The stage worked on, or the best time.
    private var nowText: Text {
        switch goal.kind {
        case .stages:
            if let index = progress.currentStageIndex, goal.stageKeys.indices.contains(index) {
                return Text(catalog: goal.stageKeys[index])
            }
            return Text(catalog: goal.nameKey)
        case .time:
            if let best = progress.bestSeconds {
                return Text("Best time \(ValueText.seconds(best))")
            }
            return Text("No time yet")
        }
    }

    /// The final stage, or the target time.
    private var goalText: Text {
        switch goal.kind {
        case .stages:
            if let last = goal.stageKeys.last {
                return Text(catalog: last)
            }
            return Text(catalog: goal.nameKey)
        case .time(let target):
            return Text("Target \(ValueText.seconds(target))")
        }
    }

    private var progressLine: Text {
        switch goal.kind {
        case .stages(let count):
            if progress.isComplete { return Text("All stages reached") }
            let remaining = max(0, count - progress.reachedStages)
            return Text("Stage \(progress.reachedStages) / \(count) · \(remaining) to go")
        case .time:
            return progress.isComplete ? Text("Goal reached") : Text("Keep going")
        }
    }
}

/// Free version: invites to the skills, which need Pro.
private struct SkillTeaser: View {
    var body: some View {
        HUDPanel {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        MonoLabel("Skills")
                        Badge(kind: .subscription)
                    }
                    Text("Reach your first skill")
                        .font(.metric)
                        .foregroundStyle(Theme.text)
                    Text("Choose a skill like the front lever and get the workouts that build it.")
                        .font(.text(13))
                        .foregroundStyle(Theme.textSoft)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                StickyManView(.frontLever)
                    .frame(width: 110, height: 110)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
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
                plan.title
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

#Preview {
    NavigationStack {
        MeScreen()
    }
    .previewEnvironment()
}

#Preview("Pro") {
    NavigationStack {
        MeScreen()
    }
    // Set before previewEnvironment(): the innermost value wins.
    .environment(SubscriptionStore.preview(isPro: true))
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        MeScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
