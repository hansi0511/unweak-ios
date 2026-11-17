import Foundation
import Testing
@testable import Unweak

struct CatalogTests {
    private let catalog = Catalog.main

    @Test func loadsWithoutProblems() throws {
        let loaded = try Catalog.load()
        #expect(loaded.problems().isEmpty)
        #expect(loaded.exercises.count == 16)
        #expect(loaded.plans.count == 7)
        #expect(loaded.goals.count == 6)
    }

    @Test func fivePlansAreFree() {
        #expect(catalog.freePlanCount == 5)
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
        let broken = Catalog(exercises: catalog.exercises, plans: [plan], goals: [])
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
        let broken = Catalog(exercises: catalog.exercises, plans: [plan], goals: [])
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

struct WorkoutFilterTests {
    @Test func offersAllAndEveryCategory() {
        #expect(WorkoutFilter.allFilters.count == ExerciseCategory.allCases.count + 1)
        #expect(WorkoutFilter.allFilters.first == .all)
        #expect(WorkoutFilter.all.category == nil)
        #expect(WorkoutFilter.category(.legs).category == .legs)
    }
}
