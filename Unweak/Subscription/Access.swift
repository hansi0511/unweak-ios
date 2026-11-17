import Foundation

/// Product IDs of the Pro subscription. Placeholders until the final bundle ID is set;
/// they must match App Store Connect and `Unweak.storekit`.
enum ProductID {
    static let monthly = "com.example.unweak.pro.monthly"
    static let yearly = "com.example.unweak.pro.yearly"
    static let all: Set<String> = [monthly, yearly]
}

/// What the free version and Pro allow (docs/SPEC.md "Preis").
/// Free: the general workouts and up to three custom workouts.
/// Pro: additionally all skills with their workouts and unlimited custom workouts.
struct Access: Equatable, Sendable {
    static let freeCustomWorkoutLimit = 3

    let isPro: Bool

    /// Skills can be opened, set as goal and tracked.
    var canUseSkills: Bool { isPro }

    func canTrain(_ plan: WorkoutPlan) -> Bool {
        plan.isFree || isPro
    }

    /// Whether another custom workout may be created, given how many exist.
    func canCreateCustomWorkout(existing count: Int) -> Bool {
        isPro || count < Self.freeCustomWorkoutLimit
    }
}
