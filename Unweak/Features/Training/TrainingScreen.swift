import SwiftUI

/// Running workout (Design V2, `V2-Training`): one exercise per screen with one large
/// number, set dots and one main button. After "Set done" the rest starts on its own and
/// the number counts down ("Skip rest"). After the last set of the last exercise,
/// "Finish workout" shows "Workout done" in place. The tab bar is hidden meanwhile.
struct TrainingScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    @State private var session: TrainingSession?
    /// Set once the workout is finished: the entry shown on "Workout done".
    @State private var doneEntry: JournalEntry?
    private let catalog: Catalog

    init(plan: WorkoutPlan, catalog: Catalog = .main) {
        self.catalog = catalog
        _session = State(initialValue: TrainingSession(plan: plan, catalog: catalog, startedAt: .now))
    }

    var body: some View {
        Group {
            if let doneEntry {
                WorkoutDoneScreen(entry: doneEntry, mode: .afterWorkout, catalog: catalog)
            } else if let session {
                TrainingContent(session: session, catalog: catalog) {
                    finish(session)
                } onQuit: {
                    quit(session)
                }
            } else {
                ComingLaterScreen(title: "Workouts")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { navigation?.isTabBarHidden = true }
        .onDisappear { navigation?.isTabBarHidden = false }
    }

    /// Ends the workout and shows "Workout done".
    private func finish(_ session: TrainingSession) {
        let now = Date.now
        session.finish(at: now)
        withAnimation(.easeOut(duration: 0.2)) {
            doneEntry = JournalEntry(session: session, endedAt: now)
        }
    }

    /// ✕ confirmed: with at least one set done the workout ends like "Finish workout";
    /// without any, it closes without saving.
    private func quit(_ session: TrainingSession) {
        let entry = JournalEntry(session: session, endedAt: .now)
        if entry.results.isEmpty {
            dismiss()
        } else {
            finish(session)
        }
    }
}

private struct TrainingContent: View {
    @Environment(\.accent) private var accent
    let session: TrainingSession
    let catalog: Catalog
    let onFinish: () -> Void
    let onQuit: () -> Void
    @State private var isConfirmingQuit = false

    private var step: TrainingSession.Step { session.current }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let action = session.primaryAction(at: now)

            ScreenContainer {
                header

                Text(catalog: step.exercise.nameKey)
                    .font(.grotesk(34))
                    .foregroundStyle(Theme.text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                StickyManView(step.exercise.animation)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                    .id(step.exercise.id)

                bigNumber(at: now)

                setDots

                mainButton(action)
            }
        }
        .confirmationDialog("End workout?", isPresented: $isConfirmingQuit, titleVisibility: .visible) {
            Button("End workout", role: .destructive, action: onQuit)
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Sets you have done are saved.")
        }
    }

    /// ✕, one segment per exercise, "?" for the technique.
    private var header: some View {
        HStack(spacing: 12) {
            IconButton(systemImage: "xmark", accessibilityLabel: "End workout") {
                isConfirmingQuit = true
            }
            SegmentedProgress(
                total: session.steps.count,
                filled: session.stepIndex + 1,
                height: 5,
                label: "Exercises"
            )
            NavigationLink {
                ExerciseDetailScreen(exercise: step.exercise, catalog: catalog)
            } label: {
                Text(verbatim: "?")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                    .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .accessibilityLabel(Text("How the exercise works"))
        }
    }

    /// Repetitions or seconds of the set; during the rest the remaining rest time.
    private func bigNumber(at now: Date) -> some View {
        let resting = session.isResting(at: now)
        return VStack(spacing: 4) {
            Group {
                if resting {
                    Text(verbatim: TimeText.clock(session.restRemaining(at: now)))
                } else {
                    switch step.item.target {
                    case .reps(let reps): Text(verbatim: "\(reps)")
                    case .seconds(let seconds): Text(verbatim: "\(seconds)")
                    }
                }
            }
            .font(.grotesk(72))
            .monospacedDigit()
            .foregroundStyle(resting ? accent.color : Theme.text)
            Group {
                if resting {
                    Text("Rest")
                } else {
                    switch step.item.target {
                    case .reps: Text("Repetitions")
                    case .seconds: Text("Seconds")
                    }
                }
            }
            .font(.text(17))
            .foregroundStyle(Theme.textSoft)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// One dot per set (done filled, current outlined) and "Set 3 of 4".
    private var setDots: some View {
        let total = step.item.sets
        let done = session.completedSets
        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < done ? accent.color : Color.clear)
                        .overlay(Circle().strokeBorder(index < done ? accent.color : (index == done ? Theme.text : Theme.lineStrong), lineWidth: 2))
                        .frame(width: 14, height: 14)
                }
            }
            .accessibilityHidden(true)
            Group {
                if session.isExerciseComplete {
                    Text("All sets done")
                } else {
                    Text("Set \(session.currentSetNumber) of \(total)")
                }
            }
            .font(.text(15))
            .foregroundStyle(Theme.textSoft)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func mainButton(_ action: TrainingSession.PrimaryAction) -> some View {
        Button {
            if action == .finish {
                onFinish()
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    session.performPrimaryAction(at: .now)
                }
            }
        } label: {
            Text(title(for: action))
                .font(.grotesk(20))
                .foregroundStyle(action == .skipRest ? accent.color : Theme.onAccent)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(action == .skipRest ? Color.clear : accent.color)
                .overlay(Rectangle().strokeBorder(accent.color, lineWidth: action == .skipRest ? 1.5 : 0))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .glow(action == .skipRest ? .clear : accent.color, radius: Theme.Glow.medium)
    }

    private func title(for action: TrainingSession.PrimaryAction) -> LocalizedStringKey {
        switch action {
        case .completeSet: "Set done"
        case .skipRest: "Skip rest"
        case .nextExercise: "Next exercise"
        case .finish: "Finish workout"
        }
    }
}

#Preview {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            TrainingScreen(plan: plan)
        }
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        if let plan = Catalog.main.plans.first {
            TrainingScreen(plan: plan)
        }
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
