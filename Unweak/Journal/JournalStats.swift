import Foundation

/// Weekly target: number of training days chosen for reminders (step 5), 3 until set.
enum WeeklyTarget {
    static let defaultValue = 3
    /// `UserDefaults` key of the chosen reminder weekdays (array of 1...7). Written in step 5.
    static let weekdaysKey = "reminderWeekdays"

    static func current(in defaults: UserDefaults = .standard) -> Int {
        let days = defaults.array(forKey: weekdaysKey) as? [Int] ?? []
        return days.isEmpty ? defaultValue : days.count
    }
}

/// One day of the training week (shown on the streak share card).
struct WeekDay: Equatable {
    let date: Date
    let trained: Bool
    let isToday: Bool
}

struct WeekSummary: Equatable {
    /// Monday to Sunday.
    let days: [WeekDay]
    let workouts: Int
    let target: Int
}

struct MonthSummary: Equatable {
    let workouts: Int
    let seconds: Int
    let records: Int
}

/// Progress towards an achievement.
struct AchievementProgress: Equatable {
    let achievement: Achievement
    let value: Int

    var isAchieved: Bool { value >= achievement.threshold }
}

extension Array where Element == AchievementProgress {
    /// Achieved ones first, then the open ones, each in catalog order.
    var achievedFirst: [AchievementProgress] {
        filter(\.isAchieved) + filter { !$0.isAchieved }
    }
}

/// State of the active goal.
struct GoalProgress: Equatable {
    let goal: Goal
    /// Reached stages (skill goal) or 0.
    let reachedStages: Int
    /// Best time of the linked exercise (time goal).
    let bestSeconds: Int?

    static let segmentCount = 5

    /// Filled segments out of `segmentCount`.
    var filledSegments: Int {
        switch goal.kind {
        case .stages: return min(reachedStages, Self.segmentCount)
        case .time(let target):
            guard target > 0, let bestSeconds else { return 0 }
            return min(Self.segmentCount, bestSeconds * Self.segmentCount / target)
        }
    }

    var isComplete: Bool {
        switch goal.kind {
        case .stages(let count): reachedStages >= count
        case .time(let target): (bestSeconds ?? 0) >= target
        }
    }

    /// Index of the stage the user is at: the next one to reach, the last one once all
    /// are reached; `nil` for time goals.
    var currentStageIndex: Int? {
        guard case .stages(let count) = goal.kind, count > 0 else { return nil }
        return min(max(reachedStages, 0), count - 1)
    }

    /// Key of the stage that is worked on next, `nil` once all are reached or for time goals.
    var nextStageKey: String? {
        let keys = goal.stageKeys
        return reachedStages < keys.count ? keys[reachedStages] : nil
    }
}

/// Evaluations of the journal. Pure functions; the calendar is passed in for tests.
struct JournalStats {
    let entries: [JournalEntry]
    let calendar: Calendar

    init(entries: [JournalEntry], calendar: Calendar = .trainingWeek) {
        self.entries = entries.sorted { ($0.date, $0.id.uuidString) < ($1.date, $1.id.uuidString) }
        self.calendar = calendar
    }

    // MARK: Week and streak

    func startOfWeek(_ date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    func workouts(inWeekOf date: Date) -> Int {
        let start = startOfWeek(date)
        guard let end = calendar.date(byAdding: .day, value: 7, to: start) else { return 0 }
        return entries.filter { $0.date >= start && $0.date < end }.count
    }

    func week(containing now: Date, target: Int) -> WeekSummary {
        let start = startOfWeek(now)
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }.map { day in
            WeekDay(
                date: day,
                trained: entries.contains { calendar.isDate($0.date, inSameDayAs: day) },
                isToday: calendar.isDate(day, inSameDayAs: now)
            )
        }
        return WeekSummary(days: days, workouts: workouts(inWeekOf: now), target: target)
    }

    /// Weeks in a row with the target reached, counted back from the last finished week.
    /// The running week counts as soon as its target is reached.
    func streak(at now: Date, target: Int) -> Int {
        let target = max(1, target)
        var week = startOfWeek(now)
        var count = 0
        if workouts(inWeekOf: week) >= target { count += 1 }
        while let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: week),
              workouts(inWeekOf: previous) >= target {
            count += 1
            week = previous
        }
        return count
    }

    /// Longest run of weeks with the target reached, at any time.
    func longestStreak(target: Int) -> Int {
        let target = max(1, target)
        guard let first = entries.first, let last = entries.last else { return 0 }
        var week = startOfWeek(first.date)
        let lastWeek = startOfWeek(last.date)
        var longest = 0
        var current = 0
        while week <= lastWeek {
            if workouts(inWeekOf: week) >= target {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: week) else { break }
            week = next
        }
        return longest
    }

    // MARK: Records

    /// Best value of an exercise before `date` (exclusive), or in all entries for `nil`.
    func bestValue(of exercise: String, unit: ExerciseResult.Unit, before entry: JournalEntry? = nil) -> Int? {
        var best: Int?
        for candidate in entries {
            if let entry, !isBefore(candidate, entry) { continue }
            for result in candidate.results where result.exercise == exercise && result.unit == unit {
                best = max(best ?? result.value, result.value)
            }
        }
        return best
    }

    /// Results of `entry` that beat every earlier value of the same exercise.
    /// The first time an exercise is done is not a record.
    func records(in entry: JournalEntry) -> [ExerciseResult] {
        entry.results.filter { result in
            guard let previous = bestValue(of: result.exercise, unit: result.unit, before: entry) else { return false }
            return result.value > previous
        }
    }

    private func isBefore(_ a: JournalEntry, _ b: JournalEntry) -> Bool {
        (a.date, a.id.uuidString) < (b.date, b.id.uuidString)
    }

    // MARK: Month

    func month(containing date: Date) -> MonthSummary {
        let inMonth = entries.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
        return MonthSummary(
            workouts: inMonth.count,
            seconds: inMonth.reduce(0) { $0 + $1.durationSeconds },
            records: inMonth.reduce(0) { $0 + records(in: $1).count }
        )
    }

    // MARK: Achievements, goal, next workout

    func progress(of achievement: Achievement, target: Int) -> AchievementProgress {
        let value: Int
        switch achievement.kind {
        case .workouts:
            value = entries.count
        case .reps:
            value = achievement.exercise.flatMap { bestValue(of: $0, unit: .reps) } ?? 0
        case .seconds:
            value = achievement.exercise.flatMap { bestValue(of: $0, unit: .seconds) } ?? 0
        case .streak:
            value = longestStreak(target: target)
        }
        return AchievementProgress(achievement: achievement, value: value)
    }

    func goalProgress(_ goal: Goal, reachedStages: Int) -> GoalProgress {
        GoalProgress(
            goal: goal,
            reachedStages: reachedStages,
            bestSeconds: bestValue(of: goal.exercise, unit: .seconds)
        )
    }

    /// The plan trained longest ago; plans never trained come first, in catalog order.
    /// Workouts of the active skill (`preferred`) the user may train are suggested first,
    /// otherwise the general workouts.
    func nextWorkout(
        in catalog: Catalog,
        access: Access = Access(isPro: false),
        preferring preferred: [String] = []
    ) -> WorkoutPlan? {
        let trainable = catalog.plans.filter { access.canTrain($0) }
        let fromSkill = trainable.filter { preferred.contains($0.id) }
        let general = trainable.filter { $0.category != .skill }
        return leastRecentlyTrained(fromSkill.isEmpty ? general : fromSkill)
    }

    private func leastRecentlyTrained(_ candidates: [WorkoutPlan]) -> WorkoutPlan? {
        func lastTrained(_ plan: WorkoutPlan) -> Date? {
            entries.last { $0.planID == plan.id }?.date
        }
        return candidates.enumerated().min { a, b in
            switch (lastTrained(a.element), lastTrained(b.element)) {
            case (nil, nil): return a.offset < b.offset
            case (nil, _): return true
            case (_, nil): return false
            case let (dateA?, dateB?): return dateA < dateB || (dateA == dateB && a.offset < b.offset)
            }
        }?.element
    }
}

extension Calendar {
    /// Weeks run Monday to Sunday (ISO 8601), in the user's time zone.
    static var trainingWeek: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }
}
