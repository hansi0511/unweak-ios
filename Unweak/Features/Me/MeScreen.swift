import SwiftUI

/// "Me" tab (Design V2, `V2-Ich`): the avatar with the weekly ring, which opens the Me
/// area; the workout due today with "Start"; and one row for the goal (Pro) or the skills
/// teaser (free).
struct MeScreen: View {
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(LeagueStore.self) private var league
    @State private var isShowingPaywall = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let target = reminders.weeklyTarget
        let stats = JournalStats(entries: store.entries)
        let week = stats.week(containing: .now, target: target)
        let streak = stats.streak(at: .now, target: target)
        let unlocks = AvatarUnlocks(stats: stats, catalog: catalog, weeklyTarget: target, leagueWins: Set(store.data.leagueWins)) {
            store.reachedStages(of: $0)
        }
        let goals = subscription.access.canUseSkills ? store.activeGoals(in: catalog) : []
        // Pro: first from the skills being learned. Free: from the free workouts.
        let today = stats.nextWorkout(in: catalog, access: subscription.access, preferring: goals.flatMap(\.plans))

        let now = Date.now
        let standing = league.standing(store: store, weeklyTarget: target, catalog: catalog, now: now)
        @Bindable var leagueBinding = league

        ScreenContainer {
            Text("Me")
                .font(.screenTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)

            NavigationLink {
                ProfileScreen(catalog: catalog)
            } label: {
                AvatarWithWeek(
                    style: store.data.avatar,
                    avatarBody: unlocks.body(for: store.data.avatar),
                    extra: unlocks.extra(for: store.data.avatar),
                    week: week,
                    streak: streak
                )
            }
            .buttonStyle(PressFeedbackStyle())
            .frame(maxWidth: .infinity)
            .accessibilityHint(Text("Your avatar and level"))

            if let today {
                TodayCard(plan: today, catalog: catalog)
            }

            if league.isTakingPart {
                NavigationLink {
                    LeagueScreen(catalog: catalog)
                } label: {
                    LeagueRow(league: league.league, standing: standing, daysLeft: LeagueWeek(containing: now).daysLeft(at: now))
                }
                .buttonStyle(PressFeedbackStyle())
            }

            goalRow(goals: goals, stats: stats)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
        .fullScreenCover(item: $leagueBinding.pendingResult) { result in
            WeekResultScreen(result: result)
        }
        .onAppear {
            // From Monday on: shows how the last week ended, once.
            league.refresh(
                store: store,
                weeklyTarget: target,
                avatar: LeagueAvatar.mine(store: store, catalog: catalog, weeklyTarget: target),
                now: .now
            )
        }
    }

    /// Pro with one skill: "Your goal: Front lever". With several: "Your goals" and one row
    /// per skill. Pro without: a row to choose one. Free: the skills teaser, which opens the
    /// subscription page.
    @ViewBuilder
    private func goalRow(goals: [Goal], stats: JournalStats) -> some View {
        if !subscription.access.canUseSkills {
            Button {
                isShowingPaywall = true
            } label: {
                GoalRowLabel(pose: .frontLever, title: Text("Skills"), badge: true) {
                    Text("Front lever, muscle-up and more in 5 stages")
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .buttonStyle(PressFeedbackStyle())
        } else if goals.count == 1, let goal = goals.first {
            goalLink(goal, title: Text("Your goal: \(Text(catalog: goal.nameKey))"), stats: stats)
        } else if !goals.isEmpty {
            // Several skills: "Your goals" and one row per skill, in the order they were added.
            VStack(alignment: .leading, spacing: 8) {
                Text("Your goals")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                ForEach(goals) { goal in
                    goalLink(goal, title: Text(catalog: goal.nameKey), stats: stats)
                }
            }
        } else {
            Button {
                navigation?.showSkills()
            } label: {
                GoalRowLabel(pose: .frontLever, title: Text("Choose a goal"), badge: false) {
                    Text("Learn a skill in 5 stages")
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }

    /// One skill row: pose, title, stage and segments; opens the skill page.
    private func goalLink(_ goal: Goal, title: Text, stats: JournalStats) -> some View {
        let progress = stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal))
        return NavigationLink {
            SkillScreen(goal: goal, catalog: catalog)
        } label: {
            GoalRowLabel(pose: goal.pose, title: title, badge: false) {
                HStack(spacing: 10) {
                    progress.shortStateText
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                    SegmentedProgress(total: GoalProgress.segmentCount, filled: progress.filledSegments, height: 5, label: "Goal progress")
                }
            }
        }
        .buttonStyle(PressFeedbackStyle())
    }
}

extension GoalProgress {
    /// "2 / 5" for skills with stages, "1:20 / 5:00" or "5:00" for time skills.
    var shortStateText: Text {
        switch goal.kind {
        case .stages(let count):
            return Text(verbatim: "\(reachedStages) / \(count)")
        case .time(let target):
            if let bestSeconds {
                return Text("\(ValueText.seconds(bestSeconds)) / \(ValueText.seconds(target))")
            }
            return ValueText.seconds(target)
        }
    }
}

/// The avatar (190 pt) in its weekly ring, with "2 of 3 workouts this week" and the streak.
private struct AvatarWithWeek: View {
    @Environment(\.accent) private var accent
    let style: AvatarStyle
    let avatarBody: AvatarBody
    let extra: AvatarExtra?
    let week: WeekSummary
    let streak: Int

    private static let size: CGFloat = 190

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(style.backgroundColor)
                    .padding(18)
                WeekRing(total: week.target, filled: week.workouts)
                AvatarView(style: style, body: avatarBody, extra: extra, framed: false)
                    .padding(30)
            }
            .frame(width: Self.size, height: Self.size)

            VStack(spacing: 4) {
                Text("\(Text(verbatim: "\(week.workouts)").foregroundColor(accent.color)) of \(week.target) workouts this week")
                    .font(.textSemibold(17))
                    .foregroundStyle(Theme.text)
                if streak > 0 {
                    Text("\(streak) weeks in a row done")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .multilineTextAlignment(.center)
        }
        .contentShape(Rectangle())
    }
}

/// One arc per workout of the weekly target around the avatar; done ones in the accent color.
private struct WeekRing: View {
    @Environment(\.accent) private var accent
    let total: Int
    let filled: Int

    /// Gap between two arcs, as a share of the full circle.
    private static let gap = 0.015
    private static let lineWidth: CGFloat = 7

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

/// "Due today": pose, workout name, duration and number of exercises, and "Start".
/// The only card on the screen with corner marks.
private struct TodayCard: View {
    @Environment(\.accent) private var accent
    let plan: WorkoutPlan
    let catalog: Catalog

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                StickyPoseView(plan.pose)
                    .scaleEffect(56 / StickyPose.canvas.width)
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due today")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                    plan.title
                        .font(.grotesk(26))
                        .foregroundStyle(Theme.text)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text("\(plan.estimatedMinutes) min · \(plan.exercises.count) exercises")
                        .font(.text(14))
                        .foregroundStyle(Theme.textSoft)
                }
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .combine)

            NavigationLink {
                TrainingScreen(plan: plan, catalog: catalog)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .accessibilityHidden(true)
                    Text("Start")
                        .font(.buttonTitle)
                }
                .foregroundStyle(Theme.onAccent)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(accent.color)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .glow(accent.color, radius: Theme.Glow.medium)
        }
        .padding(18)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .overlay {
            DiagonalCornerMarks()
                .stroke(accent.color, lineWidth: Theme.Layout.cornerMarkWidth)
                .accessibilityHidden(true)
        }
    }
}

/// A slim row: pose, a title line and a detail below, an optional "PRO" badge and a chevron.
private struct GoalRowLabel<Detail: View>: View {
    let pose: StickyPose
    let title: Text
    let badge: Bool
    @ViewBuilder let detail: () -> Detail

    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(pose)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    title
                        .font(.textSemibold(16))
                        .foregroundStyle(Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if badge {
                        Badge(kind: .subscription)
                    }
                }
                detail()
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .contentShape(Rectangle())
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
