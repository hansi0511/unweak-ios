import SwiftUI

/// What the info sheet of a skill page explains: the skill itself or one of its stages.
enum SkillInfo: Identifiable, Hashable {
    case skill
    /// Stage index, 0-based.
    case stage(Int)

    var id: Self { self }
}

/// Info sheet for a skill or one of its stages: animation, muscles used and how it is
/// done. For a stage it also holds the "Mastered" switch, the only place to take a stage
/// back (Design V2).
struct SkillInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    let goal: Goal
    let info: SkillInfo
    let catalog: Catalog

    private var stageIndex: Int? {
        guard case .stage(let index) = info, goal.stageKeys.indices.contains(index) else { return nil }
        return index
    }

    private var animation: StickyAnimation {
        if let stageIndex, let animations = goal.stageAnimations, animations.indices.contains(stageIndex) {
            return animations[stageIndex]
        }
        return catalog.animation(for: goal)
    }

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                if let stageIndex {
                    Text("Stage \(stageIndex + 1) of \(goal.stageKeys.count)")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                    Text(catalog: goal.stageKeys[stageIndex])
                        .font(.screenTitle)
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                } else {
                    Text("Skill")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                    Text(catalog: goal.nameKey)
                        .font(.screenTitle)
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                }
            }

            HUDPanel(padding: 10) {
                StickyManView(animation)
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
            }

            if let stageIndex, subscription.access.canUseSkills {
                masteredRow(stageIndex)
            }

            section("Muscles", key: stageIndex.map { goal.stageMusclesKeys[$0] } ?? goal.musclesKey)
            section("How it’s done", key: stageIndex.map { goal.stageBenefitKeys[$0] } ?? goal.benefitKey)
        }
        .presentationDetents([.large])
        .presentationBackground(Theme.background)
    }

    private func section(_ title: LocalizedStringKey, key: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.buttonTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            Text(catalog: key)
                .font(.text(15))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// "Mastered" switch. On reaches this stage and all before it; off takes it back
    /// together with all later stages.
    private func masteredRow(_ index: Int) -> some View {
        let reached = store.reachedStages(of: goal)
        let isMastered = index < reached
        return VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: Binding(
                get: { isMastered },
                set: { store.setReachedStages($0 ? index + 1 : index, of: goal) }
            )) {
                Text("Mastered")
                    .font(.textSemibold(16))
                    .foregroundStyle(Theme.text)
            }
            .tint(accent.color)
            .frame(minHeight: Theme.Layout.minTouchTarget)
            if isMastered && index + 1 < reached {
                Text("Switching off also takes back the later stages.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }
}

#Preview("Stage") {
    if let goal = Catalog.main.goals.first {
        SkillInfoSheet(goal: goal, info: .stage(1), catalog: .main)
            .environment(SubscriptionStore.preview(isPro: true))
            .previewEnvironment()
    }
}

#Preview("Skill, German") {
    if let goal = Catalog.main.goals.first {
        SkillInfoSheet(goal: goal, info: .skill, catalog: .main)
            .previewEnvironment()
            .environment(\.locale, Locale(identifier: "de"))
    }
}
