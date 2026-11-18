import Foundation
import Observation
import SwiftUI

/// The user's group in the running week, ranked.
struct LeagueStanding: Equatable {
    let week: LeagueWeek
    let league: League
    /// Ranked: first place first.
    let members: [LeagueMember]
    let myPoints: LeaguePoints.Breakdown

    var groupSize: Int { members.count }

    /// The user's place, 1 for the first.
    var myPlace: Int? {
        members.firstIndex { $0.isMe }.map { $0 + 1 }
    }

    var myZone: LeagueZone? {
        myPlace.map { LeagueRules.zone(place: $0, groupSize: groupSize) }
    }

    var movingPlaces: Int { LeagueRules.movingPlaces(groupSize: groupSize) }
}

/// How the last week ended, shown once from Monday on.
struct WeekResult: Identifiable, Equatable {
    let week: LeagueWeek
    let place: Int
    let groupSize: Int
    let outcome: WeekOutcome
    /// The league from Monday on.
    let newLeague: League
    /// The first three, first place first.
    let podium: [LeagueMember]

    var id: String { week.id }
}

/// Why a name is reported.
enum ReportReason: String, CaseIterable, Identifiable, Sendable {
    case offensive
    case inappropriate
    case other

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .offensive: "Offensive"
        case .inappropriate: "Inappropriate"
        case .other: "Other"
        }
    }
}

/// League and duels. Until the server exists (step 6), the other people are sample data
/// from the mockup and the user's own points come from the journal with the league rules.
/// The user's choices (name, taking part, blocked people, duels) are kept on the device.
@MainActor
@Observable
final class LeagueStore {
    /// `true` while the groups and duels are sample data; the screens say so.
    let usesSampleData = true

    private(set) var displayName: String?
    private(set) var displayNameChangedAt: Date?
    private(set) var isTakingPart: Bool
    /// The league of the running week.
    private(set) var league: League
    private(set) var blocked: [LeagueOpponent]
    private(set) var duels: [Duel]
    private(set) var reportedIDs: Set<String>
    /// Set when a week has ended and its result is not shown yet.
    var pendingResult: WeekResult?

    private var evaluatedWeek: String?
    private let defaults: UserDefaults

    private enum Key {
        static let displayName = "league.displayName"
        static let displayNameChangedAt = "league.displayNameChangedAt"
        static let isTakingPart = "league.isTakingPart"
        static let league = "league.current"
        static let blocked = "league.blocked"
        static let duels = "league.duels"
        static let reported = "league.reported"
        static let evaluatedWeek = "league.evaluatedWeek"
        static let seededSampleDuel = "league.seededSampleDuel"
    }

    init(defaults: UserDefaults = .standard, now: Date = .now) {
        self.defaults = defaults
        displayName = defaults.string(forKey: Key.displayName)
        displayNameChangedAt = defaults.object(forKey: Key.displayNameChangedAt) as? Date
        isTakingPart = defaults.object(forKey: Key.isTakingPart) as? Bool ?? true
        league = defaults.string(forKey: Key.league).flatMap(League.init(rawValue:)) ?? .bronze
        blocked = Self.decode([LeagueOpponent].self, from: defaults.data(forKey: Key.blocked)) ?? []
        duels = Self.decode([Duel].self, from: defaults.data(forKey: Key.duels)) ?? []
        reportedIDs = Set(defaults.stringArray(forKey: Key.reported) ?? [])
        evaluatedWeek = defaults.string(forKey: Key.evaluatedWeek)
        if !defaults.bool(forKey: Key.seededSampleDuel) {
            duels.append(SampleLeague.duel(startingIn: LeagueWeek(containing: now)))
            defaults.set(true, forKey: Key.seededSampleDuel)
            save(duels, forKey: Key.duels)
        }
    }

    /// In-memory store with sample data, for Xcode Previews.
    static func preview(named name: String? = "jonas.k") -> LeagueStore {
        let defaults = UserDefaults(suiteName: "unweak.preview.league") ?? .standard
        defaults.removePersistentDomain(forName: "unweak.preview.league")
        defaults.set(League.silver.rawValue, forKey: Key.league)
        if let name { defaults.set(name, forKey: Key.displayName) }
        return LeagueStore(defaults: defaults)
    }

    // MARK: Standing

    /// The user's group in the week of `now`, `nil` if they do not take part this week.
    func standing(
        entries: [JournalEntry],
        stageDates: [String: [Date]],
        weeklyTarget: Int,
        avatar: LeagueAvatar,
        now: Date
    ) -> LeagueStanding? {
        let week = LeagueWeek(containing: now)
        guard isTakingPart, LeaguePoints.takesPart(in: week, entries: entries) else { return nil }
        return standing(in: week, league: league, entries: entries, stageDates: stageDates,
                        weeklyTarget: weeklyTarget, avatar: avatar, share: week.elapsedShare(at: now))
    }

    private func standing(
        in week: LeagueWeek,
        league: League,
        entries: [JournalEntry],
        stageDates: [String: [Date]],
        weeklyTarget: Int,
        avatar: LeagueAvatar,
        share: Double
    ) -> LeagueStanding {
        let points = LeaguePoints.breakdown(for: week, entries: entries, weeklyTarget: weeklyTarget, stageDates: stageDates)
        let me = LeagueMember(
            id: "me",
            name: displayName ?? "",
            avatar: avatar,
            points: points.total,
            reachedAt: LeaguePoints.reachedAt(for: week, entries: entries, stageDates: stageDates),
            isMe: true
        )
        let blockedIDs = Set(blocked.map(\.id))
        let others = SampleLeague.rivals(in: week, share: share).filter { !blockedIDs.contains($0.id) }
        return LeagueStanding(week: week, league: league, members: LeagueRules.ranked(others + [me]), myPoints: points)
    }

    /// Checks once per week whether the last week has ended: then its result is shown,
    /// the league changes and first place unlocks the crown. Duels that have ended are
    /// counted. Call when the app comes to the front.
    func refresh(
        store: UserDataStore,
        weeklyTarget: Int,
        avatar: LeagueAvatar,
        now: Date
    ) {
        countFinishedDuels(store: store, now: now)

        let week = LeagueWeek(containing: now)
        guard evaluatedWeek != week.id else { return }
        defer {
            evaluatedWeek = week.id
            defaults.set(week.id, forKey: Key.evaluatedWeek)
        }
        // The first start only remembers the week.
        guard evaluatedWeek != nil, isTakingPart else { return }
        let previous = week.previous
        let entries = store.entries
        guard LeaguePoints.takesPart(in: previous, entries: entries) else { return }

        let last = standing(in: previous, league: league, entries: entries, stageDates: store.data.stageReachedDates,
                            weeklyTarget: weeklyTarget, avatar: avatar, share: 1)
        guard let place = last.myPlace else { return }
        let (outcome, newLeague) = LeagueRules.outcome(place: place, groupSize: last.groupSize, league: last.league)
        if place == 1 { store.addLeagueWin(last.league) }
        league = newLeague
        defaults.set(newLeague.rawValue, forKey: Key.league)
        pendingResult = WeekResult(
            week: previous,
            place: place,
            groupSize: last.groupSize,
            outcome: outcome,
            newLeague: newLeague,
            podium: Array(last.members.prefix(3))
        )
    }

    // MARK: Name and taking part

    /// Sets the display name; returns why it cannot be used, or `nil` when it is saved.
    @discardableResult
    func setDisplayName(_ name: String, now: Date = .now) -> DisplayNameProblem? {
        let name = DisplayName.normalized(name)
        if let problem = DisplayName.problem(with: name) { return problem }
        guard name != displayName else { return nil }
        guard DisplayName.canChange(lastChange: displayNameChangedAt, now: now) else { return nil }
        // Choosing the first name does not start the 30 days.
        if displayName != nil {
            displayNameChangedAt = now
            defaults.set(now, forKey: Key.displayNameChangedAt)
        }
        displayName = name
        defaults.set(name, forKey: Key.displayName)
        return nil
    }

    func setTakingPart(_ value: Bool) {
        isTakingPart = value
        defaults.set(value, forKey: Key.isTakingPart)
    }

    // MARK: Report and block

    func report(_ memberID: String, reason: ReportReason) {
        // Sent to the server with step 6; until then only remembered.
        reportedIDs.insert(memberID)
        defaults.set(Array(reportedIDs), forKey: Key.reported)
    }

    func isReported(_ memberID: String) -> Bool { reportedIDs.contains(memberID) }

    /// The blocked person no longer appears in rankings and cannot challenge the user.
    func block(_ member: LeagueMember) {
        guard !member.isMe, !blocked.contains(where: { $0.id == member.id }) else { return }
        blocked.append(LeagueOpponent(id: member.id, name: member.name, avatar: member.avatar, isPro: false))
        save(blocked, forKey: Key.blocked)
    }

    func unblock(_ id: String) {
        blocked.removeAll { $0.id == id }
        save(blocked, forKey: Key.blocked)
    }

    // MARK: Duels

    func runningDuels(at now: Date) -> [Duel] {
        let blockedIDs = Set(blocked.map(\.id))
        return duels.filter { $0.isRunning(at: now) && !blockedIDs.contains($0.opponent.id) }
    }

    /// People from earlier duels, without blocked ones.
    var friends: [LeagueOpponent] {
        let blockedIDs = Set(blocked.map(\.id))
        var seen = Set<String>()
        let fromDuels = duels.map(\.opponent) + SampleLeague.friends
        return fromDuels.filter { !blockedIDs.contains($0.id) && seen.insert($0.id).inserted }
    }

    /// Starts a duel. Until the server exists the friend accepts at once.
    @discardableResult
    func challenge(_ opponent: LeagueOpponent, kind: DuelKind, now: Date = .now) -> Duel? {
        guard DuelRules.canStart(running: runningDuels(at: now).count) else { return nil }
        let duel = Duel(
            id: UUID().uuidString,
            kind: kind,
            opponent: opponent,
            start: now,
            opponentSide: DuelSide(score: 0, days: Array(repeating: false, count: 7))
        )
        duels.append(duel)
        save(duels, forKey: Key.duels)
        return duel
    }

    private func countFinishedDuels(store: UserDataStore, now: Date) {
        let finished = duels.filter { now >= $0.end }
        guard !finished.isEmpty else { return }
        for duel in finished {
            let mine = duel.mySide(entries: store.entries, stageDates: store.data.stageReachedDates).score
            if Duel.outcome(mine: mine, theirs: duel.opponentSide.score) == .won {
                store.addDuelWin()
            }
        }
        duels.removeAll { now >= $0.end }
        save(duels, forKey: Key.duels)
    }

    // MARK: Saving

    private func save<Value: Encodable>(_ value: Value, forKey key: String) {
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
    }

    private static func decode<Value: Decodable>(_ type: Value.Type, from data: Data?) -> Value? {
        data.flatMap { try? JSONDecoder().decode(type, from: $0) }
    }
}

extension LeagueAvatar {
    /// The user's own avatar as others see it.
    @MainActor
    static func mine(store: UserDataStore, catalog: Catalog, weeklyTarget: Int) -> LeagueAvatar {
        let stats = JournalStats(entries: store.entries)
        let unlocks = AvatarUnlocks(stats: stats, catalog: catalog, weeklyTarget: weeklyTarget,
                                    leagueWins: Set(store.data.leagueWins)) {
            store.reachedStages(of: $0)
        }
        let style = store.data.avatar
        return LeagueAvatar(style: style, body: unlocks.body(for: style), extra: unlocks.extra(for: style))
    }
}

/// Sample people and duels from the mockup, until the server delivers real ones.
enum SampleLeague {
    private static func avatar(_ body: AvatarBody, _ color: AvatarColor, _ extra: AvatarExtra? = nil) -> LeagueAvatar {
        LeagueAvatar(style: AvatarStyle(color: color, extraColor: .mono), body: body, extra: extra)
    }

    /// Name, points at the end of the week and avatar.
    private static let people: [(String, Int, LeagueAvatar)] = [
        ("k.lever", 212, avatar(.trained, .cyan, .visor)),
        ("mara_moves", 186, avatar(.trained, .pink, .headband)),
        ("bar.joe", 171, avatar(.athlete, .orange, .cap)),
        ("tim.calis", 149, avatar(.athlete, .violet)),
        ("nora.fit", 140, avatar(.athlete, .cyan)),
        ("lukas_w", 131, avatar(.athlete, .red, .cap)),
        ("sarah.k", 120, avatar(.start, .pink)),
        ("ben_moves", 112, avatar(.athlete, .lime)),
        ("ella.str", 104, avatar(.start, .orange, .headband)),
        ("jonas.h", 96, avatar(.start, .violet)),
        ("mia_lev", 90, avatar(.athlete, .cyan)),
        ("paul.p", 81, avatar(.start, .mono)),
        ("lena.g", 74, avatar(.start, .red)),
        ("max.bar", 66, avatar(.start, .lime)),
        ("anna_up", 52, avatar(.start, .pink)),
        ("felix.r", 40, avatar(.start, .orange)),
        ("tom.k", 30, avatar(.start, .violet)),
        ("julia.m", 20, avatar(.start, .cyan)),
        ("nico_b", 10, avatar(.start, .mono)),
    ]

    /// The 19 others of the group; their points grow over the week.
    static func rivals(in week: LeagueWeek, share: Double) -> [LeagueMember] {
        let share = max(0.15, min(1, share))
        return people.enumerated().map { index, person in
            LeagueMember(
                id: person.0,
                name: person.0,
                avatar: person.2,
                points: Int((Double(person.1) * share).rounded()),
                reachedAt: week.start.addingTimeInterval(Double(index + 1) * 3_600),
                isMe: false
            )
        }
    }

    static var friends: [LeagueOpponent] {
        [opponent(at: 1, isPro: true), opponent(at: 2, isPro: false)]
    }

    private static func opponent(at index: Int, isPro: Bool) -> LeagueOpponent {
        let person = people[index]
        return LeagueOpponent(id: person.0, name: person.0, avatar: person.2, isPro: isPro)
    }

    /// A running duel against mara_moves from Monday of the week: she trained on Tuesday
    /// and Thursday.
    static func duel(startingIn week: LeagueWeek) -> Duel {
        Duel(
            id: "sample-duel",
            kind: .moreWorkouts,
            opponent: opponent(at: 1, isPro: true),
            start: week.start,
            opponentSide: DuelSide(score: 2, days: [false, true, false, true, false, false, false])
        )
    }
}
