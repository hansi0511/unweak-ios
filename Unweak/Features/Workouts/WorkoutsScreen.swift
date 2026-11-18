import SwiftUI

/// Workouts tab (Design V2, `V2-Workouts`): two suggested workouts ("For you"), the four
/// areas as tiles, and a card that leads to the skills. The plus creates a custom workout.
struct WorkoutsScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingPaywall = false
    @State private var isCreating = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let goals = subscription.access.canUseSkills ? store.activeGoals(in: catalog) : []
        let suggestions = stats.nextWorkouts(
            in: catalog,
            access: subscription.access,
            preferring: goals.flatMap(\.plans),
            count: 2
        )

        ScreenContainer {
            HStack {
                Text("Workouts")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                IconButton(systemImage: "plus", accessibilityLabel: "Create custom workout") {
                    if subscription.access.canCreateCustomWorkout(existing: store.customWorkouts.count) {
                        isCreating = true
                    } else {
                        // Free version: three custom workouts; more with Pro.
                        isShowingPaywall = true
                    }
                }
            }

            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("For you")
                    ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, plan in
                        NavigationLink {
                            TrainingScreen(plan: plan, catalog: catalog)
                        } label: {
                            WorkoutCard(plan: plan, isHighlighted: index == 0)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("By area")
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(ExerciseCategory.areas, id: \.self) { area in
                        NavigationLink(value: WorkoutsRoute.area(area)) {
                            AreaTile(area: area, count: workoutCount(in: area))
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }

            NavigationLink(value: WorkoutsRoute.skills) {
                SkillsCard()
            }
            .buttonStyle(PressFeedbackStyle())
        }
        .navigationDestination(for: WorkoutsRoute.self) { route in
            switch route {
            case .skills: SkillsScreen(catalog: catalog)
            case .area(let area): AreaScreen(area: area, catalog: catalog)
            }
        }
        .navigationDestination(isPresented: $isCreating) {
            CustomWorkoutEditor(workout: nil, catalog: catalog)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
    }

    /// Catalog plans and custom workouts of an area.
    private func workoutCount(in area: ExerciseCategory) -> Int {
        catalog.workoutPlans(category: area).count + store.customWorkouts.filter { $0.category == area }.count
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.buttonTitle)
            .foregroundStyle(Theme.text)
            .accessibilityAddTraits(.isHeader)
    }
}

/// One area tile: pose, name and number of workouts.
private struct AreaTile: View {
    let area: ExerciseCategory
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            StickyPoseView(area.areaPose)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            Text(area.title)
                .font(.textSemibold(17))
                .foregroundStyle(Theme.text)
            Text("\(count) workouts")
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 112, maxHeight: 112, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// "Skills · PRO" with one sentence; opens the skills.
private struct SkillsCard: View {
    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(.frontLever)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Skills")
                        .font(.grotesk(20))
                        .foregroundStyle(Theme.text)
                    Badge(kind: .subscription)
                }
                Text("Front lever, muscle-up and more in 5 stages")
                    .font(.text(14))
                    .foregroundStyle(Theme.textSoft)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// A workout as a card (Design V2): pose, name, "21 min · Beginner", an optional badge
/// and a play circle. Highlighted: accent outline and a filled play button.
struct WorkoutCard: View {
    @Environment(\.accent) private var accent
    let plan: WorkoutPlan
    var isHighlighted = false
    var badge: Badge.Kind?

    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(plan.pose)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    plan.title
                        .font(.textSemibold(18))
                        .foregroundStyle(Theme.text)
                        .multilineTextAlignment(.leading)
                    if let badge {
                        Badge(kind: badge)
                    }
                }
                Text("\(plan.estimatedMinutes) min · \(Text(plan.level.title))")
                    .font(.text(14))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            Image(systemName: "play.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isHighlighted ? Theme.onAccent : accent.color)
                .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                .background(Circle().fill(isHighlighted ? accent.color : Color.clear))
                .overlay(Circle().strokeBorder(accent.color, lineWidth: isHighlighted ? 0 : 1.5))
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(isHighlighted ? accent.color : Theme.line, lineWidth: isHighlighted ? 2 : 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// One plan in a list: pose, name, metadata and badge (Free, Pro or Custom). Used when
/// adding a workout by hand in the Journey.
struct PlanRow: View {
    private let plan: WorkoutPlan
    private let badge: Badge.Kind

    init(plan: WorkoutPlan, badge: Badge.Kind? = nil) {
        self.plan = plan
        self.badge = badge ?? (plan.customName != nil ? .custom : (plan.isFree ? .free : .subscription))
    }

    var body: some View {
        Card(padding: 12) {
            HStack(spacing: 14) {
                StickyPoseView(plan.pose, highlighted: plan.isFree)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    plan.title
                        .font(.textSemibold(17))
                        .foregroundStyle(Theme.text)
                        .multilineTextAlignment(.leading)
                    MetaLine([
                        Text(plan.category.title),
                        Text("\(plan.estimatedMinutes) min"),
                        Text(plan.level.title),
                    ])
                }
                Spacer(minLength: 0)
                Badge(kind: badge)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NavigationStack {
        WorkoutsScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        WorkoutsScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
