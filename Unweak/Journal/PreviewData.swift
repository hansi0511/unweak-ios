import SwiftUI

extension UserDataStore {
    /// In-memory store with a few weeks of sample workouts, for Xcode Previews.
    static func preview(now: Date = .now, catalog: Catalog = .main) -> UserDataStore {
        let calendar = Calendar.trainingWeek
        let free = catalog.plans.filter(\.isFree)
        var entries: [JournalEntry] = []
        // Three workouts per week for the last three weeks, two so far this week.
        for (index, daysAgo) in [1, 3, 8, 10, 12, 15, 17, 19].enumerated() {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            var entry = JournalEntry(plan: free[index % free.count], date: date)
            if index == 0, !entry.results.isEmpty {
                entry.results[0].value += 2 // a record in the newest workout
            }
            entry.rating = WorkoutRating.allCases[index % WorkoutRating.allCases.count]
            entries.append(entry)
        }
        var data = UserData(entries: entries)
        data.activeGoalID = catalog.goals.first?.id
        if let goal = catalog.goals.first { data.reachedStages[goal.id] = 2 }
        return UserDataStore(fileURL: nil, initial: data)
    }
}

extension View {
    /// Environment needed by the app screens, with sample data. For Xcode Previews.
    func previewEnvironment() -> some View {
        environment(UserDataStore.preview())
            .environment(AppNavigation())
            .environment(ReminderSettings(defaults: UserDefaults(suiteName: "unweak.preview") ?? .standard))
    }
}
