import Foundation
import Testing
@testable import Unweak

// Dates in November 2026: Monday 2, 9, 16 (week 47) and 30. "Now" is Thursday 19 November.

private let utc: Calendar = {
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
}()

private func day(_ month: Int, _ day: Int, hour: Int = 18) -> Date {
    utc.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour)) ?? .distantPast
}

private let now = day(11, 19, hour: 12)

private func entry(
    _ date: Date,
    plan: String? = "pushBasics",
    seconds: Int = 1_200,
    results: [ExerciseResult] = []
) -> JournalEntry {
    JournalEntry(date: date, planID: plan, durationSeconds: seconds, results: results)
}

private func pullUps(_ value: Int) -> ExerciseResult {
    ExerciseResult(exercise: "pullUp", sets: 3, value: value, unit: .reps)
}

private func stats(_ entries: [JournalEntry]) -> JournalStats {
    JournalStats(entries: entries, calendar: utc)
}

struct WeekAndStreakTests {
    @Test func weekRunsMondayToSundayAndMarksTrainedDaysAndToday() {
        let week = stats([entry(day(11, 16)), entry(day(11, 18)), entry(day(11, 13))]).week(containing: now, target: 3)
        #expect(week.days.count == 7)
        #expect(utc.isDate(week.days[0].date, inSameDayAs: day(11, 16)))
        #expect(week.days.map(\.trained) == [true, false, true, false, false, false, false])
        #expect(week.days.map(\.isToday) == [false, false, false, true, false, false, false])
        #expect(week.workouts == 2)
        #expect(week.target == 3)
    }

    @Test func sundayEveningStillBelongsToTheWeek() {
        let week = stats([entry(day(11, 22, hour: 23))]).week(containing: now, target: 3)
        #expect(week.workouts == 1)
        #expect(week.days[6].trained)
    }

    private func threePerWeek(mondays: [Int]) -> [JournalEntry] {
        mondays.flatMap { monday in [0, 2, 4].map { entry(day(11, monday + $0)) } }
    }

    @Test func streakCountsFinishedWeeksWhileTheCurrentOneIsOpen() {
        // Weeks of 2 and 9 November reached, current week has one workout.
        let entries = threePerWeek(mondays: [2, 9]) + [entry(day(11, 16))]
        #expect(stats(entries).streak(at: now, target: 3) == 2)
    }

    @Test func currentWeekCountsOnceTheTargetIsReached() {
        let entries = threePerWeek(mondays: [2, 9, 16])
        #expect(stats(entries).streak(at: day(11, 21), target: 3) == 3)
    }

    @Test func aWeekBelowTheTargetBreaksTheStreak() {
        // 2 November reached, 9 November only two workouts, current week not yet.
        let entries = threePerWeek(mondays: [2]) + [entry(day(11, 9)), entry(day(11, 10))]
        #expect(stats(entries).streak(at: now, target: 3) == 0)
    }

    @Test func noWorkoutsNoStreak() {
        #expect(stats([]).streak(at: now, target: 3) == 0)
        #expect(stats([]).longestStreak(target: 3) == 0)
    }

    @Test func targetBelowOneIsTreatedAsOne() {
        #expect(stats([entry(day(11, 10))]).streak(at: now, target: 0) == 1)
    }

    @Test func longestStreakLooksAtTheWholeHistory() {
        let entries = threePerWeek(mondays: [2, 9]) + [entry(day(11, 30))]
        #expect(stats(entries).longestStreak(target: 3) == 2)
        #expect(stats(entries).longestStreak(target: 1) == 2)
    }
}

struct RecordAndMonthTests {
    @Test func aBetterValueThanEverBeforeIsARecord() {
        let first = entry(day(11, 2), results: [pullUps(5)])
        let second = entry(day(11, 4), results: [pullUps(6)])
        let third = entry(day(11, 6), results: [pullUps(6)])
        let all = stats([third, first, second])
        #expect(all.records(in: first).isEmpty, "the first time is not a record")
        #expect(all.records(in: second) == [pullUps(6)])
        #expect(all.records(in: third).isEmpty, "equal is not better")
    }

    @Test func repsAndSecondsAreComparedSeparately() {
        let reps = entry(day(11, 2), results: [ExerciseResult(exercise: "plank", sets: 1, value: 50, unit: .reps)])
        let seconds = entry(day(11, 4), results: [ExerciseResult(exercise: "plank", sets: 1, value: 40, unit: .seconds)])
        #expect(stats([reps, seconds]).records(in: seconds).isEmpty)
        #expect(stats([reps, seconds]).bestValue(of: "plank", unit: .seconds) == 40)
    }

    @Test func monthFigures() {
        let entries = [
            entry(day(10, 30), seconds: 999, results: [pullUps(4)]),
            entry(day(11, 2), seconds: 1_000, results: [pullUps(5)]),
            entry(day(11, 9), seconds: 500, results: [pullUps(7)]),
        ]
        let month = stats(entries).month(containing: now)
        #expect(month == MonthSummary(workouts: 2, seconds: 1_500, records: 2))
    }
}

struct AchievementAndGoalTests {
    private let catalog = Catalog.main

    private func achievement(_ id: String) throws -> Achievement {
        try #require(catalog.achievements.first { $0.id == id })
    }

    @Test func workoutCountAchievements() throws {
        let entries = (1...10).map { entry(day(11, $0)) }
        let first = try achievement("firstWorkout")
        let ten = try achievement("workouts10")
        let twentyFiveWorkouts = try achievement("workouts25")
        #expect(stats(entries).progress(of: first, target: 3).isAchieved)
        #expect(stats(entries).progress(of: ten, target: 3).isAchieved)
        let twentyFive = stats(entries).progress(of: twentyFiveWorkouts, target: 3)
        #expect(!twentyFive.isAchieved)
        #expect(twentyFive.value == 10)
    }

    @Test func achievedFirstKeepsCatalogOrder() throws {
        let entries = (1...10).map { entry(day(11, $0)) }
        let ids = ["workouts25", "firstWorkout", "pullUps10", "workouts10"]
        let progress = try ids.map { stats(entries).progress(of: try achievement($0), target: 3) }
        #expect(progress.achievedFirst.map(\.achievement.id) == ["firstWorkout", "workouts10", "workouts25", "pullUps10"])
    }

    @Test func currentStageIsTheNextOneToReach() throws {
        let goal = try #require(catalog.goals.first { $0.id == "frontLever" })
        #expect(stats([]).goalProgress(goal, reachedStages: 0).currentStageIndex == 0)
        #expect(stats([]).goalProgress(goal, reachedStages: 2).currentStageIndex == 2)
        #expect(stats([]).goalProgress(goal, reachedStages: 5).currentStageIndex == 4)
        let plank = try #require(catalog.goals.first { $0.id == "plank5Min" })
        #expect(stats([]).goalProgress(plank, reachedStages: 0).currentStageIndex == nil)
    }

    @Test func currentAnimationFollowsTheStage() throws {
        let goal = try #require(catalog.goals.first { $0.id == "frontLever" })
        #expect(catalog.currentAnimation(for: stats([]).goalProgress(goal, reachedStages: 0)) == .tuckFrontLever)
        #expect(catalog.currentAnimation(for: stats([]).goalProgress(goal, reachedStages: 1)) == .advancedTuckFrontLever)
        #expect(catalog.currentAnimation(for: stats([]).goalProgress(goal, reachedStages: 5)) == .frontLever)
        let plank = try #require(catalog.goals.first { $0.id == "plank5Min" })
        #expect(catalog.currentAnimation(for: stats([]).goalProgress(plank, reachedStages: 0)) == .plank)
    }

    @Test func everyStageHasItsOwnAnimationAndTheLastIsTheSkill() {
        for goal in catalog.goals where goal.stageCount != nil {
            let animations = goal.stageAnimations ?? []
            #expect(animations.count == goal.stageCount, "\(goal.id)")
            #expect(animations.last == catalog.animation(for: goal), "\(goal.id)")
        }
    }

    @Test func bestRepsAchievement() throws {
        let entries = [entry(day(11, 2), results: [pullUps(9)]), entry(day(11, 4), results: [pullUps(10)])]
        let pullUpAchievement = try achievement("pullUps10")
        let progress = stats(entries).progress(of: pullUpAchievement, target: 3)
        #expect(progress.value == 10)
        #expect(progress.isAchieved)
    }

    @Test func streakAchievement() throws {
        let entries = [2, 9, 16, 23].map { entry(day(11, $0)) }
        let streak = try achievement("streak4")
        #expect(stats(entries).progress(of: streak, target: 1).isAchieved)
        #expect(!stats(entries).progress(of: streak, target: 2).isAchieved)
    }

    @Test func skillGoalShowsReachedStagesAndTheNextOne() throws {
        let goal = try #require(catalog.goals.first { $0.id == "frontLever" })
        let progress = stats([]).goalProgress(goal, reachedStages: 2)
        #expect(progress.filledSegments == 2)
        #expect(progress.nextStageKey == "goal.frontLever.stage3")
        #expect(!progress.isComplete)
        let done = stats([]).goalProgress(goal, reachedStages: 5)
        #expect(done.isComplete)
        #expect(done.nextStageKey == nil)
    }

    @Test func timeGoalUsesTheBestTimeOfItsExercise() throws {
        let goal = try #require(catalog.goals.first { $0.id == "plank5Min" })
        let plank = ExerciseResult(exercise: "plank", sets: 3, value: 150, unit: .seconds)
        let progress = stats([entry(day(11, 2), results: [plank])]).goalProgress(goal, reachedStages: 0)
        #expect(progress.bestSeconds == 150)
        #expect(progress.filledSegments == 2) // 150 of 300 s = 2.5 of 5 segments
        #expect(!progress.isComplete)
        #expect(stats([]).goalProgress(goal, reachedStages: 0).filledSegments == 0)
    }

    @Test func nextWorkoutPrefersPlansNeverTrainedThenTheOldest() throws {
        let free = catalog.plans.filter(\.isFree)
        #expect(stats([]).nextWorkout(in: catalog)?.id == free[0].id)
        #expect(stats([entry(day(11, 2), plan: free[0].id)]).nextWorkout(in: catalog)?.id == free[1].id)

        let allTrained = free.enumerated().map { index, plan in entry(day(11, 10 - index), plan: plan.id) }
        #expect(stats(allTrained).nextWorkout(in: catalog)?.id == free.last?.id)
    }
}

@MainActor
struct JournalEntryTests {
    @Test func entryFromASessionCountsCompletedSets() throws {
        let plan = try #require(Catalog.main.plan("pushBasics"))
        let start = day(11, 19, hour: 7)
        let session = try #require(TrainingSession(plan: plan, catalog: .main, startedAt: start))
        for _ in 0..<3 { session.completeSet(at: start) }
        session.goToNextExercise()
        session.completeSet(at: start)
        session.completeSet(at: start)

        let entry = JournalEntry(session: session, endedAt: start.addingTimeInterval(900))
        #expect(entry.planID == "pushBasics")
        #expect(entry.date == start)
        #expect(entry.durationSeconds == 900)
        #expect(entry.results == [
            ExerciseResult(exercise: "kneePushUp", sets: 3, value: 10, unit: .reps),
            ExerciseResult(exercise: "pushUp", sets: 2, value: 6, unit: .reps),
        ])
        #expect(entry.totalSets == 5)
    }

    @Test func sessionWithoutSetsGivesNoResults() throws {
        let plan = try #require(Catalog.main.plan("corePlank"))
        let session = try #require(TrainingSession(plan: plan, catalog: .main, startedAt: now))
        #expect(JournalEntry(session: session, endedAt: now).results.isEmpty)
    }

    @Test func entryAddedByHandUsesThePlanTargets() throws {
        let plan = try #require(Catalog.main.plan("corePlank"))
        let entry = JournalEntry(plan: plan, date: now)
        #expect(entry.results.first == ExerciseResult(exercise: "plank", sets: 3, value: 40, unit: .seconds))
        #expect(entry.durationSeconds == plan.estimatedSeconds)
    }
}

@MainActor
struct UserDataStoreTests {
    private func temporaryFile() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "unweak-tests-\(UUID().uuidString)")
            .appending(path: "userdata.json")
    }

    @Test func savesAndLoadsAgain() throws {
        let file = temporaryFile()
        defer { try? FileManager.default.removeItem(at: file.deletingLastPathComponent()) }
        let goal = try #require(Catalog.main.goals.first { $0.id == "frontLever" })

        let store = UserDataStore(fileURL: file)
        var first = entry(day(11, 2), results: [pullUps(5)])
        store.save(first)
        store.markStageReached(of: goal)
        store.setActiveGoal(goal.id)
        first.note = "Strong day"
        first.rating = .hard
        store.save(first)

        let reloaded = UserDataStore(fileURL: file)
        #expect(reloaded.data == store.data)
        #expect(reloaded.entries.count == 1)
        #expect(reloaded.entries.first?.note == "Strong day")
        #expect(reloaded.reachedStages(of: goal) == 1)
        #expect(reloaded.data.activeGoalID == "frontLever")
        #expect(store.saveError == nil)
    }

    @Test func stagesStopAtTheLastOneAndTimeGoalsHaveNone() throws {
        let store = UserDataStore(fileURL: nil)
        let skill = try #require(Catalog.main.goals.first { $0.id == "pistolSquat" })
        let time = try #require(Catalog.main.goals.first { $0.id == "lSit30" })
        for _ in 0..<8 { store.markStageReached(of: skill) }
        store.markStageReached(of: time)
        #expect(store.reachedStages(of: skill) == 5)
        #expect(store.reachedStages(of: time) == 0)
    }

    @Test func unreadableFileStartsEmpty() throws {
        let file = temporaryFile()
        defer { try? FileManager.default.removeItem(at: file.deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: file)
        #expect(UserDataStore(fileURL: file).entries.isEmpty)
    }

    @Test func sortedEntriesAreNewestFirst() {
        let store = UserDataStore(fileURL: nil)
        store.save(entry(day(11, 2)))
        store.save(entry(day(11, 9)))
        #expect(store.sortedEntries.map(\.date) == [day(11, 9), day(11, 2)])
    }
}

struct WeeklyTargetTests {
    @Test func defaultsToThreeAndFollowsTheReminderDays() throws {
        let defaults = try #require(UserDefaults(suiteName: "unweak-tests-\(UUID().uuidString)"))
        #expect(WeeklyTarget.current(in: defaults) == 3)
        defaults.set([2, 4, 6, 7], forKey: WeeklyTarget.weekdaysKey)
        #expect(WeeklyTarget.current(in: defaults) == 4)
        defaults.set([Int](), forKey: WeeklyTarget.weekdaysKey)
        #expect(WeeklyTarget.current(in: defaults) == 3)
    }
}
