import Foundation
import SwiftUI

/// Exercise and plan categories, also used by the workout filter.
enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case push
    case pull
    case legs
    case core
    case skill

    var title: LocalizedStringKey {
        switch self {
        case .push: "Push"
        case .pull: "Pull"
        case .legs: "Legs"
        case .core: "Core"
        case .skill: "Skill"
        }
    }
}

enum ExerciseLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced

    var title: LocalizedStringKey {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        }
    }
}

/// Texts of the training content live in `Catalog.xcstrings` (table "Catalog").
/// Models only carry the keys.
enum CatalogText {
    static let table = "Catalog"
}

extension Text {
    /// Text from the content string table (`Catalog.xcstrings`).
    init(catalog key: String) {
        self.init(LocalizedStringKey(key), tableName: CatalogText.table)
    }
}

struct Exercise: Codable, Identifiable, Hashable, Sendable {
    static let stepCount = 3

    let id: String
    let category: ExerciseCategory
    let level: ExerciseLevel
    let animation: StickyAnimation
    let pose: StickyPose
    let mistakeCount: Int
    /// IDs of the easier and harder variant.
    let easier: String?
    let harder: String?

    var nameKey: String { "exercise.\(id).name" }
    var stepKeys: [String] { (1...Self.stepCount).map { "exercise.\(id).step\($0)" } }
    var mistakeKeys: [String] { (0..<mistakeCount).map { "exercise.\(id).mistake\($0 + 1)" } }
}

/// What one set asks for.
enum ExerciseTarget: Hashable, Sendable {
    case reps(Int)
    case seconds(Int)

    /// Estimated seconds of work for one set (3 s per repetition).
    var workSeconds: Int {
        switch self {
        case .reps(let count): count * 3
        case .seconds(let seconds): seconds
        }
    }
}

struct PlanExercise: Codable, Hashable, Sendable {
    let exercise: String
    let sets: Int
    let reps: Int?
    let seconds: Int?
    /// Rest after each set, in seconds.
    let rest: Int

    var target: ExerciseTarget {
        if let seconds { .seconds(seconds) } else { .reps(reps ?? 0) }
    }
}

struct WorkoutPlan: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let category: ExerciseCategory
    let level: ExerciseLevel
    let pose: StickyPose
    let isFree: Bool
    let exercises: [PlanExercise]
    /// Name typed by the user for a custom workout; catalog plans use `nameKey`.
    var customName: String?

    var nameKey: String { "plan.\(id).name" }

    /// Display name: the custom name or the localized catalog name.
    var title: Text {
        if let customName { Text(verbatim: customName) } else { Text(catalog: nameKey) }
    }

    /// Estimated length: sets × (work + rest) for every exercise.
    var estimatedSeconds: Int {
        exercises.reduce(0) { $0 + $1.sets * ($1.target.workSeconds + $1.rest) }
    }

    /// Estimated length in whole minutes, at least 1.
    var estimatedMinutes: Int {
        max(1, Int((Double(estimatedSeconds) / 60).rounded()))
    }
}

struct Goal: Codable, Identifiable, Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        /// Skill goal with named stages.
        case stages(Int)
        /// Time goal: hold for this many seconds (best time counts).
        case time(seconds: Int)
    }

    let id: String
    let pose: StickyPose
    /// Exercise behind the goal: its animation is shown on the dashboard and, for
    /// time goals, its best journal value is the current best time.
    let exercise: String
    /// Workouts that build this skill, from easy to hard.
    let plans: [String]
    let isFree: Bool
    let stageCount: Int?
    let targetSeconds: Int?
    /// Animation for the skill, if it differs from the linked exercise's animation
    /// (e.g. the full front lever, while the exercise is the tuck front lever).
    var animation: StickyAnimation?

    var kind: Kind {
        if let stageCount { .stages(stageCount) } else { .time(seconds: targetSeconds ?? 0) }
    }

    var nameKey: String { "goal.\(id).name" }
    var stageKeys: [String] { (0..<(stageCount ?? 0)).map { "goal.\(id).stage\($0 + 1)" } }
}

/// A milestone computed from the journal, e.g. "10 pull-ups" or "25 workouts".
struct Achievement: Codable, Identifiable, Hashable, Sendable {
    enum Kind: String, Codable, Sendable {
        /// Number of journal entries.
        case workouts
        /// Best repetitions of `exercise` in one set.
        case reps
        /// Best hold time of `exercise` in seconds.
        case seconds
        /// Weeks in a row with the weekly target reached.
        case streak
    }

    let id: String
    let kind: Kind
    let threshold: Int
    let exercise: String?

    /// Text under the value, e.g. "Pull-ups".
    var labelKey: String { "achievement.\(id).label" }
}

/// The bundled training content: exercises, plans, goals and achievements from `Catalog.json`.
struct Catalog: Codable, Sendable {
    let exercises: [Exercise]
    let plans: [WorkoutPlan]
    let goals: [Goal]
    let achievements: [Achievement]

    enum LoadError: Error {
        case missingFile
        case invalid([String])
    }

    /// The catalog shipped with the app. A broken bundle file is a programming error.
    static let main: Catalog = {
        do {
            return try load()
        } catch {
            fatalError("Catalog.json could not be loaded: \(error)")
        }
    }()

    static func load(from bundle: Bundle = .main) throws -> Catalog {
        guard let url = bundle.url(forResource: "Catalog", withExtension: "json") else {
            throw LoadError.missingFile
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
        let problems = catalog.problems()
        guard problems.isEmpty else { throw LoadError.invalid(problems) }
        return catalog
    }

    func exercise(_ id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }

    func plan(_ id: String) -> WorkoutPlan? {
        plans.first { $0.id == id }
    }

    /// Plans of one category, or all plans for `nil`. Free plans come first.
    func filteredPlans(category: ExerciseCategory?) -> [WorkoutPlan] {
        let matching = plans.filter { category == nil || $0.category == category }
        return matching.filter(\.isFree) + matching.filter { !$0.isFree }
    }

    var freePlanCount: Int { plans.filter(\.isFree).count }

    /// Animation shown for a skill: its own, else that of its linked exercise.
    func animation(for goal: Goal) -> StickyAnimation {
        goal.animation ?? exercise(goal.exercise)?.animation ?? .frontLever
    }

    /// The workouts of a skill, from easy to hard.
    func skillPlans(for goal: Goal) -> [WorkoutPlan] {
        goal.plans.compactMap { plan($0) }
    }

    /// General workouts of a category (`nil` for all), without the skill workouts,
    /// which are shown with their skills. Free plans come first.
    func workoutPlans(category: ExerciseCategory?) -> [WorkoutPlan] {
        filteredPlans(category: category).filter { $0.category != .skill }
    }

    /// Every text key the catalog uses.
    var textKeys: [String] {
        // Built step by step: one long chain of `+` is too slow for the type checker.
        var keys: [String] = []
        for exercise in exercises {
            keys.append(exercise.nameKey)
            keys.append(contentsOf: exercise.stepKeys)
            keys.append(contentsOf: exercise.mistakeKeys)
        }
        keys.append(contentsOf: plans.map(\.nameKey))
        for goal in goals {
            keys.append(goal.nameKey)
            keys.append(contentsOf: goal.stageKeys)
        }
        keys.append(contentsOf: achievements.map(\.labelKey))
        return keys
    }

    /// Broken references and inconsistent entries. Empty for valid data.
    func problems() -> [String] {
        var problems: [String] = []
        let ids = Set(exercises.map(\.id))
        if ids.count != exercises.count { problems.append("Duplicate exercise IDs") }
        for exercise in exercises {
            for variant in [exercise.easier, exercise.harder].compactMap({ $0 }) where !ids.contains(variant) {
                problems.append("Exercise \(exercise.id): unknown variant \(variant)")
            }
        }
        for plan in plans {
            if plan.exercises.isEmpty { problems.append("Plan \(plan.id) has no exercises") }
            for item in plan.exercises {
                if !ids.contains(item.exercise) { problems.append("Plan \(plan.id): unknown exercise \(item.exercise)") }
                if item.sets < 1 { problems.append("Plan \(plan.id): \(item.exercise) needs at least one set") }
                if (item.reps == nil) == (item.seconds == nil) {
                    problems.append("Plan \(plan.id): \(item.exercise) needs either reps or seconds")
                }
            }
        }
        for goal in goals {
            if (goal.stageCount == nil) == (goal.targetSeconds == nil) {
                problems.append("Goal \(goal.id) needs either stages or a target time")
            }
            if !ids.contains(goal.exercise) { problems.append("Goal \(goal.id): unknown exercise \(goal.exercise)") }
            if goal.plans.isEmpty { problems.append("Goal \(goal.id) has no workouts") }
            for planID in goal.plans where plan(planID) == nil {
                problems.append("Goal \(goal.id): unknown workout \(planID)")
            }
        }
        for achievement in achievements {
            let needsExercise = achievement.kind == .reps || achievement.kind == .seconds
            if needsExercise != (achievement.exercise != nil) {
                problems.append("Achievement \(achievement.id): exercise does not match its kind")
            }
            if let exercise = achievement.exercise, !ids.contains(exercise) {
                problems.append("Achievement \(achievement.id): unknown exercise \(exercise)")
            }
        }
        return problems
    }
}
