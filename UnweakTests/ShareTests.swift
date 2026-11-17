import Foundation
import Testing
@testable import Unweak

struct ShareContentTests {
    private let catalog = Catalog.main

    @Test func workoutCardFromACatalogPlanWithRecord() throws {
        let plan = try #require(catalog.plan("pullDay"))
        let entry = JournalEntry(plan: plan, date: Date(timeIntervalSinceReferenceDate: 0))
        let record = ExerciseResult(exercise: "pullUp", sets: 3, value: 8, unit: .reps)

        let content = ShareContent.workoutCard(entry: entry, plan: plan, records: [record], catalog: catalog)
        guard case .workout(let workout) = content else {
            Issue.record("expected a workout card")
            return
        }
        #expect(workout.title == .catalog("plan.pullDay.name"))
        #expect(workout.exercises == plan.exercises.count)
        #expect(workout.sets == entry.totalSets)
        #expect(workout.durationSeconds == plan.estimatedSeconds)
        #expect(workout.record?.exerciseNameKey == "exercise.pullUp.name")
        #expect(workout.record?.value == 8)
        #expect(workout.animation == .row) // first exercise of Pull Day
    }

    @Test func workoutCardForCustomAndUnknownPlans() {
        let workout = CustomWorkout(name: "Garden", exercises: [catalog.defaultItem(for: "squat")])
        let plan = workout.plan(in: catalog)
        let entry = JournalEntry(plan: plan, date: .now)

        if case .workout(let custom) = ShareContent.workoutCard(entry: entry, plan: plan, records: [], catalog: catalog) {
            #expect(custom.title == .custom("Garden"))
            #expect(custom.record == nil)
            #expect(custom.animation == .squat)
        } else {
            Issue.record("expected a workout card")
        }

        let empty = JournalEntry(date: .now, planID: nil, durationSeconds: 60, results: [])
        if case .workout(let generic) = ShareContent.workoutCard(entry: empty, plan: nil, records: [], catalog: catalog) {
            #expect(generic.title == .generic)
            #expect(generic.animation == .pushUp)
        } else {
            Issue.record("expected a workout card")
        }
    }

    @Test func streakCardKeepsTheWeek() {
        let days = (0..<7).map { offset in
            WeekDay(date: Date(timeIntervalSinceReferenceDate: Double(offset) * 86_400), trained: offset.isMultiple(of: 2), isToday: offset == 3)
        }
        let week = WeekSummary(days: days, workouts: 4, target: 3)
        guard case .streak(let streak) = ShareContent.streakCard(week: week, weeks: 5) else {
            Issue.record("expected a streak card")
            return
        }
        #expect(streak.weeks == 5)
        #expect(streak.workoutsThisWeek == 4)
        #expect(streak.target == 3)
        #expect(streak.days == [true, false, true, false, true, false, true])
    }

    @Test func skillCardWithStages() throws {
        let goal = try #require(catalog.goals.first { $0.id == "frontLever" })
        let progress = GoalProgress(goal: goal, reachedStages: 2, bestSeconds: nil)
        guard case .skill(let skill) = ShareContent.skillCard(progress, catalog: catalog) else {
            Issue.record("expected a skill card")
            return
        }
        #expect(skill.state == .stages(reached: 2, count: 5, lastStageKey: "goal.frontLever.stage2"))
        #expect(skill.filledSegments == 2)
        #expect(skill.animation == .frontLever)
    }

    @Test func skillCardForATimeGoal() throws {
        let goal = try #require(catalog.goals.first { $0.id == "plank5Min" })
        let progress = GoalProgress(goal: goal, reachedStages: 0, bestSeconds: 120)
        guard case .skill(let skill) = ShareContent.skillCard(progress, catalog: catalog) else {
            Issue.record("expected a skill card")
            return
        }
        #expect(skill.state == .time(bestSeconds: 120, targetSeconds: 300))
        #expect(skill.filledSegments == 2)
    }

    @Test func imagesAre1080PixelsWide() {
        #expect(ShareFormat.story.size.width * ShareFormat.renderScale == 1080)
        #expect(ShareFormat.story.size.height * ShareFormat.renderScale == 1920)
        #expect(ShareFormat.post.size.height * ShareFormat.renderScale == 1350)
    }
}
