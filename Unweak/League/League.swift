import SwiftUI

/// The four leagues of the weekly league (docs/SOCIAL.md). New users start in Bronze.
enum League: String, CaseIterable, Codable, Identifiable, Comparable, Sendable {
    case bronze
    case silver
    case gold
    case diamond

    var id: String { rawValue }

    /// "Silver League".
    var name: LocalizedStringKey {
        switch self {
        case .bronze: "Bronze League"
        case .silver: "Silver League"
        case .gold: "Gold League"
        case .diamond: "Diamond League"
        }
    }

    /// "Silver", for the list of leagues.
    var shortName: LocalizedStringKey {
        switch self {
        case .bronze: "Bronze"
        case .silver: "Silver"
        case .gold: "Gold"
        case .diamond: "Diamond"
        }
    }

    /// The prize for first place: a crown in the league's color.
    var prize: AvatarExtra {
        switch self {
        case .bronze: .bronzeCrown
        case .silver: .silverCrown
        case .gold: .goldCrown
        case .diamond: .diamondCrown
        }
    }

    var color: Color { Color(hex: hex) }

    var hex: UInt32 {
        switch self {
        case .bronze: 0xB98A5E
        case .silver: 0xC9D3DB
        case .gold: 0xFFD36B
        case .diamond: 0x5CE1FF
        }
    }

    /// The league after moving up; Diamond stays Diamond.
    var promoted: League {
        Self.allCases.first { $0 > self } ?? self
    }

    /// The league after moving down; Bronze stays Bronze.
    var relegated: League {
        Self.allCases.last { $0 < self } ?? self
    }

    private var order: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    static func < (lhs: League, rhs: League) -> Bool { lhs.order < rhs.order }
}

/// Where a place in the ranking stands at the moment.
enum LeagueZone: Equatable, Sendable {
    case promotion
    case middle
    case relegation

    var title: LocalizedStringKey {
        switch self {
        case .promotion: "Promotion zone"
        case .middle: "Midfield"
        case .relegation: "Relegation zone"
        }
    }
}

/// How a week ended.
enum WeekOutcome: Hashable, Sendable {
    case promoted
    case stayed
    case relegated

    var headline: LocalizedStringKey {
        switch self {
        case .promoted: "Promoted!"
        case .stayed: "League kept"
        case .relegated: "Relegated"
        }
    }
}

/// The rules of the weekly league. Pure functions, so they can be tested; the server
/// applies the same rules later.
enum LeagueRules {
    /// Groups are drawn with this many people where there are enough users.
    static let targetGroupSize = 20
    /// Smallest group when a league has few users.
    static let minimumGroupSize = 5

    /// Places that move up, and places that move down: a quarter of the group, rounded
    /// down, at least 1. 5 in a group of 20.
    static func movingPlaces(groupSize: Int) -> Int {
        max(1, groupSize / 4)
    }

    /// Zone of a place (1 is the first) in a group of `groupSize`.
    static func zone(place: Int, groupSize: Int) -> LeagueZone {
        let moving = movingPlaces(groupSize: groupSize)
        if place <= moving { return .promotion }
        if place > groupSize - moving { return .relegation }
        return .middle
    }

    /// What happens at the end of the week. Diamond cannot rise, Bronze cannot fall:
    /// there the place keeps the league.
    static func outcome(place: Int, groupSize: Int, league: League) -> (WeekOutcome, League) {
        switch zone(place: place, groupSize: groupSize) {
        case .promotion where league.promoted != league:
            return (.promoted, league.promoted)
        case .relegation where league.relegated != league:
            return (.relegated, league.relegated)
        default:
            return (.stayed, league)
        }
    }

    /// Highest points first; with equal points whoever reached them first.
    static func ranked(_ members: [LeagueMember]) -> [LeagueMember] {
        members.sorted { a, b in
            if a.points != b.points { return a.points > b.points }
            if a.reachedAt != b.reachedAt { return a.reachedAt < b.reachedAt }
            return a.id < b.id
        }
    }
}

/// A league week: Monday 00:00 to Sunday 24:00 in UTC, the same for everyone.
struct LeagueWeek: Equatable, Hashable, Sendable {
    let start: Date
    let end: Date

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    init(containing date: Date) {
        let calendar = Self.calendar
        let interval = calendar.dateInterval(of: .weekOfYear, for: date)
        start = interval?.start ?? date
        end = interval?.end ?? date.addingTimeInterval(7 * 86_400)
    }

    var previous: LeagueWeek { LeagueWeek(containing: start.addingTimeInterval(-86_400)) }

    /// ISO week number, e.g. 46.
    var number: Int { Self.calendar.component(.weekOfYear, from: start) }

    /// Stable identifier such as "2026-W46".
    var id: String {
        let calendar = Self.calendar
        let year = calendar.component(.yearForWeekOfYear, from: start)
        return "\(year)-W\(number)"
    }

    func contains(_ date: Date) -> Bool { date >= start && date < end }

    /// Whole days left, rounded up: 2 on Friday afternoon, 1 on Sunday.
    func daysLeft(at now: Date) -> Int {
        let seconds = max(0, end.timeIntervalSince(now))
        return Int((seconds / 86_400).rounded(.up))
    }

    /// Share of the week that has passed, 0...1.
    func elapsedShare(at now: Date) -> Double {
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 1 }
        return min(1, max(0, now.timeIntervalSince(start) / total))
    }
}

/// How another person looks in rankings and duels: their avatar, nothing else.
struct LeagueAvatar: Equatable, Codable, Sendable {
    var style: AvatarStyle
    var body: AvatarBody
    var extra: AvatarExtra?
}

/// Someone in a league group. Only the display name, the avatar and the points are visible.
struct LeagueMember: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let avatar: LeagueAvatar
    let points: Int
    /// When the points were reached; decides between equal points.
    let reachedAt: Date
    let isMe: Bool
}

/// Someone the user can challenge: a person from an earlier duel.
struct LeagueOpponent: Identifiable, Equatable, Codable, Sendable {
    let id: String
    let name: String
    let avatar: LeagueAvatar
    /// Needed for the duel kind "More skill stages".
    let isPro: Bool
}
