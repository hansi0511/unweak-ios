import SwiftUI

/// Exercise detail: animation, technique steps, common mistakes, easier and harder variant.
struct ExerciseDetailScreen: View {
    @Environment(\.accent) private var accent
    private let exercise: Exercise
    private let catalog: Catalog

    init(exercise: Exercise, catalog: Catalog = .main) {
        self.exercise = exercise
        self.catalog = catalog
    }

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                }
                MetaLine([Text(exercise.category.title), Text(exercise.level.title)])
                Text(catalog: exercise.nameKey)
                    .font(.exerciseTitle)
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
            }

            HUDPanel(padding: 10) {
                StickyManView(exercise.animation)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 12) {
                MonoLabel("How it works")
                ForEach(Array(exercise.stepKeys.enumerated()), id: \.offset) { index, key in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(verbatim: String(format: "%02d", index + 1))
                            .font(.monoBold)
                            .foregroundStyle(accent.color)
                            .accessibilityHidden(true)
                        Text(catalog: key)
                            .font(.text(15))
                            .foregroundStyle(Theme.textSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }

            if !exercise.mistakeKeys.isEmpty {
                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        MonoLabel("Common mistakes", color: Theme.danger, bold: true)
                        ForEach(exercise.mistakeKeys, id: \.self) { key in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.danger)
                                    .accessibilityHidden(true)
                                Text(catalog: key)
                                    .font(.text(15))
                                    .foregroundStyle(Theme.textSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .accessibilityElement(children: .combine)
            }

            HStack(alignment: .top, spacing: 10) {
                VariantTile(label: "Easier", exercise: exercise.easier.flatMap(catalog.exercise), catalog: catalog)
                VariantTile(label: "Harder", exercise: exercise.harder.flatMap(catalog.exercise), catalog: catalog)
            }
        }
    }
}

/// Tile linking to the easier or harder variant; shows a dash if there is none.
private struct VariantTile: View {
    let label: LocalizedStringKey
    let exercise: Exercise?
    let catalog: Catalog

    var body: some View {
        if let exercise {
            NavigationLink {
                ExerciseDetailScreen(exercise: exercise, catalog: catalog)
            } label: {
                content(name: Text(catalog: exercise.nameKey), pose: exercise.pose)
            }
            .buttonStyle(PressFeedbackStyle())
        } else {
            content(name: Text(verbatim: "–"), pose: nil)
                .accessibilityLabel(Text(label))
                .accessibilityValue(Text("None"))
        }
    }

    private func content(name: Text, pose: StickyPose?) -> some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(label)
                HStack(spacing: 8) {
                    if let pose {
                        StickyPoseView(pose)
                            .accessibilityHidden(true)
                    }
                    name
                        .font(.textSemibold(15))
                        .foregroundStyle(Theme.text)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(minHeight: Theme.Layout.minTouchTarget)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        if let exercise = Catalog.main.exercise("pushUp") {
            ExerciseDetailScreen(exercise: exercise)
        }
    }
}

#Preview("German") {
    NavigationStack {
        if let exercise = Catalog.main.exercise("pullUp") {
            ExerciseDetailScreen(exercise: exercise)
        }
    }
    .environment(\.locale, Locale(identifier: "de"))
}
