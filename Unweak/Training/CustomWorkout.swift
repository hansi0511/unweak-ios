import Foundation

/// A workout put together by the user from catalog exercises.
struct CustomWorkout: Codable, Identifiable, Hashable, Sendable {
    static let idPrefix = "custom."

    var id: UUID
    var name: String
    var category: ExerciseCategory
    var exercises: [PlanExercise]

    init(id: UUID = UUID(), name: String = "", category: ExerciseCategory = .push, exercises: [PlanExercise] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.exercises = exercises
    }

    /// Plan ID used in the journal and for training.
    var planID: String { Self.idPrefix + id.uuidString }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Ready to save: a name and at least one exercise.
    var isComplete: Bool { !trimmedName.isEmpty && !exercises.isEmpty }

    /// The workout as a plan, so training, journal and lists treat it like any other.
    /// Level is the highest of its exercises, the pose that of the first exercise.
    func plan(in catalog: Catalog) -> WorkoutPlan {
        let known = exercises.compactMap { catalog.exercise($0.exercise) }
        let level = known.map(\.level).max { $0.rank < $1.rank } ?? .beginner
        return WorkoutPlan(
            id: planID,
            category: category,
            level: level,
            pose: known.first?.pose ?? .pushUp,
            isFree: true,
            exercises: exercises,
            customName: trimmedName
        )
    }
}

extension ExerciseLevel {
    var rank: Int {
        switch self {
        case .beginner: 0
        case .intermediate: 1
        case .advanced: 2
        }
    }
}

extension Catalog {
    /// Default target for an exercise added to a custom workout: the first use in a
    /// catalog plan, otherwise 3 × 8 repetitions with 60 s rest.
    func defaultItem(for exerciseID: String) -> PlanExercise {
        if let used = plans.lazy.flatMap(\.exercises).first(where: { $0.exercise == exerciseID }) {
            return used
        }
        return PlanExercise(exercise: exerciseID, sets: 3, reps: 8, seconds: nil, rest: 60)
    }
}

extension PlanExercise {
    /// Copy with a different number of sets (1...10).
    func withSets(_ sets: Int) -> PlanExercise {
        PlanExercise(exercise: exercise, sets: min(max(sets, 1), 10), reps: reps, seconds: seconds, rest: rest)
    }

    /// Copy with a different target value: repetitions 1...100 or seconds 5...600.
    func withTargetValue(_ value: Int) -> PlanExercise {
        if seconds != nil {
            return PlanExercise(exercise: exercise, sets: sets, reps: nil, seconds: min(max(value, 5), 600), rest: rest)
        }
        return PlanExercise(exercise: exercise, sets: sets, reps: min(max(value, 1), 100), seconds: nil, rest: rest)
    }

    var targetValue: Int {
        switch target {
        case .reps(let reps): reps
        case .seconds(let seconds): seconds
        }
    }
}
