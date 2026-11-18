import SwiftUI

/// Color of the avatar figure or its extra: the six accent colors plus white.
enum AvatarColor: String, CaseIterable, Codable, Identifiable, Sendable {
    case lime
    case cyan
    case orange
    case red
    case pink
    case violet
    case mono

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .lime: Accent.lime.color
        case .cyan: Accent.cyan.color
        case .orange: Accent.orange.color
        case .red: Accent.red.color
        case .pink: Accent.pink.color
        case .violet: Accent.violet.color
        case .mono: Theme.text
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .lime: Accent.lime.name
        case .cyan: Accent.cyan.name
        case .orange: Accent.orange.name
        case .red: Accent.red.name
        case .pink: Accent.pink.name
        case .violet: Accent.violet.name
        case .mono: "Mono"
        }
    }
}

/// Background behind the avatar.
enum AvatarBackground: String, CaseIterable, Codable, Identifiable, Sendable {
    /// The app's dark surface.
    case dark
    /// Deep violet night.
    case night
    /// Filled with the figure color, the figure drawn dark.
    case inverted

    var id: String { rawValue }

    var name: LocalizedStringKey {
        switch self {
        case .dark: "Dark"
        case .night: "Night"
        case .inverted: "Inverted"
        }
    }
}

/// What it takes to unlock a body or an extra. Purchases come in a later step.
enum AvatarUnlock: Equatable, Sendable {
    case always
    /// This many journal entries.
    case workouts(Int)
    /// The achievement with this ID from the catalog.
    case achievement(String)
    /// Any skill completed (all stages, or the target time reached).
    case masteredSkill
    /// First place in a week of this league.
    case leagueWin(League)
}

/// The avatar's body. It grows with the training.
enum AvatarBody: String, CaseIterable, Codable, Identifiable, Comparable, Sendable {
    case start
    case athlete
    case trained
    case legend

    var id: String { rawValue }

    var unlock: AvatarUnlock {
        switch self {
        case .start: .always
        case .athlete: .workouts(10)
        case .trained: .workouts(50)
        case .legend: .masteredSkill
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .start: "Start"
        case .athlete: "Athlete"
        case .trained: "Trained"
        case .legend: "Legend"
        }
    }

    private var order: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    static func < (lhs: AvatarBody, rhs: AvatarBody) -> Bool { lhs.order < rhs.order }
}

/// Accessories for the avatar, unlocked with achievements and skills.
enum AvatarExtra: String, CaseIterable, Codable, Identifiable, Sendable {
    case headband
    case cap
    case visor
    case headphones
    case medal
    case crown
    /// Prizes for first place in a league week, a crown in the league's color.
    case bronzeCrown
    case silverCrown
    case goldCrown
    case diamondCrown

    var id: String { rawValue }

    /// League crowns keep their league's color; other extras use the chosen extra color.
    var fixedColor: Color? {
        switch self {
        case .bronzeCrown: League.bronze.color
        case .silverCrown: League.silver.color
        case .goldCrown: League.gold.color
        case .diamondCrown: League.diamond.color
        default: nil
        }
    }

    var unlock: AvatarUnlock {
        switch self {
        case .headband: .achievement("firstWorkout")
        case .cap: .achievement("workouts10")
        case .headphones: .achievement("workouts25")
        case .visor: .achievement("streak4")
        case .medal: .achievement("workouts50")
        case .crown: .masteredSkill
        case .bronzeCrown: .leagueWin(.bronze)
        case .silverCrown: .leagueWin(.silver)
        case .goldCrown: .leagueWin(.gold)
        case .diamondCrown: .leagueWin(.diamond)
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .headband: "Headband"
        case .cap: "Cap"
        case .visor: "Visor"
        case .headphones: "Headphones"
        case .medal: "Medal"
        case .crown: "Crown"
        case .bronzeCrown: "Bronze crown"
        case .silverCrown: "Silver crown"
        case .goldCrown: "Gold crown"
        case .diamondCrown: "Diamond crown"
        }
    }
}

/// What the user chose for the avatar. Saved in `UserData`.
struct AvatarStyle: Codable, Equatable, Sendable {
    var color: AvatarColor = .lime
    /// Color of the extra.
    var extraColor: AvatarColor = .cyan
    var background: AvatarBackground = .dark
    var extra: AvatarExtra?
    /// `nil`: always the highest unlocked body.
    var body: AvatarBody?

    init(
        color: AvatarColor = .lime,
        extraColor: AvatarColor = .cyan,
        background: AvatarBackground = .dark,
        extra: AvatarExtra? = nil,
        body: AvatarBody? = nil
    ) {
        self.color = color
        self.extraColor = extraColor
        self.background = background
        self.extra = extra
        self.body = body
    }

    /// Missing or unknown values (older or newer files) fall back to the defaults.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = (try? container.decodeIfPresent(AvatarColor.self, forKey: .color)) ?? .lime
        extraColor = (try? container.decodeIfPresent(AvatarColor.self, forKey: .extraColor)) ?? .cyan
        background = (try? container.decodeIfPresent(AvatarBackground.self, forKey: .background)) ?? .dark
        extra = try? container.decodeIfPresent(AvatarExtra.self, forKey: .extra)
        body = try? container.decodeIfPresent(AvatarBody.self, forKey: .body)
    }
}

/// What the user has unlocked, from the journal, the achievements and the skills.
/// Pure values, so the rules can be tested.
struct AvatarUnlocks: Equatable, Sendable {
    let workouts: Int
    /// IDs of achieved achievements.
    let achievements: Set<String>
    let hasMasteredSkill: Bool
    /// Leagues with a first place.
    let leagueWins: Set<League>

    init(workouts: Int, achievements: Set<String>, hasMasteredSkill: Bool, leagueWins: Set<League> = []) {
        self.workouts = workouts
        self.achievements = achievements
        self.hasMasteredSkill = hasMasteredSkill
        self.leagueWins = leagueWins
    }

    /// - Parameters:
    ///   - leagueWins: Leagues with a first place, from `UserData`.
    ///   - reachedStages: Reached stages per skill, from `UserDataStore`.
    init(
        stats: JournalStats,
        catalog: Catalog,
        weeklyTarget: Int,
        leagueWins: Set<League> = [],
        reachedStages: (Goal) -> Int
    ) {
        self.leagueWins = leagueWins
        workouts = stats.entries.count
        achievements = Set(
            catalog.achievements
                .filter { stats.progress(of: $0, target: weeklyTarget).isAchieved }
                .map(\.id)
        )
        hasMasteredSkill = catalog.goals.contains {
            stats.goalProgress($0, reachedStages: reachedStages($0)).isComplete
        }
    }

    func isUnlocked(_ unlock: AvatarUnlock) -> Bool {
        switch unlock {
        case .always: true
        case .workouts(let count): workouts >= count
        case .achievement(let id): achievements.contains(id)
        case .masteredSkill: hasMasteredSkill
        case .leagueWin(let league): leagueWins.contains(league)
        }
    }

    func isUnlocked(_ body: AvatarBody) -> Bool { isUnlocked(body.unlock) }
    func isUnlocked(_ extra: AvatarExtra) -> Bool { isUnlocked(extra.unlock) }

    /// The highest unlocked body.
    var highestBody: AvatarBody {
        AvatarBody.allCases.last { isUnlocked($0) } ?? .start
    }

    /// The body shown: the chosen one if it is unlocked, otherwise the highest unlocked.
    func body(for style: AvatarStyle) -> AvatarBody {
        guard let chosen = style.body, isUnlocked(chosen) else { return highestBody }
        return chosen
    }

    /// The extra shown: the chosen one, if it is unlocked.
    func extra(for style: AvatarStyle) -> AvatarExtra? {
        guard let extra = style.extra, isUnlocked(extra) else { return nil }
        return extra
    }

    /// The next body to unlock, `nil` once all are unlocked.
    var nextBody: AvatarBody? {
        AvatarBody.allCases.first { !isUnlocked($0) }
    }

    /// Workouts still missing for the next body, `nil` if it is not unlocked by workouts.
    var workoutsToNextBody: Int? {
        guard let next = nextBody, case .workouts(let count) = next.unlock else { return nil }
        return max(0, count - workouts)
    }
}
