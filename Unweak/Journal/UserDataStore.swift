import Foundation
import Observation

/// Everything the user creates, saved as one file so that backup and sync (step 6)
/// can treat it as a whole.
struct UserData: Codable, Equatable, Sendable {
    var version = 1
    var entries: [JournalEntry] = []
    var activeGoalID: String?
    /// Number of reached stages per skill goal.
    var reachedStages: [String: Int] = [:]
    var customWorkouts: [CustomWorkout] = []
    /// How the user's avatar looks.
    var avatar = AvatarStyle()

    init(
        entries: [JournalEntry] = [],
        activeGoalID: String? = nil,
        reachedStages: [String: Int] = [:],
        customWorkouts: [CustomWorkout] = [],
        avatar: AvatarStyle = AvatarStyle()
    ) {
        self.entries = entries
        self.activeGoalID = activeGoalID
        self.reachedStages = reachedStages
        self.customWorkouts = customWorkouts
        self.avatar = avatar
    }

    /// Fields missing in files from older versions get their defaults.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        entries = try container.decodeIfPresent([JournalEntry].self, forKey: .entries) ?? []
        activeGoalID = try container.decodeIfPresent(String.self, forKey: .activeGoalID)
        reachedStages = try container.decodeIfPresent([String: Int].self, forKey: .reachedStages) ?? [:]
        customWorkouts = try container.decodeIfPresent([CustomWorkout].self, forKey: .customWorkouts) ?? []
        avatar = try container.decodeIfPresent(AvatarStyle.self, forKey: .avatar) ?? AvatarStyle()
    }
}

/// Holds and persists `UserData` in `Application Support/userdata.json`.
@MainActor
@Observable
final class UserDataStore {
    private(set) var data: UserData
    /// Set when the last save failed; the data stays in memory.
    private(set) var saveError: String?
    private let fileURL: URL?

    /// - Parameter fileURL: `nil` keeps everything in memory (previews).
    init(fileURL: URL?, initial: UserData = UserData()) {
        self.fileURL = fileURL
        guard let fileURL, let stored = try? Data(contentsOf: fileURL) else {
            data = initial
            return
        }
        if let decoded = try? JSONDecoder.userData.decode(UserData.self, from: stored) {
            data = decoded
        } else {
            // Never overwrite a file we cannot read: keep a copy next to it first.
            let backup = fileURL.deletingPathExtension()
                .appendingPathExtension("unreadable-\(Int(Date.now.timeIntervalSince1970)).json")
            try? FileManager.default.copyItem(at: fileURL, to: backup)
            data = initial
        }
    }

    static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "userdata.json")
    }

    var entries: [JournalEntry] { data.entries }

    /// Entries, newest first.
    var sortedEntries: [JournalEntry] { data.entries.sorted { $0.date > $1.date } }

    func entry(_ id: JournalEntry.ID) -> JournalEntry? {
        data.entries.first { $0.id == id }
    }

    /// Adds the entry or replaces the one with the same ID.
    func save(_ entry: JournalEntry) {
        if let index = data.entries.firstIndex(where: { $0.id == entry.id }) {
            data.entries[index] = entry
        } else {
            data.entries.append(entry)
        }
        persist()
    }

    // MARK: Custom workouts

    var customWorkouts: [CustomWorkout] { data.customWorkouts }

    /// Adds the workout or replaces the one with the same ID.
    func save(_ workout: CustomWorkout) {
        if let index = data.customWorkouts.firstIndex(where: { $0.id == workout.id }) {
            data.customWorkouts[index] = workout
        } else {
            data.customWorkouts.append(workout)
        }
        persist()
    }

    /// Removes the workout. Journal entries of it stay and show as "Workout".
    func delete(_ workout: CustomWorkout) {
        data.customWorkouts.removeAll { $0.id == workout.id }
        persist()
    }

    /// Catalog plan or custom workout for a plan ID.
    func plan(_ id: String, in catalog: Catalog) -> WorkoutPlan? {
        if let plan = catalog.plan(id) { return plan }
        return data.customWorkouts.first { $0.planID == id }?.plan(in: catalog)
    }

    // MARK: Goals

    func setActiveGoal(_ goalID: String) {
        data.activeGoalID = goalID
        persist()
    }

    func reachedStages(of goal: Goal) -> Int {
        data.reachedStages[goal.id] ?? 0
    }

    /// Marks the next stage of a skill goal as reached.
    func markStageReached(of goal: Goal) {
        setReachedStages(reachedStages(of: goal) + 1, of: goal)
    }

    /// Sets how many stages of a skill goal are reached (0...stage count). Stages build
    /// on each other: reaching stage n reaches all before it, taking it back takes back
    /// all after it.
    func setReachedStages(_ reached: Int, of goal: Goal) {
        guard case .stages(let count) = goal.kind else { return }
        data.reachedStages[goal.id] = min(max(reached, 0), count)
        persist()
    }

    // MARK: Avatar

    func setAvatar(_ style: AvatarStyle) {
        data.avatar = style
        persist()
    }

    private func persist() {
        guard let fileURL else { return }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder.userData.encode(data).write(to: fileURL, options: .atomic)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }
}

extension JSONEncoder {
    static var userData: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    static var userData: JSONDecoder {
        JSONDecoder()
    }
}
