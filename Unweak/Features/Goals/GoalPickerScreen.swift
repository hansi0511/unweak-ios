import SwiftUI

/// Choose the skills to learn, as many as the user likes. Each tap adds or removes a
/// skill at once. Without Pro the rows lead to the subscription page.
struct GoalPickerScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @State private var isShowingSubscription = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let stats = JournalStats(entries: store.entries)

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    MonoLabel("As many as you like")
                }
                Text("Choose skills")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Text("Every skill you learn shows in the Me tab with its stage and workouts.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                ForEach(catalog.goals) { goal in
                    let isLearning = store.isLearning(goal, in: catalog)
                    Button {
                        guard subscription.access.canUseSkills else {
                            isShowingSubscription = true
                            return
                        }
                        withAnimation(.easeOut(duration: 0.15)) {
                            store.setLearning(!isLearning, goal, in: catalog)
                        }
                    } label: {
                        GoalRow(
                            progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                            isSelected: subscription.access.canUseSkills && isLearning
                        )
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .sheet(isPresented: $isShowingSubscription) {
            PaywallSheet()
        }
    }
}

/// One goal: pose, name, current state and badge.
private struct GoalRow: View {
    @Environment(\.accent) private var accent
    @Environment(SubscriptionStore.self) private var subscription
    let progress: GoalProgress
    let isSelected: Bool

    private var goal: Goal { progress.goal }

    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(goal.pose, highlighted: subscription.access.canUseSkills)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(catalog: goal.nameKey)
                    .font(.textSemibold(17))
                    .foregroundStyle(Theme.text)
                progress.stateText
                    .font(.mono)
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            if !subscription.access.canUseSkills {
                Badge(kind: .subscription)
            } else if isSelected {
                Badge(kind: .selected)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Theme.surfaceSelected : Theme.surface)
        .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.line, lineWidth: isSelected ? 2 : 1))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack {
        GoalPickerScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        GoalPickerScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
