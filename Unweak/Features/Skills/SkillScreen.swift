import SwiftUI

/// Skills (Design V2, `V2-Skills`): two columns of tiles with pose, name and five
/// segments; skills being learned carry "Your goal" and an accent outline. Without Pro
/// every tile opens the subscription page.
struct SkillsScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingPaywall = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let canUseSkills = subscription.access.canUseSkills
        let learning = canUseSkills ? Set(store.activeGoalIDs(in: catalog)) : []

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    Badge(kind: .subscription)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Skills")
                        .font(.grotesk(36))
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                    Text("Choose a goal. You learn it in 5 stages.")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(catalog.goals) { goal in
                    let tile = SkillTile(
                        progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                        isGoal: learning.contains(goal.id),
                        isLocked: !canUseSkills
                    )
                    if canUseSkills {
                        NavigationLink {
                            SkillScreen(goal: goal, catalog: catalog)
                        } label: {
                            tile
                        }
                        .buttonStyle(PressFeedbackStyle())
                    } else {
                        Button {
                            isShowingPaywall = true
                        } label: {
                            tile
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
    }
}

/// One skill tile: pose, "Your goal" when learned, name and five segments.
private struct SkillTile: View {
    @Environment(\.accent) private var accent
    let progress: GoalProgress
    let isGoal: Bool
    let isLocked: Bool

    private var goal: Goal { progress.goal }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                StickyPoseView(goal.pose, highlighted: !isLocked)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                if isGoal {
                    Text("Your goal")
                        .font(.text(12))
                        .foregroundStyle(accent.color)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.textMuted)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
            Text(catalog: goal.nameKey)
                .font(.textSemibold(16))
                .foregroundStyle(Theme.text)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, height: 4, label: "Goal progress")
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(isGoal ? accent.color : Theme.line, lineWidth: isGoal ? 2 : 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(isGoal ? Text("Your goal") : (isLocked ? Text("Locked") : Text(verbatim: "")))
        .accessibilityAddTraits(.isButton)
    }
}

/// One skill (Design V2, `V2-Skill`): "My goal" in the header, the animation, "Your
/// path" with five stage tiles (tap for the stage's info and the "Mastered" switch),
/// "Now" with what to do and "Done", and "Start matching workout".
struct SkillScreen: View {
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingSubscription = false
    /// Info sheet shown for the skill or one of its stages.
    @State private var info: SkillInfo?
    private let goal: Goal
    private let catalog: Catalog

    init(goal: Goal, catalog: Catalog = .main) {
        self.goal = goal
        self.catalog = catalog
    }

    private var isGoal: Bool {
        subscription.access.canUseSkills && store.isLearning(goal, in: catalog)
    }

    var body: some View {
        let progress = JournalStats(entries: store.entries)
            .goalProgress(goal, reachedStages: store.reachedStages(of: goal))

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    goalButton
                }
                Text(catalog: goal.nameKey)
                    .font(.exerciseTitle)
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
            }

            HUDPanel(padding: 10) {
                StickyManView(catalog.animation(for: goal))
                    .frame(maxWidth: .infinity)
                    .frame(height: 190)
                    .overlay(alignment: .topTrailing) {
                        IconButton(systemImage: "info.circle", accessibilityLabel: "About this skill") {
                            info = .skill
                        }
                    }
            }

            switch goal.kind {
            case .stages:
                pathSection(progress)
                nowCard(progress)
            case .time(let target):
                timeSection(progress, target: target)
            }

            if let plan = catalog.plan(forStage: progress.currentStageIndex ?? 0, of: goal) {
                if subscription.access.canTrain(plan) {
                    NavigationLink {
                        TrainingScreen(plan: plan, catalog: catalog)
                    } label: {
                        mainButtonLabel
                    }
                    .buttonStyle(PressFeedbackStyle())
                    .glow(accent.color, radius: Theme.Glow.medium)
                } else {
                    Button {
                        isShowingSubscription = true
                    } label: {
                        mainButtonLabel
                    }
                    .buttonStyle(PressFeedbackStyle())
                    .glow(accent.color, radius: Theme.Glow.medium)
                }
            }
        }
        .sheet(isPresented: $isShowingSubscription) {
            PaywallSheet()
        }
        .sheet(item: $info) { info in
            SkillInfoSheet(goal: goal, info: info, catalog: catalog)
        }
    }

    // MARK: Header

    /// "✓ My goal" or "Choose as goal"; toggles learning the skill.
    private var goalButton: some View {
        Button {
            guard subscription.access.canUseSkills else {
                isShowingSubscription = true
                return
            }
            withAnimation(.easeOut(duration: 0.15)) {
                store.setLearning(!isGoal, goal, in: catalog)
            }
        } label: {
            HStack(spacing: 6) {
                if isGoal {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .accessibilityHidden(true)
                    Text("My goal")
                } else {
                    Text("Choose as goal")
                }
            }
            .font(.text(14))
            .foregroundStyle(isGoal ? Theme.onAccent : accent.color)
            .padding(.horizontal, 14)
            .frame(minHeight: Theme.Layout.minTouchTarget)
            .background(isGoal ? accent.color : Color.clear)
            .overlay(Rectangle().strokeBorder(accent.color, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityHint(isGoal ? Text("Tap to stop learning") : Text("Adds the skill to the Me tab"))
    }

    // MARK: Stages

    /// "Your path" with "Stage 3 of 5" and five stage tiles.
    private func pathSection(_ progress: GoalProgress) -> some View {
        let count = goal.stageKeys.count
        let reached = progress.reachedStages
        let animations = goal.stageAnimations ?? []
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your path")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Group {
                    if progress.isComplete {
                        Text("\(count) of \(count)")
                    } else {
                        Text("Stage \(reached + 1) of \(count)")
                    }
                }
                .font(.text(14))
                .foregroundStyle(Theme.textMuted)
            }
            HStack(spacing: 6) {
                ForEach(0..<count, id: \.self) { index in
                    StageTile(
                        animation: animations.indices.contains(index) ? animations[index] : nil,
                        isReached: index < reached,
                        isCurrent: index == reached
                    ) {
                        info = .stage(index)
                    }
                    .accessibilityLabel(Text("Stage \(index + 1): \(Text(catalog: goal.stageKeys[index]))"))
                }
            }
        }
    }

    /// "Now": the current stage with what to do and "Done", or "Mastered!" at the end.
    @ViewBuilder
    private func nowCard(_ progress: GoalProgress) -> some View {
        if progress.isComplete {
            Text("Mastered!")
                .font(.grotesk(22))
                .foregroundStyle(accent.color)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .overlay(Rectangle().strokeBorder(accent.color, lineWidth: 1))
        } else if let index = progress.currentStageIndex {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Now")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                    Text(catalog: goal.stageKeys[index])
                        .font(.grotesk(22))
                        .foregroundStyle(Theme.text)
                    Text(catalog: goal.stageTipKeys[index])
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                Button {
                    guard subscription.access.canUseSkills else {
                        isShowingSubscription = true
                        return
                    }
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.markStageReached(of: goal)
                    }
                } label: {
                    Text("Done")
                        .font(.text(15))
                        .foregroundStyle(accent.color)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .overlay(Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4])))
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityHint(Text("Marks this stage as reached"))
            }
            .padding(16)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        }
    }

    /// Time skills: five segments with the best time, and where it comes from.
    private func timeSection(_ progress: GoalProgress, target: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your path")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Group {
                    if let best = progress.bestSeconds {
                        Text("Best \(ValueText.seconds(best)) of \(ValueText.seconds(target))")
                    } else {
                        Text("Target \(ValueText.seconds(target))")
                    }
                }
                .font(.text(14))
                .foregroundStyle(Theme.textMuted)
            }
            SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, height: 8, label: "Goal progress")
            Text("Your best time comes from your Journey.")
                .font(.text(15))
                .foregroundStyle(Theme.textSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var mainButtonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .bold))
                .accessibilityHidden(true)
            Text("Start matching workout")
                .font(.buttonTitle)
        }
        .foregroundStyle(Theme.onAccent)
        .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
        .background(accent.color)
        .contentShape(Rectangle())
    }
}

/// One stage on "Your path": still pose; reached ones filled, the current one with an
/// accent outline, later ones dimmed. Tapping opens the stage's info.
private struct StageTile: View {
    @Environment(\.accent) private var accent
    let animation: StickyAnimation?
    let isReached: Bool
    let isCurrent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if let animation {
                    StickyFigureCanvas(figure: animation.figure(at: animation.endPoseProgress), highlighted: isReached || isCurrent)
                        .padding(6)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58, maxHeight: 58)
            .background(isReached ? accent.color.opacity(0.18) : Theme.surface)
            .overlay(Rectangle().strokeBorder(isCurrent ? accent.color : Theme.line, lineWidth: isCurrent ? 2 : 1))
            .opacity(isReached || isCurrent ? 1 : 0.45)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityValue(isReached ? Text("Reached") : (isCurrent ? Text("Now") : Text("Open")))
        .accessibilityHint(Text("Shows muscles and how it is done"))
    }
}

#Preview("Skills") {
    NavigationStack {
        SkillsScreen()
    }
    .environment(SubscriptionStore.preview(isPro: true))
    .previewEnvironment()
}

#Preview("Skill, German") {
    NavigationStack {
        if let goal = Catalog.main.goals.first {
            SkillScreen(goal: goal)
        }
    }
    .environment(SubscriptionStore.preview(isPro: true))
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
