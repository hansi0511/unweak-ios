import Foundation
import Observation

/// State of a running workout: which exercise and set is current, the rest countdown
/// and the elapsed time. Times are passed in so the logic is testable.
@MainActor
@Observable
final class TrainingSession {
    struct Step: Hashable {
        let exercise: Exercise
        let item: PlanExercise
    }

    /// What the large button does next.
    enum PrimaryAction: Equatable {
        /// Mark set n (1-based) as done.
        case completeSet(Int)
        case nextExercise
        case finish
    }

    let plan: WorkoutPlan
    let steps: [Step]
    let startedAt: Date

    private(set) var stepIndex = 0
    /// Completed sets of the current exercise.
    private(set) var completedSets = 0
    private(set) var restEndsAt: Date?
    private(set) var finishedAt: Date?

    /// Returns `nil` if the plan has no exercise that exists in the catalog.
    init?(plan: WorkoutPlan, catalog: Catalog, startedAt: Date) {
        let steps = plan.exercises.compactMap { item in
            catalog.exercise(item.exercise).map { Step(exercise: $0, item: item) }
        }
        guard !steps.isEmpty else { return nil }
        self.plan = plan
        self.steps = steps
        self.startedAt = startedAt
    }

    var current: Step { steps[stepIndex] }
    var next: Step? { stepIndex + 1 < steps.count ? steps[stepIndex + 1] : nil }
    var isLastExercise: Bool { stepIndex == steps.count - 1 }
    var isExerciseComplete: Bool { completedSets >= current.item.sets }
    var isFinished: Bool { finishedAt != nil }

    /// 1-based number of the set that is up next (the last set once all are done).
    var currentSetNumber: Int { min(completedSets + 1, current.item.sets) }

    var primaryAction: PrimaryAction {
        if !isExerciseComplete { return .completeSet(completedSets + 1) }
        return isLastExercise ? .finish : .nextExercise
    }

    func completeSet(at now: Date) {
        guard !isFinished, !isExerciseComplete else { return }
        completedSets += 1
        restEndsAt = now.addingTimeInterval(TimeInterval(current.item.rest))
    }

    func goToNextExercise() {
        guard !isFinished, !isLastExercise else { return }
        stepIndex += 1
        completedSets = 0
    }

    func finish(at now: Date) {
        guard !isFinished else { return }
        finishedAt = now
        restEndsAt = nil
    }

    /// Runs the primary action.
    func performPrimaryAction(at now: Date) {
        switch primaryAction {
        case .completeSet: completeSet(at: now)
        case .nextExercise: goToNextExercise()
        case .finish: finish(at: now)
        }
    }

    /// Seconds of rest left, 0 when no rest is running.
    func restRemaining(at now: Date) -> Int {
        guard let restEndsAt else { return 0 }
        return max(0, Int(restEndsAt.timeIntervalSince(now).rounded(.up)))
    }

    /// Whole seconds since the start (until the end once finished).
    func elapsedSeconds(at now: Date) -> Int {
        max(0, Int((finishedAt ?? now).timeIntervalSince(startedAt)))
    }
}

enum TimeText {
    /// "m:ss", or "h:mm:ss" from one hour on.
    static func clock(_ totalSeconds: Int) -> String {
        let seconds = max(0, totalSeconds)
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
