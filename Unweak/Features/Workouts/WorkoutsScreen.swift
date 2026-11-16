import SwiftUI

/// Workout categories used for filtering plans.
enum WorkoutFilter: CaseIterable, Identifiable {
    case all
    case push
    case pull
    case legs
    case core
    case skill

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .push: "Push"
        case .pull: "Pull"
        case .legs: "Legs"
        case .core: "Core"
        case .skill: "Skill"
        }
    }
}

/// Workouts tab. Step 1 placeholder: header and the category filter.
/// The plan list follows in step 3.
struct WorkoutsScreen: View {
    @State private var filter: WorkoutFilter = .all

    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel("5 plans free"), title: "Workouts")

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(WorkoutFilter.allCases) { item in
                        SelectChip(item.title, isSelected: item == filter) {
                            filter = item
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            PlaceholderNote()
        }
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
