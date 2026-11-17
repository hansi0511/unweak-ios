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
                // Pro: first from the skills being learned. Free: from the free workouts.
                nextPlans: stats.nextWorkouts(
                    in: catalog,
                    access: subscription.access,
                    preferring: goals.flatMap(\.plans),
                    count: 5
                ),
                catalog: catalog
            )

            if subscription.access.canUseSkills {
                VStack(spacing: 8) {
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
                        SkillRow(
                            progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                            catalog: catalog
                        )
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
/// this week; below it the week in short, the name of the body and the next workouts.
private struct AvatarStage: View {
    let style: AvatarStyle
    let unlocks: AvatarUnlocks
    let week: WeekSummary
    let streak: Int
    let nextPlans: [WorkoutPlan]
    let catalog: Catalog

    var body: some View {
        let current = unlocks.body(for: style)

        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(style.backgroundColor)
                    .padding(16)
                WeekRing(total: week.target, filled: week.workouts)
                AvatarView(style: style, body: current, extra: unlocks.extra(for: style), framed: false)
                    .padding(26)
            }
            .frame(maxWidth: 180)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)

            HStack(spacing: 6) {
                Text("\(week.workouts) / \(week.target) this week")
                if streak > 0 {
                    Text(verbatim: "·")
                    Text("Streak \(streak) weeks")
                }
                Text(verbatim: "·")
                Text(current.name)
                    .foregroundStyle(Theme.text)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Theme.textSoft)
            .font(.mono)
            .tracking(1)
            .textCase(.uppercase)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            if !nextPlans.isEmpty {
                NextWorkoutsRow(plans: nextPlans, catalog: catalog)
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

/// One skill being learned, as a slim row: still pose of the current stage, name, state
/// with the current stage, fine segments. Opens the skill page; stages are marked there.
private struct SkillRow: View {
    @Environment(\.accent) private var accent
    let progress: GoalProgress
    let catalog: Catalog

    private var goal: Goal { progress.goal }

    var body: some View {
        let animation = catalog.currentAnimation(for: progress)
        NavigationLink {
            SkillScreen(goal: goal, catalog: catalog)
        } label: {
            HStack(spacing: 12) {
                StickyFigureCanvas(figure: animation.figure(at: animation.endPoseProgress))
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(catalog: goal.nameKey)
                        .font(.textSemibold(15))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                    stateLine
                        .font(.mono)
                        .foregroundStyle(Theme.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, height: 4, label: "Goal progress")
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent.color)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Shows the skill with its stages"))
    }

    /// "Stage 2 / 5 · Advanced tuck", or the best or target time.
    private var stateLine: Text {
        guard let index = progress.currentStageIndex, !progress.isComplete,
              goal.stageKeys.indices.contains(index)
        else { return progress.stateText }
        return progress.stateText + Text(verbatim: " · ") + Text(catalog: goal.stageKeys[index])
    }
}

/// Free version: invites to the skills, which need Pro.
private struct SkillTeaser: View {
    var body: some View {
        HStack(spacing: 12) {
            StickyPoseView(.frontLever)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    MonoLabel("Skills")
                    Badge(kind: .subscription)
                }
                Text("Reach your first skill")
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// Up to five suggested workouts as tiles that scroll sideways. The first one is the
/// main suggestion and stands out in the accent color. Each tile starts its workout.
/// Kept flat (72 pt) so that the Me tab fits on one screen.
private struct NextWorkoutsRow: View {
    let plans: [WorkoutPlan]
    let catalog: Catalog

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                    NavigationLink {
                        TrainingScreen(plan: plan, catalog: catalog)
                    } label: {
                        NextWorkoutTile(plan: plan, isFirst: index == 0)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
            // The row runs to the screen edges while the tiles start in line with the content.
            .padding(.horizontal, Theme.Layout.screenEdge)
        }
        .padding(.horizontal, -Theme.Layout.screenEdge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Next workouts"))
    }
}

/// One suggested workout: pose, name, duration and a play symbol.
private struct NextWorkoutTile: View {
    @Environment(\.accent) private var accent
    let plan: WorkoutPlan
    let isFirst: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            StickyPoseView(plan.pose)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                plan.title
                    .font(.textSemibold(13))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(accent.color)
                        .accessibilityHidden(true)
                    ValueText.minutes(plan.estimatedSeconds)
                        .font(.mono)
                        .foregroundStyle(Theme.textMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(width: 168, height: 72, alignment: .leading)
        .background(isFirst ? Theme.surfaceSelected : Theme.surface)
        .overlay(Rectangle().strokeBorder(isFirst ? accent.color : Theme.line, lineWidth: isFirst ? 2 : 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text("Starts the workout"))
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
