import SwiftUI

/// "Me" tab: the avatar, the weekly target, the skill being learned (Pro) and the next
/// workout. Free: a teaser for the skills takes the place of the skill.
struct MeScreen: View {
    @Environment(\.accent) private var accent
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
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
        let goals = activeGoals

        ScreenContainer {
            header(week: week, streak: streak)

            AvatarStage(
                style: store.data.avatar,
                unlocks: unlocks,
                week: week,
                streak: streak,
                // Pro: from the skills being learned. Free: from the free workouts.
                nextPlan: stats.nextWorkout(in: catalog, access: subscription.access, preferring: goals.flatMap(\.plans)),
                catalog: catalog
            )

            if subscription.access.canUseSkills {
                SkillsHeader {
                    navigation?.showSkills()
                }
                if goals.isEmpty {
                    Button {
                        navigation?.showSkills()
                    } label: {
                        ChipLabel("Choose skills", systemImage: "plus", style: .dashed, expands: true)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
                ForEach(goals) { goal in
                    SkillPanel(
                        progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                        catalog: catalog
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            store.markStageReached(of: goal)
                        }
                    }
                }
            } else {
                // Free version: skills are Pro, so a teaser takes the place of the skills.
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

    /// The skills being learned; none in the free version (skills are Pro).
    private var activeGoals: [Goal] {
        guard subscription.access.canUseSkills else { return [] }
        return store.activeGoals(in: catalog)
    }

    private func header(week: WeekSummary, streak: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // The title opens the Me area: level, avatar and settings.
            NavigationLink {
                ProfileScreen(catalog: catalog)
            } label: {
                HStack(spacing: 8) {
                    Text("Me")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.text)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent.color)
                }
                .frame(minHeight: Theme.Layout.minTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .accessibilityAddTraits(.isHeader)
            .accessibilityHint(Text("Level, avatar and settings"))
            Spacer(minLength: 0)
            if week.workouts > 0 || streak > 0 {
                IconButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share week") {
                    shareContent = .streakCard(week: week, weeks: streak)
                }
            }
        }
    }
}

/// The avatar large in the middle, framed by a ring that fills with the workouts of
/// this week; below it the week in short, the name of the body and the next workout.
private struct AvatarStage: View {
    let style: AvatarStyle
    let unlocks: AvatarUnlocks
    let week: WeekSummary
    let streak: Int
    let nextPlan: WorkoutPlan?
    let catalog: Catalog

    var body: some View {
        let current = unlocks.body(for: style)

        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(style.backgroundColor)
                    .padding(16)
                WeekRing(total: week.target, filled: week.workouts)
                AvatarView(style: style, body: current, extra: unlocks.extra(for: style), framed: false)
                    .padding(36)
            }
            .frame(maxWidth: 280)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)

            HStack(spacing: 6) {
                Text("\(week.workouts) / \(week.target) this week")
                if streak > 0 {
                    Text(verbatim: "·")
                    Text("Streak \(streak) weeks")
                }
            }
            .foregroundStyle(Theme.textSoft)
            .font(.mono)
            .tracking(1)
            .textCase(.uppercase)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            Text(current.name)
                .font(.metric)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity)

            if let nextPlan {
                NavigationLink {
                    TrainingScreen(plan: nextPlan, catalog: catalog)
                } label: {
                    NextWorkoutBar(plan: nextPlan)
                }
                .buttonStyle(PressFeedbackStyle())
            }
        }
    }
}

/// One arc per workout of the weekly target around the avatar; done ones in the accent color.
private struct WeekRing: View {
    @Environment(\.accent) private var accent
    let total: Int
    let filled: Int

    /// Gap between two arcs, as a share of the full circle.
    private static let gap = 0.015
    private static let lineWidth: CGFloat = 6

    var body: some View {
        let count = max(total, 1)
        let done = min(max(filled, 0), count)
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                let start = Double(index) / Double(count) + Self.gap / 2
                let end = Double(index + 1) / Double(count) - Self.gap / 2
                let isDone = index < done
                Circle()
                    .trim(from: start, to: end)
                    .stroke(isDone ? accent.color : Theme.line, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .butt))
                    .glow(isDone ? accent.color : .clear, radius: Theme.Glow.small)
            }
        }
        .rotationEffect(.degrees(-90))
        .padding(Self.lineWidth / 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Weekly target"))
        .accessibilityValue(Text("\(done) of \(count)"))
    }
}

/// "Your skills" with "Edit", which opens the skills in the workouts tab.
private struct SkillsHeader: View {
    @Environment(\.accent) private var accent
    let onEdit: () -> Void

    var body: some View {
        HStack {
            MonoLabel("Your skills")
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(action: onEdit) {
                Text("Edit")
                    .font(.monoBold)
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(accent.color)
                    .frame(minWidth: Theme.Layout.minTouchTarget, minHeight: Theme.Layout.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .accessibilityLabel(Text("Choose skills"))
        }
    }
}

/// One skill the user works towards: name and animations open the skill page; the current stage ("Now")
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
                // Name and animations open the skill's page with its description.
                NavigationLink {
                    SkillScreen(goal: goal, catalog: catalog)
                } label: {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Text(catalog: goal.nameKey)
                                .font(.metric)
                                .foregroundStyle(Theme.text)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(accent.color)
                                .accessibilityHidden(true)
                        }
                        .frame(minHeight: Theme.Layout.minTouchTarget)
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
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityHint(Text("Shows the skill with its stages"))

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

/// Slim bar with the suggested next workout: play symbol, label, name and duration.
private struct NextWorkoutBar: View {
    @Environment(\.accent) private var accent
    let plan: WorkoutPlan

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.onAccent)
                .frame(width: 36, height: 36)
                .background(accent.color)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                MonoLabel("Next workout")
                plan.title
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            ValueText.minutes(plan.estimatedSeconds)
                .font(.mono)
                .foregroundStyle(Theme.textMuted)
        }
        .padding(10)
        .frame(minHeight: Theme.Layout.minTouchTarget)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
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
