import SwiftUI

/// Filter of the workouts list: all plans or one category. Single selection.
enum WorkoutFilter: Hashable, Identifiable {
    case all
    case category(ExerciseCategory)

    static let allFilters: [WorkoutFilter] = [.all] + ExerciseCategory.allCases.map { .category($0) }

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

/// Workouts tab: predefined plans, filterable by category. Free plans start the
/// workout; subscription plans lead to the subscription page.
struct WorkoutsScreen: View {
    @Environment(UserDataStore.self) private var store
    private let catalog: Catalog
    @State private var filter: WorkoutFilter = .all
    @State private var subscriptionPlan: WorkoutPlan?
    @State private var editing: CustomWorkout?
    @State private var deleting: CustomWorkout?

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel("\(catalog.freePlanCount) plans free"), title: "Workouts") {
                NavigationLink {
                    CustomWorkoutEditor(workout: nil, catalog: catalog)
                } label: {
                    ChipLabel("Custom", systemImage: "plus", style: .dashed)
                }
                .buttonStyle(PressFeedbackStyle())
            }

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
                ForEach(catalog.filteredPlans(category: filter.category)) { plan in
                    if plan.isFree {
                        NavigationLink {
                            TrainingScreen(plan: plan, catalog: catalog)
                        } label: {
                            PlanRow(plan: plan)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    } else {
                        Button {
                            subscriptionPlan = plan
                        } label: {
                            PlanRow(plan: plan)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }
        }
        .sheet(item: $subscriptionPlan) { _ in
            SubscriptionPlaceholderSheet()
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

    /// Custom workouts of the selected category, shown above the plans.
    private var customWorkouts: [CustomWorkout] {
        store.customWorkouts.filter { filter.category == nil || $0.category == filter.category }
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
