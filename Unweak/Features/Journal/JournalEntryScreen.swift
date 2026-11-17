import SwiftUI

/// Journal entry: exercises with their values, rating and note. Edits a draft that is
/// written to the store with "Save".
struct JournalEntryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(UserDataStore.self) private var store
    @State private var draft: JournalEntry
    private let catalog: Catalog

    /// - Parameter entry: An existing entry or a new, unsaved one. Leaving with "Back"
    ///   discards the changes.
    init(entry: JournalEntry, catalog: Catalog = .main) {
        _draft = State(initialValue: entry)
        self.catalog = catalog
    }

    private var plan: WorkoutPlan? { draft.planID.flatMap { store.plan($0, in: catalog) } }

    /// Records of the draft compared with all other entries.
    private var records: [ExerciseResult] {
        let others = store.entries.filter { $0.id != draft.id }
        return JournalStats(entries: others + [draft]).records(in: draft)
    }

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                }
                MetaLine([
                    Text(verbatim: draft.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale))),
                    ValueText.minutes(draft.durationSeconds),
                ])
                HStack(spacing: 12) {
                    StickyPoseView(plan?.pose ?? .pushUp)
                        .accessibilityHidden(true)
                    planName
                        .font(.screenTitle)
                        .foregroundStyle(Theme.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .accessibilityAddTraits(.isHeader)
                }
            }

            if !records.isEmpty {
                recordBanner
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Exercises")
                ForEach($draft.results, id: \.exercise) { $result in
                    ResultRow(result: $result, catalog: catalog)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("How did it feel?")
                HStack(spacing: 8) {
                    ForEach(WorkoutRating.allCases, id: \.self) { rating in
                        SelectChip(rating.title, isSelected: draft.rating == rating) {
                            draft.rating = draft.rating == rating ? nil : rating
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Note")
                TextField("How did the workout go?", text: $draft.note, axis: .vertical)
                    .font(.text(15))
                    .foregroundStyle(Theme.text)
                    .lineLimit(3...8)
                    .padding(12)
                    .frame(minHeight: Theme.Layout.minTouchTarget)
                    .background(Theme.surface)
                    .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
            }

            PrimaryButton("Save", systemImage: "checkmark") {
                store.save(draft)
                dismiss()
            }
        }
    }

    private var planName: Text {
        if let plan { plan.title } else { Text("Workout") }
    }

    private var recordBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.onAccent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    if records.count == 1 { Text("New record") } else { Text("New records") }
                }
                .font(.monoBold)
                .textCase(.uppercase)
                ForEach(records, id: \.exercise) { record in
                    if let exercise = catalog.exercise(record.exercise) {
                        HStack(spacing: 4) {
                            Text(catalog: exercise.nameKey)
                            Text(verbatim: "·")
                            ValueText.result(record.value, unit: record.unit)
                        }
                        .font(.textSemibold(15))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(Theme.onAccent)
        .padding(14)
        .background(accent.color)
        .glow(accent.color, radius: Theme.Glow.small)
        .accessibilityElement(children: .combine)
    }
}

/// One exercise with its sets and an adjustable best value.
private struct ResultRow: View {
    @Binding var result: ExerciseResult
    let catalog: Catalog

    private var step: Int { result.unit == .reps ? 1 : 5 }

    var body: some View {
        Card(padding: 12) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    if let exercise = catalog.exercise(result.exercise) {
                        Text(catalog: exercise.nameKey)
                            .font(.textSemibold(15))
                            .foregroundStyle(Theme.text)
                    }
                    MonoLabel("\(result.sets) sets")
                }
                Spacer(minLength: 0)
                IconButton(systemImage: "minus", accessibilityLabel: "Less") {
                    result.value = max(0, result.value - step)
                }
                ValueText.result(result.value, unit: result.unit)
                    .font(.metric)
                    .monospacedDigit()
                    .foregroundStyle(Theme.text)
                    .frame(minWidth: 72)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                IconButton(systemImage: "plus", accessibilityLabel: "More") {
                    result.value += step
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    let store = UserDataStore.preview()
    return NavigationStack {
        if let entry = store.sortedEntries.first {
            JournalEntryScreen(entry: entry)
        }
    }
    .environment(store)
    .environment(AppNavigation())
}

#Preview("German") {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            JournalEntryScreen(entry: JournalEntry(plan: plan, date: .now))
        }
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
