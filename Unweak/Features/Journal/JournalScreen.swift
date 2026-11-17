import SwiftUI

/// The two areas of the journey tab.
private enum JournalArea {
    /// Records per exercise, month figures and the workouts.
    case stats
    case achievements
}

/// Journey tab. "Stats": the best value of every exercise as tiles, the month figures and
/// all workouts, newest first, with records highlighted. "Achievements": all achievements.
struct JournalScreen: View {
    @Environment(\.locale) private var locale
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @State private var area: JournalArea = .stats
    @State private var isPickingPlan = false
    @State private var shareContent: ShareContent?
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private var monthTitle: String {
        Date.now.formatted(.dateTime.month(.wide).year().locale(locale))
    }

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let month = stats.month(containing: .now)
        let entries = store.sortedEntries

        ScreenContainer {
            ScreenHeader(label: MonoLabel(verbatim: monthTitle), title: "Journey") {
                IconButton(systemImage: "plus", accessibilityLabel: "Add workout") {
                    isPickingPlan = true
                }
            }

            HStack(spacing: 8) {
                SelectChip("Stats", isSelected: area == .stats, expands: true) {
                    area = .stats
                }
                SelectChip("Achievements", isSelected: area == .achievements, expands: true) {
                    area = .achievements
                }
            }

            switch area {
            case .stats:
                let bests = stats.personalBests()
                if !bests.isEmpty {
                    PersonalBestsRow(bests: bests, catalog: catalog)
                }

                HStack(spacing: 10) {
                    MetricTile(value: Text(verbatim: "\(month.workouts)"), label: "Sessions")
                    MetricTile(value: ValueText.totalTime(month.seconds, locale: locale), label: "Time")
                    MetricTile(value: Text(verbatim: "\(month.records)"), label: "Records")
                }

                if entries.isEmpty {
                    Card {
                        VStack(alignment: .leading, spacing: 6) {
                            MonoLabel("No workouts yet", bold: true)
                            Text("Finish a workout or tap + to add one.")
                                .font(.text(15))
                                .foregroundStyle(Theme.textSoft)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        MonoLabel("Recent workouts")
                            .accessibilityAddTraits(.isHeader)
                        ForEach(entries) { entry in
                            NavigationLink(value: JournalRoute.entry(entry.id)) {
                                JournalRow(entry: entry, records: stats.records(in: entry), catalog: catalog)
                            }
                            .buttonStyle(PressFeedbackStyle())
                        }
                    }
                }
            case .achievements:
                AchievementsGrid(
                    progress: catalog.achievements.map { stats.progress(of: $0, target: reminders.weeklyTarget) }
                ) { achievement in
                    shareContent = .achievement(achievement)
                }
            }
        }
        .navigationDestination(for: JournalRoute.self) { route in
            switch route {
            case .entry(let id):
                if let entry = store.entry(id) {
                    JournalEntryScreen(entry: entry, catalog: catalog)
                }
            case .newEntry(let planID):
                if let plan = store.plan(planID, in: catalog) {
                    JournalEntryScreen(entry: JournalEntry(plan: plan, date: .now), catalog: catalog)
                }
            }
        }
        .sheet(isPresented: $isPickingPlan) {
            PlanPickerSheet(catalog: catalog)
        }
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }
}

/// The best value of every exercise as tiles that scroll sideways, most recent first.
private struct PersonalBestsRow: View {
    let bests: [PersonalBest]
    let catalog: Catalog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel("Records")
                .accessibilityAddTraits(.isHeader)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(bests) { best in
                        PersonalBestTile(best: best, exercise: catalog.exercise(best.exercise))
                    }
                }
                // The row runs to the screen edges while the tiles start in line with the content.
                .padding(.horizontal, Theme.Layout.screenEdge)
            }
            .padding(.horizontal, -Theme.Layout.screenEdge)
        }
    }
}

/// One exercise's best value: pose, value, exercise name and the day it was reached.
private struct PersonalBestTile: View {
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let best: PersonalBest
    let exercise: Exercise?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let exercise {
                StickyPoseView(exercise.pose)
                    .accessibilityHidden(true)
            }
            ValueText.result(best.value, unit: best.unit)
                .font(.metric)
                .foregroundStyle(accent.color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Group {
                if let exercise {
                    Text(catalog: exercise.nameKey)
                } else {
                    Text(verbatim: best.exercise)
                }
            }
            .font(.textSemibold(13))
            .foregroundStyle(Theme.text)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            MonoLabel(verbatim: best.date.formatted(.dateTime.day().month(.abbreviated).locale(locale)))
        }
        .padding(12)
        .frame(width: 132, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}

/// Small card with a large value and a label below.
struct MetricTile: View {
    private let value: Text
    private let label: LocalizedStringKey

    init(value: Text, label: LocalizedStringKey) {
        self.value = value
        self.label = label
    }

    var body: some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 4) {
                value
                    .font(.metric)
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                MonoLabel(label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// One workout in the journal list.
private struct JournalRow: View {
    @Environment(UserDataStore.self) private var store
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let entry: JournalEntry
    let records: [ExerciseResult]
    let catalog: Catalog

    private var plan: WorkoutPlan? { entry.planID.flatMap { store.plan($0, in: catalog) } }

    var body: some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(verbatim: entry.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale)))
                HStack(spacing: 12) {
                    StickyPoseView(plan?.pose ?? .pushUp, highlighted: !records.isEmpty)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        planName
                            .font(.textSemibold(17))
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.leading)
                        summary
                    }
                    Spacer(minLength: 0)
                    ValueText.minutes(entry.durationSeconds)
                        .font(.mono)
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var planName: Text {
        if let plan { plan.title } else { Text("Workout") }
    }

    @ViewBuilder
    private var summary: some View {
        if let record = records.first, let exercise = catalog.exercise(record.exercise) {
            HStack(spacing: 4) {
                Text("Record: \(Text(catalog: exercise.nameKey))")
                Text(verbatim: "·")
                ValueText.result(record.value, unit: record.unit)
            }
            .font(.textSemibold(13))
            .foregroundStyle(accent.color)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        } else {
            Text("Exercises \(entry.results.count) · Sets \(entry.totalSets)")
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
        }
    }
}

/// Choose the plan for a workout added by hand.
private struct PlanPickerSheet: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    let catalog: Catalog

    /// Custom workouts first, then the catalog plans the user can train.
    private var pickablePlans: [WorkoutPlan] {
        let access = subscription.access
        let custom: [WorkoutPlan] = store.customWorkouts.map { $0.plan(in: catalog) }
        let available: [WorkoutPlan] = catalog.plans.filter { access.canTrain($0) }
        return custom + available
    }

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
            }
            Text("Add workout")
                .font(.screenTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            Text("Choose the plan you trained.")
                .font(.text(15))
                .foregroundStyle(Theme.textSoft)
            VStack(spacing: 10) {
                ForEach(pickablePlans) { plan in
                    Button {
                        navigation?.journalPath.append(.newEntry(planID: plan.id))
                        dismiss()
                    } label: {
                        PlanRow(plan: plan)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .presentationBackground(Theme.background)
    }
}

#Preview {
    NavigationStack {
        JournalScreen()
    }
    .previewEnvironment()
}

#Preview("German, empty") {
    NavigationStack {
        JournalScreen()
    }
    .environment(UserDataStore(fileURL: nil))
    .environment(ReminderSettings(defaults: UserDefaults(suiteName: "unweak.preview") ?? .standard))
    .environment(AppNavigation())
    .environment(SubscriptionStore.preview(isPro: false))
    .environment(\.locale, Locale(identifier: "de"))
}
