import Foundation
import Testing
@testable import Unweak

struct CatalogTests {
    private let catalog = Catalog.main

    @Test func loadsWithoutProblems() throws {
        let loaded = try Catalog.load()
        #expect(loaded.problems().isEmpty)
        #expect(loaded.exercises.count == 16)
        #expect(loaded.plans.count == 13)
        #expect(loaded.goals.count == 6)
        #expect(loaded.achievements.count == 12)
    }

    @Test func theFreeVersionHasTenGeneralWorkouts() {
        #expect(catalog.freePlanCount == 10)
        for plan in catalog.plans {
            #expect(plan.isFree == (plan.category != .skill), "\(plan.id)")
        }
    }

    @Test func skillsArePro() {
        #expect(catalog.goals.allSatisfy { !$0.isFree })
    }

    @Test(arguments: ExerciseCategory.allCases)
    func everyCategoryHasAPlan(_ category: ExerciseCategory) {
        #expect(!catalog.filteredPlans(category: category).isEmpty)
    }

    @Test func filterAllShowsEveryPlanWithFreePlansFirst() {
        let plans = catalog.filteredPlans(category: nil)
        #expect(plans.count == catalog.plans.count)
        let firstPaid = plans.firstIndex { !$0.isFree } ?? plans.count
        #expect(plans[firstPaid...].allSatisfy { !$0.isFree })
    }

    @Test func filterByCategoryShowsOnlyThatCategory() {
        let push = catalog.filteredPlans(category: .push)
        #expect(push.allSatisfy { $0.category == .push })
        #expect(push.map(\.id).contains("pushBasics"))
    }

    @Test func durationEstimate() throws {
        // 3×(30+60) + 4×(18+90) + 3×(18+90) + 3×(30+45) = 1251 s ≈ 21 min
        let plan = try #require(catalog.plan("pushBasics"))
        #expect(plan.estimatedSeconds == 1251)
        #expect(plan.estimatedMinutes == 21)
    }

    @Test func targetsAndWorkTime() {
        #expect(ExerciseTarget.reps(10).workSeconds == 30)
        #expect(ExerciseTarget.seconds(40).workSeconds == 40)
    }

    @Test func goalKinds() throws {
        let frontLever = try #require(catalog.goals.first { $0.id == "frontLever" })
        #expect(frontLever.kind == .stages(5))
        #expect(frontLever.stageKeys.count == 5)
        let plank = try #require(catalog.goals.first { $0.id == "plank5Min" })
        #expect(plank.kind == .time(seconds: 300))
    }

    @Test(arguments: ["en", "de"])
    func everyTextIsTranslated(_ language: String) throws {
        let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let missing = catalog.textKeys.filter {
            bundle.localizedString(forKey: $0, value: "__missing__", table: CatalogText.table) == "__missing__"
        }
        #expect(missing.isEmpty, "Missing \(language): \(missing)")
    }

    @Test func detectsBrokenReferences() {
        let plan = WorkoutPlan(
            id: "broken",
            category: .push,
            level: .beginner,
            pose: .pushUp,
            isFree: true,
            exercises: [PlanExercise(exercise: "doesNotExist", sets: 3, reps: 5, seconds: nil, rest: 60)]
        )
        let broken = Catalog(exercises: catalog.exercises, plans: [plan], goals: [], achievements: [])
        #expect(!broken.problems().isEmpty)
    }

    @Test func detectsSetWithoutTarget() throws {
        let exercise = try #require(catalog.exercises.first)
        let plan = WorkoutPlan(
            id: "noTarget",
            category: .push,
            level: .beginner,
            pose: .pushUp,
            isFree: true,
            exercises: [PlanExercise(exercise: exercise.id, sets: 3, reps: nil, seconds: nil, rest: 60)]
        )
        let broken = Catalog(exercises: catalog.exercises, plans: [plan], goals: [], achievements: [])
        #expect(!broken.problems().isEmpty)
    }
}

@MainActor
struct TrainingSessionTests {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000)

    private func makeSession() throws -> TrainingSession {
        let plan = try #require(Catalog.main.plan("pushBasics"))
        return try #require(TrainingSession(plan: plan, catalog: .main, startedAt: start))
    }

    @Test func startsWithTheFirstSetOfTheFirstExercise() throws {
        let session = try makeSession()
        #expect(session.stepIndex == 0)
        #expect(session.current.exercise.id == "kneePushUp")
        #expect(session.next?.exercise.id == "pushUp")
        #expect(session.primaryAction == .completeSet(1))
        #expect(session.restRemaining(at: start) == 0)
    }

    @Test func completingASetStartsTheRest() throws {
        let session = try makeSession()
        session.completeSet(at: start)
        #expect(session.completedSets == 1)
        #expect(session.primaryAction == .completeSet(2))
        #expect(session.restRemaining(at: start) == 60)
        #expect(session.restRemaining(at: start.addingTimeInterval(30)) == 30)
        #expect(session.restRemaining(at: start.addingTimeInterval(61)) == 0)
    }

    @Test func afterTheLastSetComesTheNextExercise() throws {
        let session = try makeSession()
        for _ in 0..<3 { session.completeSet(at: start) }
        #expect(session.isExerciseComplete)
        #expect(session.primaryAction == .nextExercise)

        session.completeSet(at: start)
        #expect(session.completedSets == 3, "extra taps are ignored")

        session.performPrimaryAction(at: start)
        #expect(session.stepIndex == 1)
        #expect(session.completedSets == 0)
        #expect(session.primaryAction == .completeSet(1))
    }

    @Test func lastExerciseEndsWithFinish() throws {
        let session = try makeSession()
        while session.primaryAction != .finish {
            session.performPrimaryAction(at: start)
        }
        #expect(session.isLastExercise)
        #expect(session.next == nil)

        session.performPrimaryAction(at: start.addingTimeInterval(600))
        #expect(session.isFinished)
        #expect(session.elapsedSeconds(at: start.addingTimeInterval(9_999)) == 600)
    }

    @Test func elapsedTime() throws {
        let session = try makeSession()
        #expect(session.elapsedSeconds(at: start) == 0)
        #expect(session.elapsedSeconds(at: start.addingTimeInterval(125.7)) == 125)
    }

    @Test func noSessionWithoutKnownExercises() {
        let plan = WorkoutPlan(
            id: "empty",
            category: .core,
            level: .beginner,
            pose: .plank,
            isFree: true,
            exercises: [PlanExercise(exercise: "unknown", sets: 1, reps: 1, seconds: nil, rest: 0)]
        )
        #expect(TrainingSession(plan: plan, catalog: .main, startedAt: start) == nil)
    }
}

struct TimeTextTests {
    @Test func clockFormatting() {
        #expect(TimeText.clock(0) == "0:00")
        #expect(TimeText.clock(65) == "1:05")
        #expect(TimeText.clock(3_725) == "1:02:05")
        #expect(TimeText.clock(-5) == "0:00")
    }
}

struct AreaTests {
    @Test func theFourAreasWithoutSkills() {
        #expect(ExerciseCategory.areas == [.push, .pull, .legs, .core])
        #expect(!ExerciseCategory.areas.contains(.skill))
    }

    @Test func stagesAreSpreadOverTheSkillWorkouts() throws {
        let catalog = Catalog.main
        let frontLever = try #require(catalog.goals.first { $0.id == "frontLever" })
        // Three workouts over five stages: 0, 0, 1, 1, 2.
        let ids = (0..<5).compactMap { catalog.plan(forStage: $0, of: frontLever)?.id }
        #expect(ids == ["pullDay", "pullDay", "pullStrength", "pullStrength", "frontLeverBuildUp"])
        #expect(catalog.plan(forStage: 9, of: frontLever)?.id == "frontLeverBuildUp")
        let plank = try #require(catalog.goals.first { $0.id == "plank5Min" })
        #expect(catalog.plan(forStage: 3, of: plank)?.id == plank.plans.first)
    }
}

struct SkillTests {
    private let catalog = Catalog.main

    @Test func everySkillHasWorkoutsFromEasyToHard() throws {
        for goal in catalog.goals {
            #expect(!catalog.skillPlans(for: goal).isEmpty, "\(goal.id)")
        }
        let frontLever = try #require(catalog.goals.first { $0.id == "frontLever" })
        #expect(catalog.skillPlans(for: frontLever).map(\.id) == ["pullDay", "pullStrength", "frontLeverBuildUp"])
    }

    @Test func skillWorkoutsAreNotInTheWorkoutsArea() {
        let general = catalog.workoutPlans(category: nil)
        #expect(general.allSatisfy { $0.category != .skill })
        for plan in catalog.plans where plan.category == .skill {
            #expect(catalog.goals.contains { $0.plans.contains(plan.id) }, "\(plan.id) belongs to a skill")
        }
    }

    @Test func detectsUnknownSkillWorkouts() throws {
        let goal = try #require(catalog.goals.first)
        let broken = Goal(
            id: goal.id,
            pose: goal.pose,
            exercise: goal.exercise,
            plans: ["doesNotExist"],
            isFree: true,
            stageCount: 5,
            targetSeconds: nil
        )
        let catalogWithBrokenSkill = Catalog(
            exercises: catalog.exercises,
            plans: catalog.plans,
            goals: [broken],
            achievements: []
        )
        #expect(!catalogWithBrokenSkill.problems().isEmpty)
    }

    @Test func nextWorkoutPrefersFreeWorkoutsOfTheActiveSkill() {
        let stats = JournalStats(entries: [])
        #expect(stats.nextWorkout(in: catalog, preferring: ["pullDay", "frontLeverBuildUp"])?.id == "pullDay")
        // Only Pro workouts in the skill: fall back to all free plans.
        #expect(stats.nextWorkout(in: catalog, preferring: ["muscleUpPath"])?.id == catalog.plans.first(where: \.isFree)?.id)
    }
}

struct AccessTests {
    private let catalog = Catalog.main

    @Test func freeVersionTrainsGeneralWorkoutsOnly() throws {
        let free = Access(isPro: false)
        let general = try #require(catalog.plan("pushBasics"))
        let skillWorkout = try #require(catalog.plan("frontLeverBuildUp"))
        #expect(free.canTrain(general))
        #expect(!free.canTrain(skillWorkout))
        #expect(!free.canUseSkills)
    }

    @Test func proUnlocksEverything() throws {
        let pro = Access(isPro: true)
        #expect(catalog.plans.allSatisfy { pro.canTrain($0) })
        #expect(pro.canUseSkills)
        #expect(pro.canCreateCustomWorkout(existing: 50))
    }

    @Test func freeVersionAllowsThreeCustomWorkouts() {
        let free = Access(isPro: false)
        #expect(free.canCreateCustomWorkout(existing: 0))
        #expect(free.canCreateCustomWorkout(existing: 2))
        #expect(!free.canCreateCustomWorkout(existing: 3))
        #expect(!free.canCreateCustomWorkout(existing: 4))
    }

    @Test func customWorkoutsAreAlwaysTrainable() {
        let workout = CustomWorkout(name: "Mine", exercises: [catalog.defaultItem(for: "squat")])
        #expect(Access(isPro: false).canTrain(workout.plan(in: catalog)))
    }

    @Test func proSuggestsTheSkillWorkoutsIncludingProOnes() throws {
        let pullDay = JournalEntry(date: Date(timeIntervalSinceReferenceDate: 100), planID: "pullDay", durationSeconds: 60, results: [])
        let pullStrength = JournalEntry(date: Date(timeIntervalSinceReferenceDate: 200), planID: "pullStrength", durationSeconds: 60, results: [])
        let frontLever = try #require(catalog.goals.first { $0.id == "frontLever" })
        let stats = JournalStats(entries: [pullDay, pullStrength])
        let pro = stats.nextWorkout(in: catalog, access: Access(isPro: true), preferring: frontLever.plans)
        #expect(pro?.id == "frontLeverBuildUp")
        let free = stats.nextWorkout(in: catalog, access: Access(isPro: false), preferring: frontLever.plans)
        #expect(free?.id == "pullDay")
    }

    @Test func withoutSkillOnlyGeneralWorkoutsAreSuggested() {
        let suggestion = JournalStats(entries: []).nextWorkout(in: catalog, access: Access(isPro: true))
        #expect(suggestion?.category != .skill)
    }
}

struct SubscriptionStateTests {
    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    @Test func runningSubscriptionUnlocksPro() {
        #expect(SubscriptionStore.isActive(productID: ProductID.yearly, revocationDate: nil, expirationDate: now.addingTimeInterval(60), now: now))
        #expect(SubscriptionStore.isActive(productID: ProductID.monthly, revocationDate: nil, expirationDate: nil, now: now))
    }

    @Test func expiredRefundedOrForeignDoNotUnlock() {
        #expect(!SubscriptionStore.isActive(productID: ProductID.monthly, revocationDate: nil, expirationDate: now.addingTimeInterval(-1), now: now))
        #expect(!SubscriptionStore.isActive(productID: ProductID.yearly, revocationDate: now, expirationDate: nil, now: now))
        #expect(!SubscriptionStore.isActive(productID: "other.product", revocationDate: nil, expirationDate: nil, now: now))
    }
}
