import Foundation
import Observation

/// Everything the user creates, saved as one file so that backup and sync (step 6)
/// can treat it as a whole.
struct UserData: Codable, Equatable, Sendable {
    var version = 1
    var entries: [JournalEntry] = []
    /// Skills the user is learning, in the order they were added. `nil` until the user
    /// chooses: then the first skill of the catalog counts as learned.
    var activeGoalIDs: [String]?
    /// Number of reached stages per skill goal.
    var reachedStages: [String: Int] = [:]
    var customWorkouts: [CustomWorkout] = []
    /// How the user's avatar looks.
    var avatar = AvatarStyle()

    init(
        entries: [JournalEntry] = [],
        activeGoalIDs: [String]? = nil,
        reachedStages: [String: Int] = [:],
        customWorkouts: [CustomWorkout] = [],
        avatar: AvatarStyle = AvatarStyle()
    ) {
        self.entries = entries
        self.activeGoalIDs = activeGoalIDs
        self.reachedStages = reachedStages
        self.customWorkouts = customWorkouts
        self.avatar = avatar
    }

    /// Fields missing in files from older versions get their defaults.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        entries = try container.decodeIfPresent([JournalEntry].self, forKey: .entries) ?? []
        // Older files held a single active skill under "activeGoalID".
        let legacy = try decoder.container(keyedBy: LegacyKeys.self)
        if let ids = try container.decodeIfPresent([String].self, forKey: .activeGoalIDs) {
            activeGoalIDs = ids
        } else if let id = try legacy.decodeIfPresent(String.self, forKey: .activeGoalID) {
            activeGoalIDs = [id]
        }
        reachedStages = try container.decodeIfPresent([String: Int].self, forKey: .reachedStages) ?? [:]
        customWorkouts = try container.decodeIfPresent([CustomWorkout].self, forKey: .customWorkouts) ?? []
        avatar = try container.decodeIfPresent(AvatarStyle.self, forKey: .avatar) ?? AvatarStyle()
    }
}

extension UserData {
    /// Keys of older file formats that are still read.
    private enum LegacyKeys: String, CodingKey {
        case activeGoalID
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

    /// IDs of the skills being learned; before the first choice the first skill of the catalog.
    func activeGoalIDs(in catalog: Catalog) -> [String] {
        data.activeGoalIDs ?? catalog.goals.first.map { [$0.id] } ?? []
    }

    /// The skills being learned, in the order they were added.
    func activeGoals(in catalog: Catalog) -> [Goal] {
        activeGoalIDs(in: catalog).compactMap { id in catalog.goals.first { $0.id == id } }
    }

    func isLearning(_ goal: Goal, in catalog: Catalog) -> Bool {
        activeGoalIDs(in: catalog).contains(goal.id)
    }

    /// Starts or stops learning a skill. Several skills can be learned at once.
    /// A skill that is already learned keeps its place; a new one goes to the end.
    func setLearning(_ learning: Bool, _ goal: Goal, in catalog: Catalog) {
        var ids = activeGoalIDs(in: catalog)
        if learning {
            // Still saved when already in the list: the default skill becomes a real choice.
            if !ids.contains(goal.id) { ids.append(goal.id) }
        } else {
            ids.removeAll { $0 == goal.id }
        }
        data.activeGoalIDs = ids
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
