import Foundation
import Testing
@testable import Unweak

private func unlocks(workouts: Int = 0, achievements: Set<String> = [], skill: Bool = false) -> AvatarUnlocks {
    AvatarUnlocks(workouts: workouts, achievements: achievements, hasMasteredSkill: skill)
}

struct AvatarUnlockTests {
    @Test func bodyGrowsWithWorkoutsAndSkills() {
        #expect(unlocks(workouts: 0).highestBody == .start)
        #expect(unlocks(workouts: 9).highestBody == .start)
        #expect(unlocks(workouts: 10).highestBody == .athlete)
        #expect(unlocks(workouts: 49).highestBody == .athlete)
        #expect(unlocks(workouts: 50).highestBody == .trained)
        #expect(unlocks(workouts: 50, skill: true).highestBody == .legend)
    }

    @Test func nextBodyAndMissingWorkouts() {
        #expect(unlocks(workouts: 3).nextBody == .athlete)
        #expect(unlocks(workouts: 3).workoutsToNextBody == 7)
        #expect(unlocks(workouts: 12).workoutsToNextBody == 38)
        // Legend is unlocked by a skill, not by workouts.
        #expect(unlocks(workouts: 60).nextBody == .legend)
        #expect(unlocks(workouts: 60).workoutsToNextBody == nil)
        #expect(unlocks(workouts: 60, skill: true).nextBody == nil)
    }

    @Test func chosenBodyIsLimitedToUnlockedOnes() {
        let grown = unlocks(workouts: 50)
        #expect(grown.body(for: AvatarStyle()) == .trained)
        #expect(grown.body(for: AvatarStyle(body: .start)) == .start)
        // A locked choice falls back to the highest unlocked body.
        #expect(grown.body(for: AvatarStyle(body: .legend)) == .trained)
    }

    @Test func extrasNeedTheirAchievement() {
        let some = unlocks(achievements: ["firstWorkout", "streak4"])
        #expect(some.isUnlocked(AvatarExtra.headband))
        #expect(some.isUnlocked(AvatarExtra.visor))
        #expect(!some.isUnlocked(AvatarExtra.cap))
        #expect(!some.isUnlocked(AvatarExtra.crown))
        #expect(unlocks(skill: true).isUnlocked(AvatarExtra.crown))
        #expect(some.extra(for: AvatarStyle(extra: .headband)) == .headband)
        #expect(some.extra(for: AvatarStyle(extra: .medal)) == nil)
    }

    @Test func everyExtraPointsToAnExistingAchievement() {
        let ids = Set(Catalog.main.achievements.map(\.id))
        for extra in AvatarExtra.allCases {
            if case .achievement(let id) = extra.unlock {
                #expect(ids.contains(id), "\(extra) needs \(id)")
            }
        }
    }

    @Test func unlocksFromTheJournal() throws {
        let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let entries = (0..<10).map { day in
            JournalEntry(date: start.addingTimeInterval(Double(day) * 86_400), planID: "pushBasics", durationSeconds: 1_200, results: [])
        }
        let stats = JournalStats(entries: entries)
        let result = AvatarUnlocks(stats: stats, catalog: .main, weeklyTarget: 3) { _ in 0 }
        #expect(result.workouts == 10)
        #expect(result.achievements.contains("firstWorkout"))
        #expect(result.achievements.contains("workouts10"))
        #expect(!result.hasMasteredSkill)
        #expect(result.highestBody == .athlete)

        let skill = try #require(Catalog.main.goals.first { $0.id == "frontLever" })
        let mastered = AvatarUnlocks(stats: stats, catalog: .main, weeklyTarget: 3) { $0.id == skill.id ? 5 : 0 }
        #expect(mastered.hasMasteredSkill)
    }
}

struct AvatarStyleTests {
    @Test func oldFilesWithoutAvatarLoadWithTheDefault() throws {
        let json = Data(#"{"version":1,"entries":[]}"#.utf8)
        let data = try JSONDecoder.userData.decode(UserData.self, from: json)
        #expect(data.avatar == AvatarStyle())
    }

    @Test func unknownValuesFallBackToDefaults() throws {
        let json = Data(#"{"color":"gold","extraColor":"pink","background":"space","extra":"wings"}"#.utf8)
        let style = try JSONDecoder().decode(AvatarStyle.self, from: json)
        #expect(style.color == .lime)
        #expect(style.extraColor == .pink)
        #expect(style.background == .dark)
        #expect(style.extra == nil)
    }

    @MainActor
    @Test func avatarIsSavedAndLoaded() throws {
        let file = FileManager.default.temporaryDirectory
            .appending(path: "unweak-avatar-\(UUID().uuidString)")
            .appending(path: "userdata.json")
        defer { try? FileManager.default.removeItem(at: file.deletingLastPathComponent()) }
        let style = AvatarStyle(color: .violet, extraColor: .lime, background: .night, extra: .headphones, body: .athlete)
        UserDataStore(fileURL: file).setAvatar(style)
        #expect(UserDataStore(fileURL: file).data.avatar == style)
    }

    @Test(arguments: AvatarBody.allCases)
    func figureStaysOnItsGrid(_ body: AvatarBody) {
        for extra in [nil] + AvatarExtra.allCases.map(Optional.some) {
            let figure = AvatarFigure(body: body, extra: extra)
            let points = (figure.body + figure.extra).flatMap(\.points)
            for point in points {
                #expect((0...AvatarFigure.size).contains(point.x), "\(body) \(String(describing: extra))")
                #expect((0...AvatarFigure.size).contains(point.y), "\(body) \(String(describing: extra))")
            }
        }
    }
}
