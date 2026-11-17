import SwiftUI

extension GoalProgress {
    /// Short state: "Stage 2 / 5", "Best 1:20 / 5:00" or "Target 5:00".
    var stateText: Text {
        switch goal.kind {
        case .stages(let count):
            return Text("Stage \(reachedStages) / \(count)")
        case .time(let target):
            if let bestSeconds {
                return Text("Best \(ValueText.seconds(bestSeconds)) / \(ValueText.seconds(target))")
            }
            return Text("Target \(ValueText.seconds(target))")
        }
    }
}

/// The skills area of the workouts tab: one large card per skill.
struct SkillList: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingPaywall = false
    let catalog: Catalog

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let canUseSkills = subscription.access.canUseSkills
        let activeID = canUseSkills ? (store.data.activeGoalID ?? catalog.goals.first?.id) : nil

        VStack(alignment: .leading, spacing: 10) {
            Text("Choose a skill and get the workouts that build it.")
                .font(.text(15))
                .foregroundStyle(Theme.textSoft)
            ForEach(catalog.goals) { goal in
                let card = SkillCard(
                    progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                    workoutCount: goal.plans.count,
                    isActive: goal.id == activeID,
                    isLocked: !canUseSkills,
                    catalog: catalog
                )
                if canUseSkills {
                    NavigationLink {
                        SkillScreen(goal: goal, catalog: catalog)
                    } label: {
                        card
                    }
                    .buttonStyle(PressFeedbackStyle())
                } else {
                    // Skills need Pro: the card opens the subscription page.
                    Button {
                        isShowingPaywall = true
                    } label: {
                        card
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
    }
}

/// Large skill card: Sticky Man in the skill's key pose, name, state, workouts, progress.
private struct SkillCard: View {
    let progress: GoalProgress
    let workoutCount: Int
    let isActive: Bool
    let isLocked: Bool
    let catalog: Catalog

    private var goal: Goal { progress.goal }

    var body: some View {
        HUDPanel(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 14) {
                    // Static key pose: six moving figures in one list would be restless.
                    let animation = catalog.animation(for: goal)
                    StickyFigureCanvas(figure: animation.figure(at: animation.endPoseProgress), highlighted: !isLocked)
                        .frame(width: 88, height: 88)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            if isLocked {
                                Badge(kind: .subscription)
                            } else if isActive {
                                Badge(kind: .selected)
                            }
                        }
                        Text(catalog: goal.nameKey)
                            .font(.metric)
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.leading)
                        MetaLine([progress.stateText, Text("\(workoutCount) workouts")])
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.textMuted)
                        .accessibilityHidden(true)
                }
                SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, label: "Goal progress")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// One skill: animation, stages or best time, set as goal, and its workouts from easy to hard.
struct SkillScreen: View {
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingSubscription = false
    @State private var shareContent: ShareContent?
    private let goal: Goal
    private let catalog: Catalog

    init(goal: Goal, catalog: Catalog = .main) {
        self.goal = goal
        self.catalog = catalog
    }

    private var isActive: Bool {
        subscription.access.canUseSkills && (store.data.activeGoalID ?? catalog.goals.first?.id) == goal.id
    }

    var body: some View {
        let progress = JournalStats(entries: store.entries)
            .goalProgress(goal, reachedStages: store.reachedStages(of: goal))

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    Badge(kind: .subscription)
                }
                MonoLabel("Skill")
                Text(catalog: goal.nameKey)
                    .font(.exerciseTitle)
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
            }

            HUDPanel(padding: 10) {
                StickyManView(catalog.animation(for: goal))
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }

            progressSection(progress)

            goalSection

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Workouts for this skill")
                Text("From easy to hard.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
                ForEach(catalog.skillPlans(for: goal)) { plan in
                    PlanLink(plan: plan, catalog: catalog) {
                        isShowingSubscription = true
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSubscription) {
            PaywallSheet()
        }
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }

    @ViewBuilder
    private func progressSection(_ progress: GoalProgress) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MonoLabel("Progress")
                Spacer()
                if progress.filledSegments > 0 || progress.reachedStages > 0 {
                    IconButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share progress") {
                        shareContent = .skillCard(progress, catalog: catalog)
                    }
                }
                progress.stateText
                    .font(.monoBold)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.text)
            }
            SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, label: "Goal progress")

            if case .stages = goal.kind {
                VStack(spacing: 6) {
                    ForEach(Array(goal.stageKeys.enumerated()), id: \.offset) { index, key in
                        stageRow(number: index + 1, key: key, isReached: index < progress.reachedStages)
                    }
                }
                if !progress.isComplete {
                    Button {
                        guard subscription.access.canUseSkills else {
                            isShowingSubscription = true
                            return
                        }
                        withAnimation(.easeOut(duration: 0.2)) {
                            store.markStageReached(of: goal)
                        }
                    } label: {
                        ChipLabel("Stage reached", systemImage: "checkmark", style: .dashed, expands: true)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            } else {
                Text("Your best time comes from the journal.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
        }
    }

    private func stageRow(number: Int, key: String, isReached: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isReached ? "checkmark.square.fill" : "square")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isReached ? accent.color : Theme.lineStrong)
                .accessibilityHidden(true)
            Text(verbatim: String(format: "%02d", number))
                .font(.monoBold)
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
            Text(catalog: key)
                .font(.text(15))
                .foregroundStyle(isReached ? Theme.text : Theme.textSoft)
            Spacer(minLength: 0)
        }
        .frame(minHeight: 32)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isReached ? Text("Reached") : Text("Open"))
    }

    @ViewBuilder
    private var goalSection: some View {
        if isActive {
            Card {
                HStack(spacing: 10) {
                    Badge(kind: .selected)
                    Text("This is your current goal on the dashboard.")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                }
            }
        } else {
            PrimaryButton("Set as goal", systemImage: "scope") {
                if subscription.access.canUseSkills {
                    store.setActiveGoal(goal.id)
                } else {
                    isShowingSubscription = true
                }
            }
        }
    }
}

#Preview("Skills") {
    NavigationStack {
        ScrollView {
            SkillList(catalog: .main)
                .padding(Theme.Layout.screenEdge)
        }
        .background(Theme.background)
    }
    .previewEnvironment()
}

#Preview("Skill, German") {
    NavigationStack {
        if let goal = Catalog.main.goals.first {
            SkillScreen(goal: goal)
        }
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
