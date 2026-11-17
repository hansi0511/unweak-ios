import SwiftUI

/// Create or edit a custom workout: name, category, exercises with sets and targets.
struct CustomWorkoutEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var draft: CustomWorkout
    @State private var isPickingExercise = false
    @State private var isShowingPaywall = false
    @State private var isConfirmingDelete = false
    private let isExisting: Bool
    private let catalog: Catalog

    /// Skills have their own area in the workouts tab, so custom workouts use the others.
    private static let categories: [ExerciseCategory] = ExerciseCategory.allCases.filter { $0 != .skill }

    /// - Parameter workout: The workout to edit, or `nil` for a new one.
    init(workout: CustomWorkout?, catalog: Catalog = .main) {
        _draft = State(initialValue: workout ?? CustomWorkout())
        isExisting = workout != nil
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    MetaLine([
                        Text("\(draft.exercises.count) exercises"),
                        Text("about \(draft.plan(in: catalog).estimatedMinutes) min"),
                    ])
                    .fixedSize()
                }
                Group {
                    if isExisting { Text("Edit workout") } else { Text("Create workout") }
                }
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Name")
                TextField("e.g. Morning push", text: $draft.name)
                    .font(.text(17))
                    .foregroundStyle(Theme.text)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .padding(.horizontal, 12)
                    .frame(minHeight: Theme.Layout.selectHeight)
                    .background(Theme.surface)
                    .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Category")
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Self.categories, id: \.self) { category in
                            SelectChip(category.title, isSelected: draft.category == category) {
                                draft.category = category
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            VStack(alignment: .leading, spacing: 10) {
                MonoLabel("Exercises")
                ForEach(Array(draft.exercises.enumerated()), id: \.offset) { index, item in
                    ExerciseItemRow(
                        number: index + 1,
                        item: item,
                        catalog: catalog,
                        onChange: { draft.exercises[index] = $0 },
                        onRemove: { draft.exercises.remove(at: index) }
                    )
                }
                Button {
                    isPickingExercise = true
                } label: {
                    ChipLabel("Add exercise", systemImage: "plus", style: .dashed, expands: true)
                }
                .buttonStyle(PressFeedbackStyle())
            }

            VStack(spacing: 12) {
                PrimaryButton("Save workout", systemImage: "checkmark") {
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
                            .font(.monoBold)
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
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

/// One exercise in the editor: number, name, remove button, sets and target.
private struct ExerciseItemRow: View {
    @Environment(\.accent) private var accent
    let number: Int
    let item: PlanExercise
    let catalog: Catalog
    let onChange: (PlanExercise) -> Void
    let onRemove: () -> Void

    private var targetLabel: LocalizedStringKey {
        if item.seconds == nil { return "Reps" }
        return "Seconds"
    }

    var body: some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(verbatim: String(format: "%02d", number))
                        .font(.monoBold)
                        .foregroundStyle(accent.color)
                        .accessibilityHidden(true)
                    if let exercise = catalog.exercise(item.exercise) {
                        Text(catalog: exercise.nameKey)
                            .font(.textSemibold(15))
                            .foregroundStyle(Theme.text)
                    }
                    Spacer(minLength: 0)
                    IconButton(systemImage: "xmark", accessibilityLabel: "Remove exercise", action: onRemove)
                }
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
            }
        }
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
            MonoLabel(label)
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
                .font(.screenTitle)
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
