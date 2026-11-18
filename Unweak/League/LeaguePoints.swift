import Foundation

/// Points of one league week (docs/SOCIAL.md "Punkte"). Later the server credits them;
/// the app uses the same rules to show its own points until then.
///
/// Only what is hard to fake counts: workouts finished in the app (not added by hand)
/// of at least 10 minutes, the weekly target, reached skill stages and the streak.
enum LeaguePoints {
    static let perWorkout = 10
    static let weeklyTargetBonus = 20
    static let perSkillStage = 30
    static let perStreakWeek = 5
    /// Workouts shorter than this bring no points.
    static let minimumWorkoutSeconds = 10 * 60

    struct Breakdown: Equatable, Sendable {
        /// Days with a counting workout, at most one per day.
        let workoutDays: Int
        let reachedWeeklyTarget: Bool
        /// Skills with a stage reached this week, at most one per skill.
        let skillsWithNewStage: Int
        /// Weeks in a row before this week, credited on Monday.
        let streakWeeks: Int

        var total: Int {
            workoutDays * LeaguePoints.perWorkout
                + (reachedWeeklyTarget ? LeaguePoints.weeklyTargetBonus : 0)
                + skillsWithNewStage * LeaguePoints.perSkillStage
                + streakWeeks * LeaguePoints.perStreakWeek
        }
    }

    /// Whether a journal entry can bring points.
    static func counts(_ entry: JournalEntry) -> Bool {
        !entry.isAddedByHand && entry.durationSeconds >= minimumWorkoutSeconds
    }

    /// - Parameters:
    ///   - stageDates: When each stage of each skill was reached, from `UserData`.
    ///   - calendar: The user's calendar: decides what a calendar day is.
    static func breakdown(
        for week: LeagueWeek,
        entries: [JournalEntry],
        weeklyTarget: Int,
        stageDates: [String: [Date]],
        calendar: Calendar = .trainingWeek
    ) -> Breakdown {
        let counting = entries.filter { week.contains($0.date) && counts($0) }
        let days = Set(counting.map { calendar.startOfDay(for: $0.date) })
        let skills = stageDates.values.filter { dates in dates.contains { week.contains($0) } }.count
        // The streak counts every workout, also those added by hand.
        let streak = JournalStats(entries: entries, calendar: calendar)
            .streak(at: week.start.addingTimeInterval(-1), target: weeklyTarget)
        return Breakdown(
            workoutDays: days.count,
            reachedWeeklyTarget: counting.count >= max(1, weeklyTarget),
            skillsWithNewStage: skills,
            streakWeeks: streak
        )
    }

    /// The moment the week's points were complete: the last counting event, or the
    /// start of the week. Used between equal points.
    static func reachedAt(
        for week: LeagueWeek,
        entries: [JournalEntry],
        stageDates: [String: [Date]]
    ) -> Date {
        let workoutDates = entries.filter { week.contains($0.date) && counts($0) }.map(\.date)
        let stageMoments = stageDates.values.flatMap { $0 }.filter { week.contains($0) }
        return (workoutDates + stageMoments).max() ?? week.start
    }

    /// Whether the user takes part in the league of `week`: only after a counting workout
    /// in the week before, or once they train again in this week.
    static func takesPart(in week: LeagueWeek, entries: [JournalEntry]) -> Bool {
        let previous = week.previous
        return entries.contains { counts($0) && (previous.contains($0.date) || week.contains($0.date)) }
    }
}
