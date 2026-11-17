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
        if let fileURL, let stored = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder.userData.decode(UserData.self, from: stored) {
            data = decoded
        } else {
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

    func setActiveGoal(_ goalID: String) {
        data.activeGoalID = goalID
        persist()
    }

    func reachedStages(of goal: Goal) -> Int {
        data.reachedStages[goal.id] ?? 0
    }

    /// Marks the next stage of a skill goal as reached.
    func markStageReached(of goal: Goal) {
        guard case .stages(let count) = goal.kind else { return }
        data.reachedStages[goal.id] = min(count, reachedStages(of: goal) + 1)
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
