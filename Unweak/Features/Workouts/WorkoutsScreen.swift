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
    private let catalog: Catalog
    @State private var filter: WorkoutFilter = .all
    @State private var subscriptionPlan: WorkoutPlan?

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel("\(catalog.freePlanCount) plans free"), title: "Workouts") {
                NavigationLink {
                    ComingLaterScreen(title: "Create workout")
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
    }
}

/// One plan in the list: pose, name, metadata and Free/Pro badge.
struct PlanRow: View {
    private let plan: WorkoutPlan

    init(plan: WorkoutPlan) {
        self.plan = plan
    }

    var body: some View {
        Card(padding: 12) {
            HStack(spacing: 14) {
                StickyPoseView(plan.pose, highlighted: plan.isFree)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(catalog: plan.nameKey)
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
                Badge(kind: plan.isFree ? .free : .subscription)
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
}

#Preview("German") {
    NavigationStack {
        WorkoutsScreen()
    }
    .environment(\.locale, Locale(identifier: "de"))
}
