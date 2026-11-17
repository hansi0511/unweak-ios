import SwiftUI

/// "4 / 12" and all achievement tiles: achieved ones first, then the open ones.
/// Achieved tiles can be tapped to share them.
struct AchievementsGrid: View {
    @Environment(\.accent) private var accent
    let progress: [AchievementProgress]
    /// Called when an achieved tile is tapped.
    let onShare: (Achievement) -> Void

    private var achievedCount: Int { progress.filter(\.isAchieved).count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MonoLabel("Achievements")
                Spacer()
                MonoLabel(verbatim: "\(achievedCount) / \(progress.count)", color: Theme.text, bold: true)
                    .accessibilityLabel(Text("\(achievedCount) of \(progress.count)"))
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(progress.achievedFirst, id: \.achievement.id) { item in
                    if item.isAchieved {
                        Button {
                            onShare(item.achievement)
                        } label: {
                            tile(item)
                        }
                        .buttonStyle(PressFeedbackStyle())
                        .accessibilityHint(Text("Share achievement"))
                    } else {
                        tile(item)
                    }
                }
            }
        }
    }

    private func tile(_ item: AchievementProgress) -> some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 4) {
                ValueText.threshold(of: item.achievement)
                    .font(.metric)
                    .foregroundStyle(item.isAchieved ? accent.color : Theme.textMuted)
                Text(catalog: item.achievement.labelKey)
                    .font(.mono)
                    .textCase(.uppercase)
                    .foregroundStyle(item.isAchieved ? Theme.text : Theme.textMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .opacity(item.isAchieved ? 1 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityValue(item.isAchieved ? Text("Achieved") : Text("Open"))
    }
}
