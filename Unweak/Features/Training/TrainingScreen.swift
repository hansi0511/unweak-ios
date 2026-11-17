import SwiftUI

/// Running workout: one exercise per screen, sets to tick off, rest countdown,
/// next exercise. The tab bar is hidden while it is shown.
struct TrainingScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    @State private var session: TrainingSession?
    private let catalog: Catalog

    init(plan: WorkoutPlan, catalog: Catalog = .main) {
        self.catalog = catalog
        _session = State(initialValue: TrainingSession(plan: plan, catalog: catalog, startedAt: .now))
    }

    var body: some View {
        Group {
            if let session {
                TrainingContent(session: session, catalog: catalog) {
                    endWorkout(session)
                }
            } else {
                ComingLaterScreen(title: "Workouts")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { navigation?.isTabBarHidden = true }
        .onDisappear { navigation?.isTabBarHidden = false }
    }

    /// Ends the workout and shows the journal. Saving the entry follows in step 4.
    private func endWorkout(_ session: TrainingSession) {
        session.finish(at: .now)
        navigation?.isTabBarHidden = false
        dismiss()
        navigation?.selectedTab = .journal
    }
}

private struct TrainingContent: View {
    let session: TrainingSession
    let catalog: Catalog
    let onEnd: () -> Void

    private var step: TrainingSession.Step { session.current }

    var body: some View {
        ScreenContainer {
            header

            VStack(alignment: .leading, spacing: 8) {
                SegmentedProgress(
                    total: session.steps.count,
                    filled: session.stepIndex + 1,
                    label: "Exercises"
                )
                targetLabel
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(catalog: step.exercise.nameKey)
                        .font(.exerciseTitle)
                        .foregroundStyle(Theme.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .accessibilityAddTraits(.isHeader)
                    Spacer(minLength: 0)
                    NavigationLink {
                        ExerciseDetailScreen(exercise: step.exercise, catalog: catalog)
                    } label: {
                        ChipLabel("Technique")
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }

            HUDPanel(padding: 10) {
                StickyManView(step.exercise.animation)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
            .id(step.exercise.id)

            SetTiles(total: step.item.sets, completed: session.completedSets, target: step.item.target)

            restAndNextRow

            VStack(spacing: 12) {
                PrimaryButton(primaryTitle, systemImage: primaryIcon) {
                    if session.primaryAction == .finish {
                        onEnd()
                    } else {
                        withAnimation(.easeOut(duration: 0.2)) {
                            session.performPrimaryAction(at: .now)
                        }
                    }
                }
                SecondaryButton("End and save workout", action: onEnd)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            BackButton()
            Text(catalog: session.plan.nameKey)
                .font(.textSemibold(15))
                .foregroundStyle(Theme.textSoft)
                .lineLimit(1)
            Spacer(minLength: 0)
            TimelineView(.periodic(from: session.startedAt, by: 1)) { context in
                MonoLabel(verbatim: TimeText.clock(session.elapsedSeconds(at: context.date)), color: Theme.text, bold: true)
                    .monospacedDigit()
                    .accessibilityLabel(Text("Elapsed time"))
                    .accessibilityValue(Text(verbatim: TimeText.clock(session.elapsedSeconds(at: context.date))))
            }
        }
    }

    private var targetLabel: some View {
        let number = session.stepIndex + 1
        let count = session.steps.count
        let sets = step.item.sets
        switch step.item.target {
        case .reps(let reps):
            return MonoLabel("Exercise \(number) / \(count) · \(sets) × \(reps) reps")
        case .seconds(let seconds):
            return MonoLabel("Exercise \(number) / \(count) · \(sets) × \(seconds) s")
        }
    }

    private var restAndNextRow: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = session.restRemaining(at: context.date)
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if remaining > 0 {
                        MonoLabel("Rest", color: Theme.text)
                    } else {
                        MonoLabel("Rest time")
                    }
                    Text(verbatim: TimeText.clock(remaining > 0 ? remaining : step.item.rest))
                        .font(.metric)
                        .monospacedDigit()
                        .foregroundStyle(Theme.text)
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 4) {
                    MonoLabel("Next")
                    if let next = session.next {
                        Text(catalog: next.exercise.nameKey)
                            .font(.textSemibold(15))
                            .foregroundStyle(Theme.textSoft)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text("Last exercise")
                            .font(.textSemibold(15))
                            .foregroundStyle(Theme.textSoft)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var primaryTitle: LocalizedStringKey {
        switch session.primaryAction {
        case .completeSet(let number): "Set \(number) done"
        case .nextExercise: "Next exercise"
        case .finish: "Finish workout"
        }
    }

    private var primaryIcon: String {
        switch session.primaryAction {
        case .completeSet: "checkmark"
        case .nextExercise: "arrow.right"
        case .finish: "flag.checkered"
        }
    }
}

/// One tile per set: done (accent fill), current (bright outline), open (dark).
private struct SetTiles: View {
    @Environment(\.accent) private var accent
    let total: Int
    let completed: Int
    let target: ExerciseTarget

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                tile(index)
            }
        }
    }

    private func tile(_ index: Int) -> some View {
        let isDone = index < completed
        let isCurrent = index == completed
        return VStack(spacing: 2) {
            if isDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
            } else {
                targetText
                    .font(.metric)
                    .monospacedDigit()
            }
            Text("Set \(index + 1)")
                .font(.mono)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(isDone ? Theme.onAccent : (isCurrent ? Theme.text : Theme.textMuted))
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(isDone ? accent.color : (isCurrent ? Theme.surfaceSelected : Theme.surface))
        .overlay(
            Rectangle().strokeBorder(
                isDone ? accent.color : (isCurrent ? Theme.text : Theme.line),
                lineWidth: isCurrent ? 2 : 1
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Set \(index + 1)"))
        .accessibilityValue(Text(stateLabel(isDone: isDone, isCurrent: isCurrent)))
    }

    private func stateLabel(isDone: Bool, isCurrent: Bool) -> LocalizedStringKey {
        if isDone { return "Done" }
        if isCurrent { return "Current" }
        return "Open"
    }

    private var targetText: Text {
        switch target {
        case .reps(let reps): Text(verbatim: "\(reps)")
        case .seconds(let seconds): Text("\(seconds) s")
        }
    }
}

#Preview {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            TrainingScreen(plan: plan)
        }
    }
}

#Preview("German") {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            TrainingScreen(plan: plan)
        }
    }
    .environment(\.locale, Locale(identifier: "de"))
}
