import SwiftUI

/// Choose the one active goal. Subscription goals lead to the subscription page.
struct GoalPickerScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserDataStore.self) private var store
    @State private var selection: String?
    @State private var isShowingSubscription = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private var activeGoalID: String? {
        store.data.activeGoalID ?? catalog.goals.first(where: \.isFree)?.id
    }

    var body: some View {
        let stats = JournalStats(entries: store.entries)

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                    MonoLabel("One goal at a time")
                }
                Text("Choose goal")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(spacing: 10) {
                ForEach(catalog.goals) { goal in
                    Button {
                        if goal.isFree {
                            selection = goal.id
                        } else {
                            isShowingSubscription = true
                        }
                    } label: {
                        GoalRow(
                            progress: stats.goalProgress(goal, reachedStages: store.reachedStages(of: goal)),
                            isSelected: goal.id == (selection ?? activeGoalID)
                        )
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }

            PrimaryButton("Set as goal", systemImage: "scope") {
                if let selection {
                    store.setActiveGoal(selection)
                }
                dismiss()
            }
            .disabled(selection == nil || selection == activeGoalID)
        }
        .sheet(isPresented: $isShowingSubscription) {
            SubscriptionPlaceholderSheet()
        }
    }
}

/// One goal: pose, name, current state and badge.
private struct GoalRow: View {
    @Environment(\.accent) private var accent
    let progress: GoalProgress
    let isSelected: Bool

    private var goal: Goal { progress.goal }

    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(goal.pose, highlighted: goal.isFree)
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
            if !goal.isFree {
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
