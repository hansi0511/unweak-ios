import SwiftUI

/// What the info sheet of a skill page explains: the skill itself or one of its stages.
enum SkillInfo: Identifiable, Hashable {
    case skill
    /// Stage index, 0-based.
    case stage(Int)

    var id: Self { self }
}

/// Info sheet for a skill or one of its stages: animation, muscles used and what it brings.
struct SkillInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
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
                    MonoLabel("Stage \(stageIndex + 1) / \(goal.stageKeys.count)")
                    Text(catalog: goal.stageKeys[stageIndex])
                        .font(.screenTitle)
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                } else {
                    MonoLabel("Skill")
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

            section("Muscles", key: stageIndex.map { goal.stageMusclesKeys[$0] } ?? goal.musclesKey)
            section("How it’s done", key: stageIndex.map { goal.stageBenefitKeys[$0] } ?? goal.benefitKey)
        }
        .presentationDetents([.large])
        .presentationBackground(Theme.background)
    }

    private func section(_ title: LocalizedStringKey, key: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(title)
            Text(catalog: key)
                .font(.text(15))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Stage") {
    if let goal = Catalog.main.goals.first {
        SkillInfoSheet(goal: goal, info: .stage(1), catalog: .main)
    }
}

#Preview("Skill, German") {
    if let goal = Catalog.main.goals.first {
        SkillInfoSheet(goal: goal, info: .skill, catalog: .main)
            .environment(\.locale, Locale(identifier: "de"))
    }
}
