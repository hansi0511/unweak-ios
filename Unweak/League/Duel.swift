import SwiftUI

/// What a duel is about (docs/SOCIAL.md "Duell").
enum DuelKind: String, CaseIterable, Codable, Identifiable, Sendable {
    /// Finished workouts, at most one per day.
    case moreWorkouts
    /// Best plank time in a workout.
    case longestPlank
    /// Reached skill stages; only when both have Pro.
    case moreStages

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .moreWorkouts: "Train more often"
        case .longestPlank: "Longest plank"
        case .moreStages: "More skill stages"
        }
    }

    /// One line under the title when choosing.
    var subtitle: LocalizedStringKey {
        switch self {
        case .moreWorkouts: "Whoever finishes more workouts in 7 days"
        case .longestPlank: "The best time of the week counts"
        case .moreStages: "Whoever reaches more stages this week"
        }
    }

    /// The question on the duel screen.
    var question: LocalizedStringKey {
        switch self {
        case .moreWorkouts: "Who trains more often this week?"
        case .longestPlank: "Who holds the plank longer?"
        case .moreStages: "Who reaches more skill stages?"
        }
    }

    var needsPro: Bool { self == .moreStages }

    /// The exercise whose best time counts for the plank duel.
    static let plankExercise = "plank"
}

/// One side of a duel: score and the days with something that counted, Monday first.
struct DuelSide: Equatable, Codable, Sendable {
    var score: Int
    /// Seven values from the duel's first day on.
    var days: [Bool]
}

enum DuelOutcome: Equatable, Sendable {
    case won
    case lost
    case draw
}

/// A duel between the user and a friend, 7 days long.
struct Duel: Identifiable, Equatable, Codable, Sendable {
    static let duration: TimeInterval = 7 * 86_400
    /// An invitation that is not accepted in this time lapses.
    static let invitationLifetime: TimeInterval = 48 * 3_600
    /// At most this many duels run at the same time.
    static let maximumRunning = 3

    let id: String
    let kind: DuelKind
    let opponent: LeagueOpponent
    let start: Date
    /// The opponent's side as the server reports it.
    var opponentSide: DuelSide

    var end: Date { start.addingTimeInterval(Self.duration) }

    func isRunning(at now: Date) -> Bool { now >= start && now < end }

    /// Whole days left, rounded up.
    func daysLeft(at now: Date) -> Int {
        Int((max(0, end.timeIntervalSince(now)) / 86_400).rounded(.up))
    }

    /// The user's side, from the journal and the reached stages.
    func mySide(entries: [JournalEntry], stageDates: [String: [Date]], calendar: Calendar = .trainingWeek) -> DuelSide {
        DuelRules.side(kind: kind, from: start, entries: entries, stageDates: stageDates, calendar: calendar)
    }

    static func outcome(mine: Int, theirs: Int) -> DuelOutcome {
        if mine > theirs { return .won }
        if mine < theirs { return .lost }
        return .draw
    }
}

/// Rules of duels. Pure functions, so they can be tested.
enum DuelRules {
    /// Whether another duel may be started next to the running ones.
    static func canStart(running: Int) -> Bool {
        running < Duel.maximumRunning
    }

    /// "More skill stages" needs Pro on both sides.
    static func isAvailable(_ kind: DuelKind, meIsPro: Bool, opponentIsPro: Bool) -> Bool {
        !kind.needsPro || (meIsPro && opponentIsPro)
    }

    static func invitationHasLapsed(sentAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(sentAt) >= Duel.invitationLifetime
    }

    /// Score and days of one side over the 7 days from `start`. Only workouts finished
    /// in the app count, as in the league.
    static func side(
        kind: DuelKind,
        from start: Date,
        entries: [JournalEntry],
        stageDates: [String: [Date]],
        calendar: Calendar = .trainingWeek
    ) -> DuelSide {
        let end = start.addingTimeInterval(Duel.duration)
        let inDuel = { (date: Date) in date >= start && date < end }
        let dayIndex = { (date: Date) -> Int in
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: date)).day ?? 0
            return min(max(days, 0), 6)
        }
        var days = Array(repeating: false, count: 7)
        let counting = entries.filter { inDuel($0.date) && LeaguePoints.counts($0) }

        switch kind {
        case .moreWorkouts:
            for entry in counting { days[dayIndex(entry.date)] = true }
            return DuelSide(score: days.filter { $0 }.count, days: days)
        case .longestPlank:
            var best = 0
            for entry in counting {
                for result in entry.results where result.exercise == DuelKind.plankExercise && result.unit == .seconds {
                    best = max(best, result.value)
                    days[dayIndex(entry.date)] = true
                }
            }
            return DuelSide(score: best, days: days)
        case .moreStages:
            let reached = stageDates.values.flatMap { $0 }.filter(inDuel)
            for date in reached { days[dayIndex(date)] = true }
            return DuelSide(score: reached.count, days: days)
        }
    }
}
