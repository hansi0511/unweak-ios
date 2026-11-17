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
    /// Index of the reached stage the user wants to take back, while asking.
    @State private var stageToTakeBack: Int?
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
                VStack(spacing: 8) {
                    ForEach(Array(goal.stageKeys.enumerated()), id: \.offset) { index, key in
                        stageRow(index: index, key: key, progress: progress)
                    }
                }
                .confirmationDialog(
                    takeBackTitle,
                    isPresented: Binding(
                        get: { stageToTakeBack != nil },
                        set: { if !$0 { stageToTakeBack = nil } }
                    ),
                    titleVisibility: .visible
                ) {
                    Button("Take back", role: .destructive) {
                        if let index = stageToTakeBack {
                            withAnimation(.easeOut(duration: 0.2)) {
                                store.setReachedStages(index, of: goal)
                            }
                        }
                        stageToTakeBack = nil
                    }
                    Button("Cancel", role: .cancel) {
                        stageToTakeBack = nil
                    }
                } message: {
                    Text("Later stages are taken back too.")
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

    private var takeBackTitle: Text {
        guard let index = stageToTakeBack, goal.stageKeys.indices.contains(index) else { return Text(verbatim: "") }
        return Text("Take back “\(Text(catalog: goal.stageKeys[index]))”?")
    }

    /// One stage: small animation, number, name and check box. Tapping an open stage
    /// reaches it (and all before it); tapping a reached one asks to take it back.
    private func stageRow(index: Int, key: String, progress: GoalProgress) -> some View {
        let isReached = index < progress.reachedStages
        let isCurrent = index == progress.currentStageIndex && !progress.isComplete
        let animations = goal.stageAnimations ?? []
        return Button {
            guard subscription.access.canUseSkills else {
                isShowingSubscription = true
                return
            }
            if isReached {
                stageToTakeBack = index
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    store.setReachedStages(index + 1, of: goal)
                }
            }
        } label: {
            HStack(spacing: 12) {
                if animations.indices.contains(index) {
                    StickyManView(animations[index])
                        .frame(width: 64, height: 56)
                        .opacity(isReached || isCurrent ? 1 : 0.55)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        MonoLabel(verbatim: String(format: "%02d", index + 1))
                        if isCurrent {
                            MonoLabel("Now", color: accent.color, bold: true)
                        }
                    }
                    Text(catalog: key)
                        .font(.textSemibold(15))
                        .foregroundStyle(isReached || isCurrent ? Theme.text : Theme.textSoft)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: isReached ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isReached ? accent.color : Theme.lineStrong)
                    .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(isCurrent ? accent.color : Theme.line, lineWidth: isCurrent ? 2 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Stage \(index + 1): \(Text(catalog: key))"))
        .accessibilityValue(isReached ? Text("Reached") : Text("Open"))
        .accessibilityHint(isReached ? Text("Take back this stage") : Text("Mark as reached"))
    }

    @ViewBuilder
    private var goalSection: some View {
        if isActive {
            Card {
                HStack(spacing: 10) {
                    Badge(kind: .selected)
                    Text("This is your current goal in the Me tab.")
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
