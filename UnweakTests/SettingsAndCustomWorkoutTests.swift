import Foundation
import Testing
@testable import Unweak

struct ReminderScheduleTests {
    @Test func noTriggersWhenSwitchedOff() {
        let schedule = ReminderSchedule()
        #expect(!schedule.isEnabled)
        #expect(schedule.triggers.isEmpty)
    }

    @Test func oneRepeatingTriggerPerChosenDayMondayFirst() {
        var schedule = ReminderSchedule()
        schedule.isEnabled = true
        schedule.weekdays = [1, 2, 6] // Sunday, Monday, Friday
        #expect(schedule.orderedWeekdays == [2, 6, 1])
        #expect(schedule.triggers == [
            DateComponents(hour: 18, minute: 0, weekday: 2),
            DateComponents(hour: 18, minute: 0, weekday: 6),
            DateComponents(hour: 18, minute: 0, weekday: 1),
        ])
    }

    @Test func defaultIsMondayWednesdayFridayAtSix() {
        let schedule = ReminderSchedule()
        #expect(schedule.weekdays == [2, 4, 6])
        #expect(schedule.hour == 18 && schedule.minute == 0)
    }

    @Test func togglingADay() {
        var schedule = ReminderSchedule()
        schedule.toggle(4)
        #expect(schedule.weekdays == [2, 6])
        schedule.toggle(7)
        #expect(schedule.weekdays == [2, 6, 7])
    }

    @Test func timeMovesInHalfHoursAndWrapsAroundMidnight() {
        var schedule = ReminderSchedule()
        schedule.shiftTime(by: 1)
        #expect(schedule.hour == 18 && schedule.minute == 30)
        schedule.minutes = 0
        schedule.shiftTime(by: -1)
        #expect(schedule.hour == 23 && schedule.minute == 30)
        schedule.shiftTime(by: 1)
        #expect(schedule.minutes == 0)
    }
}

@MainActor
struct ReminderSettingsTests {
    private func freshDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "unweak-tests-\(UUID().uuidString)"))
    }

    @Test func savesAndLoadsAgain() throws {
        let defaults = try freshDefaults()
        let settings = ReminderSettings(defaults: defaults)
        settings.schedule.isEnabled = true
        settings.schedule.weekdays = [3, 5]
        settings.schedule.minutes = 7 * 60 + 30

        let reloaded = ReminderSettings(defaults: defaults)
        #expect(reloaded.schedule == settings.schedule)
    }

    @Test func chosenDaysAreTheWeeklyTarget() throws {
        let defaults = try freshDefaults()
        let settings = ReminderSettings(defaults: defaults)
        #expect(settings.weeklyTarget == 3)
        settings.schedule.weekdays = [2, 3, 5, 7]
        #expect(settings.weeklyTarget == 4)
        #expect(WeeklyTarget.current(in: defaults) == 4)
        settings.schedule.weekdays = []
        #expect(settings.weeklyTarget == 3)
    }
}

struct ReminderTextTests {
    @Test func referenceDatesHaveTheRightWeekday() {
        for weekday in 1...7 {
            #expect(Calendar.current.component(.weekday, from: ReminderText.date(forWeekday: weekday)) == weekday)
        }
    }

    @Test func germanNamesAndTime() {
        let german = Locale(identifier: "de")
        #expect(ReminderText.fullName(2, locale: german) == "Montag")
        var schedule = ReminderSchedule()
        schedule.weekdays = [2, 4, 6]
        let days = ReminderText.dayList(schedule, locale: german)
        #expect(days.hasPrefix("Mo"))
        #expect(days.contains(" und "))
        #expect(ReminderText.time(schedule, locale: german) == "18:00")
    }

    @Test func englishNames() {
        #expect(ReminderText.fullName(1, locale: Locale(identifier: "en")) == "Sunday")
    }
}

struct AppLanguageTests {
    @Test func followsThePhoneIfItIsGermanOrEnglish() {
        #expect(AppLanguage.system(preferredLanguages: ["de-AT", "en-US"]) == .de)
        #expect(AppLanguage.system(preferredLanguages: ["fr-FR", "en-US"]) == .en)
        #expect(AppLanguage.system(preferredLanguages: ["fr-FR", "de-CH"]) == .de)
        #expect(AppLanguage.system(preferredLanguages: ["it"]) == .en)
        #expect(AppLanguage.system(preferredLanguages: []) == .en)
    }

    @Test func storedChoiceWins() {
        #expect(AppLanguage.resolve(stored: "en", preferredLanguages: ["de-DE"]) == .en)
        #expect(AppLanguage.resolve(stored: "", preferredLanguages: ["de-DE"]) == .de)
        #expect(AppLanguage.resolve(stored: nil, preferredLanguages: ["en-GB"]) == .en)
    }

    @Test func choosingThePhoneLanguageFollowsThePhoneAgain() {
        #expect(AppLanguage.storedValue(for: .de, preferredLanguages: ["de-DE"]).isEmpty)
        #expect(AppLanguage.storedValue(for: .en, preferredLanguages: ["de-DE"]) == "en")
    }

    @Test func lookupInBothLanguages() {
        #expect(LocalizedLookup.string("Save", language: .de) == "Speichern")
        #expect(LocalizedLookup.string("Save", language: .en) == "Save")
        #expect(LocalizedLookup.string("exercise.pullUp.name", table: CatalogText.table, language: .de) == "Klimmzug")
        #expect(LocalizedLookup.string("Time for your workout. Your plan is ready.", language: .de) != "Time for your workout. Your plan is ready.")
    }
}

@MainActor
struct CustomWorkoutTests {
    private let catalog = Catalog.main

    @Test func needsANameAndAnExercise() {
        var workout = CustomWorkout(name: "  ")
        #expect(!workout.isComplete)
        workout.name = "Morning"
        #expect(!workout.isComplete)
        workout.exercises = [catalog.defaultItem(for: "pushUp")]
        #expect(workout.isComplete)
    }

    @Test func becomesAPlanWithItsOwnName() {
        let workout = CustomWorkout(
            name: " Evening pull ",
            category: .pull,
            exercises: [catalog.defaultItem(for: "row"), catalog.defaultItem(for: "pullUp")]
        )
        let plan = workout.plan(in: catalog)
        #expect(plan.id == "custom." + workout.id.uuidString)
        #expect(plan.customName == "Evening pull")
        #expect(plan.category == .pull)
        #expect(plan.level == .intermediate) // pull-up is the hardest exercise
        #expect(plan.pose == .pullUp)
        #expect(plan.isFree)
    }

    @Test func defaultTargetsComeFromThePlans() {
        #expect(catalog.defaultItem(for: "plank").target == .seconds(30))
        #expect(catalog.defaultItem(for: "pushUp").target == .reps(6))
        let unknown = catalog.defaultItem(for: "unknown")
        #expect(unknown.sets == 3 && unknown.target == .reps(8) && unknown.rest == 60)
    }

    @Test func setsAndTargetsStayInRange() {
        let reps = catalog.defaultItem(for: "pushUp")
        #expect(reps.withSets(0).sets == 1)
        #expect(reps.withSets(11).sets == 10)
        #expect(reps.withTargetValue(0).target == .reps(1))
        #expect(reps.withTargetValue(150).target == .reps(100))
        let hold = catalog.defaultItem(for: "plank")
        #expect(hold.withTargetValue(1).target == .seconds(5))
        #expect(hold.withTargetValue(35).target == .seconds(35))
    }

    @Test func storeSavesFindsAndDeletesCustomWorkouts() {
        let store = UserDataStore(fileURL: nil)
        var workout = CustomWorkout(name: "Legs", category: .legs, exercises: [catalog.defaultItem(for: "squat")])
        store.save(workout)
        #expect(store.plan(workout.planID, in: catalog)?.customName == "Legs")

        workout.name = "Legs 2"
        store.save(workout)
        #expect(store.customWorkouts.count == 1)
        #expect(store.plan(workout.planID, in: catalog)?.customName == "Legs 2")

        store.delete(workout)
        #expect(store.customWorkouts.isEmpty)
        #expect(store.plan(workout.planID, in: catalog) == nil)
        #expect(store.plan("pushBasics", in: catalog)?.id == "pushBasics")
    }
}

@MainActor
struct UserDataCompatibilityTests {
    @Test func readsFilesWithoutCustomWorkouts() throws {
        // Format written by step 4.
        let json = #"{"activeGoalID":"frontLever","entries":[],"reachedStages":{"frontLever":2},"version":1}"#
        let data = try JSONDecoder.userData.decode(UserData.self, from: Data(json.utf8))
        // The single active skill of older files becomes a one-element list.
        #expect(data.activeGoalIDs == ["frontLever"])
        #expect(data.reachedStages == ["frontLever": 2])
        #expect(data.customWorkouts.isEmpty)
    }

    @Test func keepsACopyOfAnUnreadableFile() throws {
        let folder = FileManager.default.temporaryDirectory.appending(path: "unweak-tests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: folder) }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appending(path: "userdata.json")
        try Data("{ broken".utf8).write(to: file)

        let store = UserDataStore(fileURL: file)
        #expect(store.entries.isEmpty)
        let names = try FileManager.default.contentsOfDirectory(atPath: folder.path())
        #expect(names.contains { $0.contains("unreadable") })
    }
}
