import Foundation

/// Something worth sharing, as plain data. `ShareCardView` turns it into an image.
enum ShareContent: Hashable, Identifiable {
    case workout(Workout)
    case record(Record)
    case achievement(Achievement)
    case streak(Streak)
    case skill(Skill)

    var id: Self { self }

    struct Workout: Hashable {
        /// Catalog name key, or the custom workout's own name.
        let title: Title
        let date: Date
        let durationSeconds: Int
        let exercises: Int
        let sets: Int
        let record: Record?
        let animation: StickyAnimation
    }

    struct Record: Hashable {
        let exerciseNameKey: String
        let value: Int
        let unit: ExerciseResult.Unit
        let animation: StickyAnimation
    }

    struct Streak: Hashable {
        let weeks: Int
        let workoutsThisWeek: Int
        let target: Int
        /// Monday to Sunday: trained or not.
        let days: [Bool]
    }

    struct Skill: Hashable {
        enum State: Hashable {
            /// Reached stages of a skill with stages, with the name of the last reached one.
            case stages(reached: Int, count: Int, lastStageKey: String?)
            /// Best time of a time skill and its target.
            case time(bestSeconds: Int, targetSeconds: Int)
        }

        let nameKey: String
        let state: State
        /// Filled progress segments out of `GoalProgress.segmentCount`.
        let filledSegments: Int
        let animation: StickyAnimation
    }

    enum Title: Hashable {
        case catalog(String)
        case custom(String)
        case generic
    }

    /// The pose drawn large on the card.
    var animation: StickyAnimation {
        switch self {
        case .workout(let workout): workout.animation
        case .record(let record): record.animation
        case .achievement: .frontLever
        case .streak: .pullUp
        case .skill(let skill): skill.animation
        }
    }
}

extension ShareContent {
    /// A finished workout from the journal; its best record (if any) is shown with it.
    static func workoutCard(
        entry: JournalEntry,
        plan: WorkoutPlan?,
        records: [ExerciseResult],
        catalog: Catalog
    ) -> ShareContent {
        let title: Title
        if let customName = plan?.customName {
            title = .custom(customName)
        } else if let plan {
            title = .catalog(plan.nameKey)
        } else {
            title = .generic
        }
        let firstExercise = entry.results.first.flatMap { catalog.exercise($0.exercise) }
        return .workout(Workout(
            title: title,
            date: entry.date,
            durationSeconds: entry.durationSeconds,
            exercises: entry.results.count,
            sets: entry.totalSets,
            record: records.first.flatMap { recordData(from: $0, catalog: catalog) },
            animation: firstExercise?.animation ?? .pushUp
        ))
    }

    static func recordData(from result: ExerciseResult, catalog: Catalog) -> Record? {
        guard let exercise = catalog.exercise(result.exercise) else { return nil }
        return Record(exerciseNameKey: exercise.nameKey, value: result.value, unit: result.unit, animation: exercise.animation)
    }

    static func streakCard(week: WeekSummary, weeks: Int) -> ShareContent {
        .streak(Streak(
            weeks: weeks,
            workoutsThisWeek: week.workouts,
            target: week.target,
            days: week.days.map(\.trained)
        ))
    }

    static func skillCard(_ progress: GoalProgress, catalog: Catalog) -> ShareContent {
        let goal = progress.goal
        let state: Skill.State
        switch goal.kind {
        case .stages(let count):
            let reached = min(progress.reachedStages, count)
            let keys = goal.stageKeys
            state = .stages(reached: reached, count: count, lastStageKey: reached > 0 && reached <= keys.count ? keys[reached - 1] : nil)
        case .time(let target):
            state = .time(bestSeconds: progress.bestSeconds ?? 0, targetSeconds: target)
        }
        return .skill(Skill(
            nameKey: goal.nameKey,
            state: state,
            filledSegments: progress.filledSegments,
            animation: catalog.exercise(goal.exercise)?.animation ?? .frontLever
        ))
    }
}

/// Image formats for sharing.
enum ShareFormat: String, CaseIterable, Identifiable {
    /// 9:16, Instagram and Facebook stories.
    case story
    /// 4:5, feed posts on Instagram, Facebook and X.
    case post

    var id: Self { self }

    /// Card size in points; rendered at 3× (1080 × 1920 or 1080 × 1350 pixels).
    var size: CGSize {
        switch self {
        case .story: CGSize(width: 360, height: 640)
        case .post: CGSize(width: 360, height: 450)
        }
    }

    static let renderScale: CGFloat = 3
}
