import SwiftUI

/// The workouts of one area (Design V2, `V2-Bereich`): title, one sentence, then the custom
/// workouts of this area (badge "Custom", edit and delete in the context menu) and the
/// catalog plans. Plans that need Pro lead to the subscription page.
struct AreaScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingPaywall = false
    @State private var editing: CustomWorkout?
    @State private var deleting: CustomWorkout?
    private let area: ExerciseCategory
    private let catalog: Catalog

    init(area: ExerciseCategory, catalog: Catalog = .main) {
        self.area = area
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                BackButton()
                VStack(alignment: .leading, spacing: 6) {
                    Text(area.title)
                        .font(.grotesk(36))
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                    Text(area.areaDescription)
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                }
            }

            VStack(spacing: 10) {
                ForEach(store.customWorkouts.filter { $0.category == area }) { workout in
                    NavigationLink {
                        TrainingScreen(plan: workout.plan(in: catalog), catalog: catalog)
                    } label: {
                        WorkoutCard(plan: workout.plan(in: catalog), badge: .custom)
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

                ForEach(catalog.workoutPlans(category: area)) { plan in
                    if subscription.access.canTrain(plan) {
                        NavigationLink {
                            TrainingScreen(plan: plan, catalog: catalog)
                        } label: {
                            WorkoutCard(plan: plan)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    } else {
                        Button {
                            isShowingPaywall = true
                        } label: {
                            WorkoutCard(plan: plan, badge: .subscription)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
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
            Text("Workouts already saved in your Journey are kept.")
        }
    }
}

#Preview {
    NavigationStack {
        AreaScreen(area: .pull)
    }
    .previewEnvironment()
}
