import SwiftUI

/// "Workout done" (Design V2, `V2-Fertig`): check mark, "Pull Day done", the date, three
/// numbers (minutes, exercises, records), a new record if there is one, "How was it?",
/// an optional note and "Save". It replaces the journal entry screen.
struct WorkoutDoneScreen: View {
    /// Where the screen is shown; decides what close (✕) and "Save" do.
    enum Mode {
        /// Right after a workout. ✕ saves too, so no workout is lost; "Save" also opens the Journey.
        case afterWorkout
        /// An entry from the Journey. ✕ leaves without the changes.
        case existing
        /// A workout added by hand from the Journey. ✕ discards it.
        case addedByHand
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    @Environment(UserDataStore.self) private var store
    @State private var draft: JournalEntry
    @State private var shareContent: ShareContent?
    @State private var isWritingNote: Bool
    @State private var isAdjustingValues = false
    private let mode: Mode
    private let catalog: Catalog

    init(entry: JournalEntry, mode: Mode, catalog: Catalog = .main) {
        _draft = State(initialValue: entry)
        _isWritingNote = State(initialValue: !entry.note.isEmpty)
        self.mode = mode
        self.catalog = catalog
    }

    private var plan: WorkoutPlan? { draft.planID.flatMap { store.plan($0, in: catalog) } }

    /// Records of the draft compared with all other entries.
    private var records: [ExerciseResult] {
        let others = store.entries.filter { $0.id != draft.id }
        return JournalStats(entries: others + [draft]).records(in: draft)
    }

    var body: some View {
        let records = records

        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    close()
                }
                Spacer()
                IconButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share") {
                    shareContent = .workoutCard(entry: draft, plan: plan, records: records, catalog: catalog)
                }
            }

            VStack(spacing: 10) {
                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.onAccent)
                    .frame(width: 72, height: 72)
                    .background(Circle().fill(accent.color))
                    .glow(accent.color, radius: Theme.Glow.medium)
                    .accessibilityHidden(true)
                Text("\(planName) done")
                    .font(.grotesk(34))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
                Text(verbatim: draft.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale)))
                    .font(.text(15))
                    .foregroundStyle(Theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            VStack(spacing: 10) {
                HStack(spacing: 0) {
                    number(Text(verbatim: "\(max(1, draft.durationSeconds / 60))"), label: "Minutes")
                    number(Text(verbatim: "\(draft.results.count)"), label: "Exercises")
                    number(Text(verbatim: "\(records.count)"), label: records.count == 1 ? "Record" : "Records")
                }
                .background(Theme.surface)
                .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))

                if let record = records.first, let exercise = catalog.exercise(record.exercise) {
                    HStack(spacing: 4) {
                        Text("New record:")
                            .foregroundStyle(Theme.textSoft)
                        Text("\(ValueText.result(record.value, unit: record.unit)) \(Text(catalog: exercise.nameKey))")
                            .foregroundStyle(accent.color)
                    }
                    .font(.text(16))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface)
                    .overlay(Rectangle().strokeBorder(accent.color, lineWidth: 1))
                    .accessibilityElement(children: .combine)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("How was it?")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 0) {
                    ForEach(WorkoutRating.allCases, id: \.self) { rating in
                        SegmentButton(rating.title, isSelected: draft.rating == rating) {
                            draft.rating = draft.rating == rating ? nil : rating
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text("Rating"))

                if isWritingNote {
                    TextField("How did the workout go?", text: $draft.note, axis: .vertical)
                        .font(.text(15))
                        .foregroundStyle(Theme.text)
                        .lineLimit(3...8)
                        .padding(12)
                        .frame(minHeight: Theme.Layout.minTouchTarget)
                        .background(Theme.surface)
                        .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
                } else {
                    textButton("+ Add note") {
                        isWritingNote = true
                    }
                }

                // Records come from adjusted values, so they stay reachable, one tap away.
                if !draft.results.isEmpty {
                    textButton(isAdjustingValues ? "Hide values" : "Adjust values") {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isAdjustingValues.toggle()
                        }
                    }
                    if isAdjustingValues {
                        VStack(spacing: 8) {
                            ForEach($draft.results, id: \.exercise) { $result in
                                ResultRow(result: $result, catalog: catalog)
                            }
                        }
                    }
                }
            }

            PrimaryButton("Save") {
                save()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }

    private var planName: Text {
        if let plan { plan.title } else { Text("Workout") }
    }

    private func number(_ value: Text, label: LocalizedStringKey) -> some View {
        VStack(spacing: 2) {
            value
                .font(.grotesk(26))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
            Text(label)
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func textButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.text(15))
                .foregroundStyle(accent.color)
                .frame(minHeight: Theme.Layout.minTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
    }

    /// ✕: right after a workout it saves as well; otherwise it leaves without changes.
    private func close() {
        if mode == .afterWorkout {
            store.save(draft)
        }
        dismiss()
    }

    /// Saves; right after a workout it then shows the Journey.
    private func save() {
        store.save(draft)
        if mode == .afterWorkout {
            navigation?.journalPath = []
            navigation?.selectedTab = .journal
        }
        dismiss()
    }
}

/// One exercise with its sets and an adjustable best value.
private struct ResultRow: View {
    @Binding var result: ExerciseResult
    let catalog: Catalog

    private var step: Int { result.unit == .reps ? 1 : 5 }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                if let exercise = catalog.exercise(result.exercise) {
                    Text(catalog: exercise.nameKey)
                        .font(.textSemibold(15))
                        .foregroundStyle(Theme.text)
                }
                Text("\(result.sets) sets")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
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
        .padding(12)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    let store = UserDataStore.preview()
    return NavigationStack {
        if let entry = store.sortedEntries.first {
            WorkoutDoneScreen(entry: entry, mode: .existing)
        }
    }
    .environment(store)
    .environment(AppNavigation())
}

#Preview("German") {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            WorkoutDoneScreen(entry: JournalEntry(plan: plan, date: .now), mode: .afterWorkout)
        }
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
