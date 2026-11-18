import Foundation
import SwiftUI

/// How the workout felt.
enum WorkoutRating: String, Codable, CaseIterable, Sendable {
    case easy
    case right
    case hard

    var title: LocalizedStringKey {
        switch self {
        case .easy: "Easy"
        case .right: "Just right"
        case .hard: "Hard"
        }
    }
}

/// Result of one exercise in a workout: completed sets and the best set.
struct ExerciseResult: Codable, Hashable, Sendable {
    enum Unit: String, Codable, Sendable {
        case reps
        case seconds
    }

    var exercise: String
    var sets: Int
    /// Best set: repetitions or seconds, depending on `unit`.
    var value: Int
    var unit: Unit
}

/// One workout in the journal.
struct JournalEntry: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var date: Date
    var planID: String?
    var durationSeconds: Int
    var results: [ExerciseResult]
    var rating: WorkoutRating?
    var note: String
    /// `true` for a workout added by hand in the Journey. Such workouts count for the
    /// Journey, the streak and the level, but bring no league points. Missing in older files.
    var addedByHand: Bool?

    init(
        id: UUID = UUID(),
        date: Date,
        planID: String?,
        durationSeconds: Int,
        results: [ExerciseResult],
        rating: WorkoutRating? = nil,
        note: String = "",
        addedByHand: Bool? = nil
    ) {
        self.id = id
        self.date = date
        self.planID = planID
        self.durationSeconds = durationSeconds
        self.results = results
        self.rating = rating
        self.note = note
        self.addedByHand = addedByHand
    }

    var isAddedByHand: Bool { addedByHand ?? false }

    var totalSets: Int { results.reduce(0) { $0 + $1.sets } }
}

extension ExerciseResult {
    /// The planned target of a plan exercise as a result with the given number of sets.
    init(_ item: PlanExercise, sets: Int) {
        switch item.target {
        case .reps(let reps): self.init(exercise: item.exercise, sets: sets, value: reps, unit: .reps)
        case .seconds(let seconds): self.init(exercise: item.exercise, sets: sets, value: seconds, unit: .seconds)
        }
    }
}

extension JournalEntry {
    /// Entry for a finished (or ended) workout. Exercises before the current one count
    /// with all their sets, the current one with the sets ticked off. The planned target
    /// is taken as the achieved value; it can be corrected in the entry.
    @MainActor
    init(session: TrainingSession, endedAt: Date) {
        var results: [ExerciseResult] = []
        for (index, step) in session.steps.enumerated() where index <= session.stepIndex {
            let sets = index < session.stepIndex ? step.item.sets : session.completedSets
            if sets > 0 { results.append(ExerciseResult(step.item, sets: sets)) }
        }
        self.init(
            date: session.startedAt,
            planID: session.plan.id,
            durationSeconds: max(0, Int(endedAt.timeIntervalSince(session.startedAt))),
            results: results
        )
    }

    /// Entry added by hand for a plan, filled with the plan's targets.
    init(plan: WorkoutPlan, date: Date) {
        self.init(
            date: date,
            planID: plan.id,
            durationSeconds: plan.estimatedSeconds,
            results: plan.exercises.map { ExerciseResult($0, sets: $0.sets) },
            addedByHand: true
        )
    }
}
