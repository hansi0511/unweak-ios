import SwiftUI

/// Technique of an exercise (Design V2, `V2-Uebung`): animation, three short numbered
/// steps, one hint with a warning sign (the most common mistake) and the easier and
/// harder variant as tiles.
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
                BackButton()
                Text(catalog: exercise.nameKey)
                    .font(.grotesk(36))
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
            }

            StickyManView(exercise.animation)
                .frame(maxWidth: .infinity)
                .frame(height: 200)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(exercise.stepKeys.enumerated()), id: \.offset) { index, key in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Text(verbatim: "\(index + 1)")
                            .font(.grotesk(20))
                            .foregroundStyle(accent.color)
                            .frame(width: 16, alignment: .leading)
                            .accessibilityHidden(true)
                        Text(catalog: key)
                            .font(.text(16))
                            .foregroundStyle(Theme.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }

            if let mistake = exercise.mistakeKeys.first {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.subscription)
                        .accessibilityHidden(true)
                    Text(catalog: mistake)
                        .font(.text(15))
                        .foregroundStyle(Theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("Watch out: \(Text(catalog: mistake))"))
            }

            let easier = exercise.easier.flatMap(catalog.exercise)
            let harder = exercise.harder.flatMap(catalog.exercise)
            if easier != nil || harder != nil {
                HStack(alignment: .top, spacing: 10) {
                    if let easier {
                        VariantTile(label: "Too hard?", exercise: easier, catalog: catalog)
                    }
                    if let harder {
                        VariantTile(label: "Too easy?", exercise: harder, catalog: catalog)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Tile with the easier or harder variant; opens its technique.
private struct VariantTile: View {
    let label: LocalizedStringKey
    let exercise: Exercise
    let catalog: Catalog

    var body: some View {
        NavigationLink {
            ExerciseDetailScreen(exercise: exercise, catalog: catalog)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
                Text(catalog: exercise.nameKey)
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
            .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NavigationStack {
        if let exercise = Catalog.main.exercise("pullUp") {
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
