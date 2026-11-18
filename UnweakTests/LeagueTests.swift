import Foundation
import Testing
@testable import Unweak

// League weeks run Monday to Sunday in UTC. Week 47 of 2026 starts on Monday 16 November;
// "now" is Thursday 19 November at noon.

private let utc: Calendar = {
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
}()

private func day(_ day: Int, hour: Int = 18) -> Date {
    utc.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour)) ?? .distantPast
}

private let now = day(19, hour: 12)
private let week = LeagueWeek(containing: now)

private func workout(_ date: Date, minutes: Int = 20, byHand: Bool = false, results: [ExerciseResult] = []) -> JournalEntry {
    JournalEntry(date: date, planID: "pushBasics", durationSeconds: minutes * 60, results: results, addedByHand: byHand ? true : nil)
}

private func member(_ id: String, _ points: Int, at reached: Date = day(16), isMe: Bool = false) -> LeagueMember {
    LeagueMember(
        id: id,
        name: id,
        avatar: LeagueAvatar(style: AvatarStyle(), body: .start, extra: nil),
        points: points,
        reachedAt: reached,
        isMe: isMe
    )
}

struct LeagueRulesTests {
    @Test func leaguesMoveOneStepAndStopAtTheEnds() {
        #expect(League.bronze.promoted == .silver)
        #expect(League.gold.promoted == .diamond)
        #expect(League.diamond.promoted == .diamond)
        #expect(League.silver.relegated == .bronze)
        #expect(League.bronze.relegated == .bronze)
    }

    @Test func aQuarterOfTheGroupMovesAtLeastOne() {
        #expect(LeagueRules.movingPlaces(groupSize: 20) == 5)
        #expect(LeagueRules.movingPlaces(groupSize: 12) == 3)
        #expect(LeagueRules.movingPlaces(groupSize: 7) == 1)
        #expect(LeagueRules.movingPlaces(groupSize: 5) == 1)
    }

    @Test func zonesOfAGroupOfTwenty() {
        #expect(LeagueRules.zone(place: 1, groupSize: 20) == .promotion)
        #expect(LeagueRules.zone(place: 5, groupSize: 20) == .promotion)
        #expect(LeagueRules.zone(place: 6, groupSize: 20) == .middle)
        #expect(LeagueRules.zone(place: 15, groupSize: 20) == .middle)
        #expect(LeagueRules.zone(place: 16, groupSize: 20) == .relegation)
        #expect(LeagueRules.zone(place: 20, groupSize: 20) == .relegation)
    }

    /// Whether `place` in a group of 20 in `league` ends as expected; computed outside
    /// #expect, which cannot compare tuples.
    private func ends(_ place: Int, in league: League, _ outcome: WeekOutcome, _ next: League) -> Bool {
        let result = LeagueRules.outcome(place: place, groupSize: 20, league: league)
        return result.0 == outcome && result.1 == next
    }

    @Test func outcomeKeepsDiamondAndBronze() {
        #expect(ends(1, in: .silver, .promoted, .gold))
        #expect(ends(10, in: .silver, .stayed, .silver))
        #expect(ends(18, in: .silver, .relegated, .bronze))
        #expect(ends(1, in: .diamond, .stayed, .diamond))
        #expect(ends(20, in: .bronze, .stayed, .bronze))
    }

    @Test func equalPointsGoToWhoeverReachedThemFirst() {
        let ranked = LeagueRules.ranked([
            member("late", 50, at: day(18)),
            member("top", 80),
            member("early", 50, at: day(17)),
        ])
        #expect(ranked.map(\.id) == ["top", "early", "late"])
    }

    @Test func theWeekRunsFromMondayInUTC() {
        #expect(week.start == day(16, hour: 0))
        #expect(week.end == day(23, hour: 0))
        #expect(week.number == 47)
        #expect(week.id == "2026-W47")
        #expect(week.contains(day(22, hour: 23)))
        #expect(!week.contains(day(23, hour: 0)))
        #expect(week.previous.start == day(9, hour: 0))
    }

    @Test func daysLeftAreRoundedUp() {
        #expect(week.daysLeft(at: now) == 4)
        #expect(week.daysLeft(at: day(22, hour: 12)) == 1)
        #expect(week.daysLeft(at: day(23, hour: 1)) == 0)
    }
}

struct LeaguePointsTests {
    @Test func oneWorkoutPerDayCountsFromTenMinutes() {
        let entries = [
            workout(day(16, hour: 7)),
            workout(day(16, hour: 19)), // second on the same day
            workout(day(17), minutes: 8), // too short
            workout(day(18), byHand: true), // added by hand
            workout(day(19, hour: 8)),
            workout(day(12)), // last week
        ]
        let points = LeaguePoints.breakdown(for: week, entries: entries, weeklyTarget: 5, stageDates: [:], calendar: utc)
        #expect(points.workoutDays == 2)
        #expect(!points.reachedWeeklyTarget)
        #expect(points.total == 20)
    }

    @Test func weeklyTargetBringsTwentyOnce() {
        let entries = [workout(day(16)), workout(day(17)), workout(day(18)), workout(day(19, hour: 8))]
        let points = LeaguePoints.breakdown(for: week, entries: entries, weeklyTarget: 3, stageDates: [:], calendar: utc)
        #expect(points.reachedWeeklyTarget)
        #expect(points.total == 4 * 10 + 20)
    }

    @Test func oneStagePerSkillAndWeek() {
        let stages = [
            "frontLever": [day(2), day(16), day(18)], // two this week: counted once
            "pistolSquat": [day(17)],
            "muscleUp": [day(10)], // last week
        ]
        let points = LeaguePoints.breakdown(for: week, entries: [], weeklyTarget: 3, stageDates: stages, calendar: utc)
        #expect(points.skillsWithNewStage == 2)
        #expect(points.total == 60)
    }

    @Test func theStreakBringsFivePerWeekAndCountsWorkoutsAddedByHand() {
        // Weeks of 2 and 9 November reached the target of 1; one of them only by hand.
        let entries = [workout(day(3)), workout(day(10), byHand: true)]
        let points = LeaguePoints.breakdown(for: week, entries: entries, weeklyTarget: 1, stageDates: [:], calendar: utc)
        #expect(points.streakWeeks == 2)
        #expect(points.total == 10)
    }

    @Test func takesPartAfterTrainingLastWeekOrThisWeek() {
        #expect(!LeaguePoints.takesPart(in: week, entries: []))
        #expect(LeaguePoints.takesPart(in: week, entries: [workout(day(12))]))
        #expect(LeaguePoints.takesPart(in: week, entries: [workout(day(17))]))
        #expect(!LeaguePoints.takesPart(in: week, entries: [workout(day(12), byHand: true)]))
        #expect(!LeaguePoints.takesPart(in: week, entries: [workout(day(3))]))
    }
}

struct DisplayNameTests {
    @Test func validNames() {
        #expect(DisplayName.problem(with: "mara_moves") == nil)
        #expect(DisplayName.problem(with: "k.lever") == nil)
        #expect(DisplayName.problem(with: "Jürgen42") == nil)
        #expect(DisplayName.problem(with: "  bar.joe ") == nil)
    }

    @Test func lengthAndCharacters() {
        #expect(DisplayName.problem(with: "ab") == .tooShort)
        #expect(DisplayName.problem(with: String(repeating: "a", count: 21)) == .tooLong)
        #expect(DisplayName.problem(with: "bar joe") == .invalidCharacters)
        #expect(DisplayName.problem(with: "bar-joe") == .invalidCharacters)
        #expect(DisplayName.problem(with: "joe@bar") == .invalidCharacters)
    }

    @Test func blockedWordsAlsoWithDotsAndDigits() {
        #expect(DisplayName.problem(with: "sh1t_happens") == .notAllowed)
        #expect(DisplayName.problem(with: "f.u.c.k") == .notAllowed)
        #expect(DisplayName.problem(with: "ARSCHloch") == .notAllowed)
    }

    @Test func changeOnceInThirtyDays() {
        let changed = day(1)
        #expect(DisplayName.canChange(lastChange: nil, now: now))
        #expect(!DisplayName.canChange(lastChange: changed, now: day(30)))
        #expect(DisplayName.canChange(lastChange: changed, now: day(1).addingTimeInterval(DisplayName.changeInterval)))
        #expect(DisplayName.nextChange(lastChange: changed, now: day(19)) == changed.addingTimeInterval(DisplayName.changeInterval))
    }
}

struct DuelTests {
    private let opponent = LeagueOpponent(
        id: "mara",
        name: "mara_moves",
        avatar: LeagueAvatar(style: AvatarStyle(), body: .trained, extra: nil),
        isPro: false
    )

    @Test func atMostThreeRunningDuels() {
        #expect(DuelRules.canStart(running: 2))
        #expect(!DuelRules.canStart(running: 3))
    }

    @Test func skillStagesNeedProOnBothSides() {
        #expect(DuelRules.isAvailable(.moreWorkouts, meIsPro: false, opponentIsPro: false))
        #expect(!DuelRules.isAvailable(.moreStages, meIsPro: true, opponentIsPro: false))
        #expect(DuelRules.isAvailable(.moreStages, meIsPro: true, opponentIsPro: true))
    }

    @Test func invitationLapsesAfterTwoDays() {
        #expect(!DuelRules.invitationHasLapsed(sentAt: day(16, hour: 12), now: day(18, hour: 11)))
        #expect(DuelRules.invitationHasLapsed(sentAt: day(16, hour: 12), now: day(18, hour: 12)))
    }

    @Test func workoutDuelCountsDaysOnce() {
        let duel = Duel(id: "d", kind: .moreWorkouts, opponent: opponent, start: day(16, hour: 0),
                        opponentSide: DuelSide(score: 1, days: Array(repeating: false, count: 7)))
        let entries = [workout(day(16, hour: 7)), workout(day(16, hour: 19)), workout(day(18)), workout(day(18), minutes: 5)]
        let side = duel.mySide(entries: entries, stageDates: [:], calendar: utc)
        #expect(side.score == 2)
        #expect(side.days == [true, false, true, false, false, false, false])
        #expect(Duel.outcome(mine: side.score, theirs: duel.opponentSide.score) == .won)
        #expect(duel.isRunning(at: now))
        #expect(!duel.isRunning(at: day(23, hour: 0)))
        #expect(duel.daysLeft(at: now) == 4)
    }

    @Test func plankDuelTakesTheBestTime() {
        let plank = { (seconds: Int) in ExerciseResult(exercise: "plank", sets: 3, value: seconds, unit: .seconds) }
        let entries = [workout(day(16), results: [plank(60)]), workout(day(18), results: [plank(95)]), workout(day(10), results: [plank(200)])]
        let side = DuelRules.side(kind: .longestPlank, from: day(16, hour: 0), entries: entries, stageDates: [:], calendar: utc)
        #expect(side.score == 95)
        #expect(Duel.outcome(mine: 95, theirs: 95) == .draw)
        #expect(Duel.outcome(mine: 60, theirs: 95) == .lost)
    }
}

@MainActor
struct LeagueStoreTests {
    private func emptyDefaults() -> UserDefaults {
        let name = "unweak.tests.league.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private let avatar = LeagueAvatar(style: AvatarStyle(), body: .start, extra: nil)

    @Test func theFirstNameStartsNoWaitingTime() {
        let league = LeagueStore(defaults: emptyDefaults(), now: now)
        #expect(league.setDisplayName("bad name", now: now) == .invalidCharacters)
        #expect(league.displayName == nil)
        #expect(league.setDisplayName("jonas.k", now: now) == nil)
        #expect(league.displayName == "jonas.k")
        #expect(league.displayNameChangedAt == nil)
        // The first change is possible at once, then only after 30 days.
        league.setDisplayName("jonas.k2", now: now)
        #expect(league.displayName == "jonas.k2")
        league.setDisplayName("jonas.k3", now: day(20))
        #expect(league.displayName == "jonas.k2")
    }

    @Test func noStandingWithoutTakingPart() {
        let league = LeagueStore(defaults: emptyDefaults(), now: now)
        let entries = [workout(day(17))]
        #expect(league.standing(entries: entries, stageDates: [:], weeklyTarget: 3, avatar: avatar, now: now) != nil)
        #expect(league.standing(entries: [], stageDates: [:], weeklyTarget: 3, avatar: avatar, now: now) == nil)
        league.setTakingPart(false)
        #expect(league.standing(entries: entries, stageDates: [:], weeklyTarget: 3, avatar: avatar, now: now) == nil)
    }

    @Test func blockedPeopleLeaveTheRanking() throws {
        let league = LeagueStore(defaults: emptyDefaults(), now: now)
        let entries = [workout(day(17))]
        let before = try #require(league.standing(entries: entries, stageDates: [:], weeklyTarget: 3, avatar: avatar, now: now))
        #expect(before.groupSize == 20)
        let other = try #require(before.members.first { !$0.isMe })
        league.block(other)
        let after = try #require(league.standing(entries: entries, stageDates: [:], weeklyTarget: 3, avatar: avatar, now: now))
        #expect(after.groupSize == 19)
        // Checked outside #expect: the macro cannot expand a closure call here.
        let stillThere = after.members.contains { $0.id == other.id }
        #expect(!stillThere)
        league.unblock(other.id)
        #expect(league.blocked.isEmpty)
    }

    @Test func atMostThreeDuelsRun() throws {
        let league = LeagueStore(defaults: emptyDefaults(), now: now)
        // The sample duel of this week runs already.
        #expect(league.runningDuels(at: now).count == 1)
        let friend = try #require(league.friends.first)
        #expect(league.challenge(friend, kind: .moreWorkouts, now: now) != nil)
        #expect(league.challenge(friend, kind: .longestPlank, now: now) != nil)
        #expect(league.challenge(friend, kind: .moreWorkouts, now: now) == nil)
        #expect(league.runningDuels(at: now).count == 3)
    }

    @Test func aNewWeekShowsHowTheLastOneEnded() {
        let defaults = emptyDefaults()
        let store = UserDataStore(fileURL: nil)
        // Last week (46): a workout every day and a stage of each skill with stages:
        // 7 × 10 + 20 + 4 × 30 = 210 points, second behind 212.
        for dayOfMonth in 9...15 { store.save(workout(day(dayOfMonth))) }
        for goal in Catalog.main.goals where goal.stageCount != nil {
            store.setReachedStages(1, of: goal, at: day(12))
        }
        let lastWeek = day(14)
        let league = LeagueStore(defaults: defaults, now: lastWeek)
        league.refresh(store: store, weeklyTarget: 3, avatar: avatar, now: lastWeek)
        #expect(league.pendingResult == nil) // the first start only remembers the week

        league.refresh(store: store, weeklyTarget: 3, avatar: avatar, now: now)
        let result = league.pendingResult
        #expect(result?.week.number == 46)
        #expect(result?.place == 2)
        #expect(result?.outcome == .promoted)
        #expect(result?.newLeague == .silver)
        #expect(league.league == .silver)
        // The sample duel of week 46 ended and was won (7 days against 2).
        #expect(store.data.duelWins == 1)

        // Only once per week.
        league.pendingResult = nil
        league.refresh(store: store, weeklyTarget: 3, avatar: avatar, now: now)
        #expect(league.pendingResult == nil)
    }
}

@MainActor
struct LeagueDataTests {
    @Test func reachedStagesAreDated() throws {
        let store = UserDataStore(fileURL: nil)
        let goal = try #require(Catalog.main.goals.first { $0.id == "frontLever" })
        store.markStageReached(of: goal, at: day(16))
        store.setReachedStages(3, of: goal, at: day(18))
        #expect(store.data.stageReachedDates["frontLever"] == [day(16), day(18), day(18)])
        store.setReachedStages(1, of: goal, at: day(19))
        #expect(store.data.stageReachedDates["frontLever"] == [day(16)])
        store.setReachedStages(0, of: goal)
        #expect(store.data.stageReachedDates["frontLever"] == nil)
    }

    @Test func workoutsAddedByHandAreMarked() throws {
        let plan = try #require(Catalog.main.plan("pushBasics"))
        #expect(JournalEntry(plan: plan, date: now).isAddedByHand)
        #expect(!workout(now).isAddedByHand)
    }

    @Test func olderFilesLoadWithoutLeagueData() throws {
        let json = #"{"version":1,"entries":[{"id":"5B3F8D8E-0000-4000-8000-000000000001","date":0,"planID":"pushBasics","durationSeconds":1200,"results":[],"note":""}]}"#
        let data = try JSONDecoder.userData.decode(UserData.self, from: Data(json.utf8))
        #expect(data.entries.first?.isAddedByHand == false)
        #expect(data.stageReachedDates.isEmpty)
        #expect(data.leagueWins.isEmpty)
        #expect(data.duelWins == 0)
    }

    @Test func leagueCrownsAreUnlockedByWinning() {
        let none = AvatarUnlocks(workouts: 0, achievements: [], hasMasteredSkill: false)
        let silver = AvatarUnlocks(workouts: 0, achievements: [], hasMasteredSkill: false, leagueWins: [.silver])
        #expect(!none.isUnlocked(AvatarExtra.silverCrown))
        #expect(silver.isUnlocked(AvatarExtra.silverCrown))
        #expect(!silver.isUnlocked(AvatarExtra.goldCrown))
        #expect(League.gold.prize == .goldCrown)
        #expect(AvatarExtra.goldCrown.fixedColor != nil)
        #expect(AvatarExtra.cap.fixedColor == nil)
    }
}
