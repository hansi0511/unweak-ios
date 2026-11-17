import SwiftUI

/// Filter of the workouts list: all plans or one category. Single selection.
enum WorkoutFilter: Hashable, Identifiable {
    case all
    case category(ExerciseCategory)

    /// "All" and the general categories; skill workouts live in the Skills area.
    static let allFilters: [WorkoutFilter] = {
        let categories: [ExerciseCategory] = ExerciseCategory.allCases.filter { $0 != .skill }
        return [.all] + categories.map { .category($0) }
    }()

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .category(let category): category.title
        }
    }

    var category: ExerciseCategory? {
        switch self {
        case .all: nil
        case .category(let category): category
        }
    }
}

/// The two areas of the workouts tab.
enum WorkoutsArea: Hashable {
    /// Skills such as Front Lever, each with its matching workouts.
    case skills
    /// General workouts and custom workouts, filterable by category.
    case workouts
}

/// Workouts tab with two areas: skills (highlighted, first) and workouts. Free plans
/// start the workout; subscription plans lead to the subscription page.
struct WorkoutsScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    private let catalog: Catalog
    @State private var area: WorkoutsArea = .skills
    @State private var filter: WorkoutFilter = .all
    @State private var isShowingPaywall = false
    @State private var editing: CustomWorkout?
    @State private var deleting: CustomWorkout?

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel("\(catalog.freePlanCount) workouts free"), title: "Workouts") {
                if area == .workouts {
                    if subscription.access.canCreateCustomWorkout(existing: store.customWorkouts.count) {
                        NavigationLink {
                            CustomWorkoutEditor(workout: nil, catalog: catalog)
                        } label: {
                            ChipLabel("Custom", systemImage: "plus", style: .dashed)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    } else {
                        // Free version: three custom workouts; more with Pro.
                        Button {
                            isShowingPaywall = true
                        } label: {
                            ChipLabel("Custom", systemImage: "lock.fill", style: .dashed)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }

            HStack(spacing: 8) {
                SelectChip("Skills", isSelected: area == .skills, expands: true) {
                    area = .skills
                }
                SelectChip("Workouts", isSelected: area == .workouts, expands: true) {
                    area = .workouts
                }
            }

            switch area {
            case .skills:
                SkillList(catalog: catalog)
            case .workouts:
                workoutsArea
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
        .navigationDestination(item: $editing) { workout in
            CustomWorkoutEditor(workout: workout, catalog: catalog)
        }
        .confirmationDialog(
            "Delete this workout?",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            titleVisibility: .visible,
            presenting: deleting
        ) { workout in
            Button("Delete workout", role: .destructive) {
                store.delete(workout)
            }
        } message: { _ in
            Text("Journal entries of this workout are kept.")
        }
    }

    /// Filter and list of the general and custom workouts.
    private var workoutsArea: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.blockSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(WorkoutFilter.allFilters) { item in
                        SelectChip(item.title, isSelected: item == filter) {
                            filter = item
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 10) {
                ForEach(customWorkouts) { workout in
                    NavigationLink {
                        TrainingScreen(plan: workout.plan(in: catalog), catalog: catalog)
                    } label: {
                        PlanRow(plan: workout.plan(in: catalog), badge: .custom)
                    }
                    .buttonStyle(PressFeedbackStyle())
                    .contextMenu {
                        Button {
                            editing = workout
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deleting = workout
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                ForEach(catalog.workoutPlans(category: filter.category)) { plan in
                    PlanLink(plan: plan, catalog: catalog) {
                        isShowingPaywall = true
                    }
                }
            }
        }
    }

    /// Custom workouts of the selected category, shown above the plans.
    private var customWorkouts: [CustomWorkout] {
        store.customWorkouts.filter { filter.category == nil || $0.category == filter.category }
    }
}

/// A plan row that starts the workout, or asks for the subscription if the plan needs Pro.
struct PlanLink: View {
    @Environment(SubscriptionStore.self) private var subscription
    let plan: WorkoutPlan
    let catalog: Catalog
    let onSubscriptionNeeded: () -> Void

    var body: some View {
        if subscription.access.canTrain(plan) {
            NavigationLink {
                TrainingScreen(plan: plan, catalog: catalog)
            } label: {
                PlanRow(plan: plan)
            }
            .buttonStyle(PressFeedbackStyle())
        } else {
            Button(action: onSubscriptionNeeded) {
                PlanRow(plan: plan)
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }
}

/// One plan in the list: pose, name, metadata and badge (Free, Pro or Custom).
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
