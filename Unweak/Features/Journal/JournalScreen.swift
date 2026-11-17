import SwiftUI

/// Journal tab: month figures and all workouts, newest first. Records are highlighted.
struct JournalScreen: View {
    @Environment(\.locale) private var locale
    @Environment(UserDataStore.self) private var store
    @State private var isPickingPlan = false
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
            ScreenHeader(label: MonoLabel(verbatim: monthTitle), title: "Journal") {
                IconButton(systemImage: "plus", accessibilityLabel: "Add workout") {
                    isPickingPlan = true
                }
            }

            HStack(spacing: 10) {
                MetricTile(value: Text(verbatim: "\(month.workouts)"), label: "Sessions")
                MetricTile(value: ValueText.totalTime(month.seconds), label: "Time")
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
                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        NavigationLink(value: JournalRoute.entry(entry.id)) {
                            JournalRow(entry: entry, records: stats.records(in: entry), catalog: catalog)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
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
                if let plan = catalog.plan(planID) {
                    JournalEntryScreen(entry: JournalEntry(plan: plan, date: .now), catalog: catalog)
                }
            }
        }
        .sheet(isPresented: $isPickingPlan) {
            PlanPickerSheet(catalog: catalog)
        }
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
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let entry: JournalEntry
    let records: [ExerciseResult]
    let catalog: Catalog

    private var plan: WorkoutPlan? { entry.planID.flatMap(catalog.plan) }

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
        if let plan { Text(catalog: plan.nameKey) } else { Text("Workout") }
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
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    let catalog: Catalog

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
                ForEach(catalog.plans.filter(\.isFree)) { plan in
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
    .environment(AppNavigation())
    .environment(\.locale, Locale(identifier: "de"))
}
