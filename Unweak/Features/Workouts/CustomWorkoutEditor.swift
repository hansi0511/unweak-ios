import SwiftUI

/// Create or edit a custom workout (Design V2, `V2-Erstellen`): name, area, exercises
/// with their dose ("4 × 6"; tap a row to adjust sets and target) and "Save".
struct CustomWorkoutEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var draft: CustomWorkout
    @State private var isPickingExercise = false
    @State private var isShowingPaywall = false
    @State private var isConfirmingDelete = false
    /// Index of the exercise whose sets and target are shown for adjusting.
    @State private var expandedIndex: Int?
    private let isExisting: Bool
    private let catalog: Catalog

    /// - Parameter workout: The workout to edit, or `nil` for a new one.
    init(workout: CustomWorkout?, catalog: Catalog = .main) {
        _draft = State(initialValue: workout ?? CustomWorkout())
        isExisting = workout != nil
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                IconButton(systemImage: "xmark", accessibilityLabel: "Cancel") {
                    dismiss()
                }
                Group {
                    if isExisting { Text("Edit workout") } else { Text("New workout") }
                }
                .font(.grotesk(34))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                TextField("e.g. Morning push", text: $draft.name)
                    .font(.text(16))
                    .foregroundStyle(Theme.text)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 52)
                    .background(Theme.surface)
                    .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Area")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                HStack(spacing: 0) {
                    ForEach(ExerciseCategory.areas, id: \.self) { area in
                        SegmentButton(area.title, isSelected: draft.category == area) {
                            draft.category = area
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text("Area"))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Exercises")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                    Spacer()
                    if !draft.exercises.isEmpty {
                        Text("about \(draft.plan(in: catalog).estimatedMinutes) min")
                            .font(.text(14))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                ForEach(Array(draft.exercises.enumerated()), id: \.offset) { index, item in
                    ExerciseItemRow(
                        item: item,
                        catalog: catalog,
                        isExpanded: expandedIndex == index,
                        onToggle: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                expandedIndex = expandedIndex == index ? nil : index
                            }
                        },
                        onChange: { draft.exercises[index] = $0 },
                        onRemove: {
                            expandedIndex = nil
                            draft.exercises.remove(at: index)
                        }
                    )
                }
                Button {
                    isPickingExercise = true
                } label: {
                    Text("+ Add exercise")
                        .font(.text(15))
                        .foregroundStyle(accent.color)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .overlay(Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4])))
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
            }

            VStack(spacing: 12) {
                PrimaryButton("Save") {
                    let allowed = isExisting
                        || subscription.access.canCreateCustomWorkout(existing: store.customWorkouts.count)
                    guard allowed else {
                        isShowingPaywall = true
                        return
                    }
                    var saved = draft
                    saved.name = draft.trimmedName
                    store.save(saved)
                    dismiss()
                }
                .disabled(!draft.isComplete)

                if isExisting {
                    Button(role: .destructive) {
                        isConfirmingDelete = true
                    } label: {
                        Text("Delete workout")
                            .font(.text(15))
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingPaywall) {
            PaywallSheet()
        }
        .sheet(isPresented: $isPickingExercise) {
            ExercisePickerSheet(catalog: catalog) { exercise in
                draft.exercises.append(catalog.defaultItem(for: exercise.id))
            }
        }
        .confirmationDialog("Delete this workout?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete workout", role: .destructive) {
                store.delete(draft)
                dismiss()
            }
        } message: {
            Text("Workouts already saved in your Journey are kept.")
        }
    }
}

/// One exercise in the editor: name and dose ("4 × 6", "3 × 10 s") with a minus button
/// to remove it. Tapping the row shows sets and target to adjust.
private struct ExerciseItemRow: View {
    let item: PlanExercise
    let catalog: Catalog
    let isExpanded: Bool
    let onToggle: () -> Void
    let onChange: (PlanExercise) -> Void
    let onRemove: () -> Void

    private var targetLabel: LocalizedStringKey {
        item.seconds == nil ? "Reps" : "Seconds"
    }

    private var dose: String {
        item.seconds == nil ? "\(item.sets) × \(item.targetValue)" : "\(item.sets) × \(item.targetValue) s"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    HStack(spacing: 12) {
                        if let exercise = catalog.exercise(item.exercise) {
                            Text(catalog: exercise.nameKey)
                                .font(.text(16))
                                .foregroundStyle(Theme.text)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                        Text(verbatim: dose)
                            .font(.text(15))
                            .foregroundStyle(Theme.textSoft)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityHint(Text("Adjust sets and target"))
                Button(action: onRemove) {
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textSoft)
                        .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityLabel(Text("Remove exercise"))
            }
            .padding(.leading, 14)
            .padding(.trailing, 4)

            if isExpanded {
                HStack(spacing: 12) {
                    CounterControl(label: "Sets", value: Text(verbatim: "\(item.sets)")) {
                        onChange(item.withSets(item.sets - 1))
                    } increase: {
                        onChange(item.withSets(item.sets + 1))
                    }
                    Spacer(minLength: 0)
                    CounterControl(label: targetLabel, value: Text(verbatim: "\(item.targetValue)")) {
                        onChange(item.withTargetValue(item.targetValue - (item.seconds == nil ? 1 : 5)))
                    } increase: {
                        onChange(item.withTargetValue(item.targetValue + (item.seconds == nil ? 1 : 5)))
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 14, bottom: 12, trailing: 14))
            }
        }
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }
}

/// Label above "− value +" with 44 pt buttons.
struct CounterControl: View {
    private let label: LocalizedStringKey
    private let value: Text
    private let decrease: () -> Void
    private let increase: () -> Void

    init(label: LocalizedStringKey, value: Text, decrease: @escaping () -> Void, increase: @escaping () -> Void) {
        self.label = label
        self.value = value
        self.decrease = decrease
        self.increase = increase
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
            HStack(spacing: 6) {
                IconButton(systemImage: "minus", accessibilityLabel: "Less", action: decrease)
                value
                    .font(.metric)
                    .monospacedDigit()
                    .foregroundStyle(Theme.text)
                    .frame(minWidth: 40)
                IconButton(systemImage: "plus", accessibilityLabel: "More", action: increase)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}

/// Search the catalog and pick an exercise.
private struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var query = ""
    let catalog: Catalog
    let onPick: (Exercise) -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: locale.language.languageCode?.identifier ?? "") ?? .en
    }

    private var matches: [Exercise] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return catalog.exercises }
        return catalog.exercises.filter { exercise in
            let name = LocalizedLookup.string(exercise.nameKey, table: CatalogText.table, language: language)
            return name.localizedStandardContains(trimmed)
        }
    }

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
            }
            Text("Add exercise")
                .font(.grotesk(28))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textMuted)
                    .accessibilityHidden(true)
                TextField("Search exercises", text: $query)
                    .font(.text(17))
                    .foregroundStyle(Theme.text)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: Theme.Layout.selectHeight)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))

            if matches.isEmpty {
                Text("No exercise found.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
            }

            VStack(spacing: 8) {
                ForEach(matches) { exercise in
                    Button {
                        onPick(exercise)
                        dismiss()
                    } label: {
                        Card(padding: 10) {
                            HStack(spacing: 12) {
                                StickyPoseView(exercise.pose)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(catalog: exercise.nameKey)
                                        .font(.textSemibold(15))
                                        .foregroundStyle(Theme.text)
                                    MetaLine([Text(exercise.category.title), Text(exercise.level.title)])
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "plus")
                                    .foregroundStyle(Theme.textMuted)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .presentationBackground(Theme.background)
    }
}

#Preview("New") {
    NavigationStack {
        CustomWorkoutEditor(workout: nil)
    }
    .previewEnvironment()
}

#Preview("Edit, German") {
    NavigationStack {
        CustomWorkoutEditor(workout: CustomWorkout(
            name: "Morgen-Push",
            category: .push,
            exercises: [Catalog.main.defaultItem(for: "pushUp"), Catalog.main.defaultItem(for: "plank")]
        ))
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
