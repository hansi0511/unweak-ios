import SwiftUI

/// End of the week (`V2-Wochenende`), shown once from Monday on: the place, "Promoted!",
/// "League kept" or "Relegated", the podium of the first three, the league from Monday,
/// "Continue" and "Share".
struct WeekResultScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @State private var shareContent: ShareContent?
    let result: WeekResult

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
                Text("Week \(result.week.number)")
                    .font(.text(14))
                    .foregroundStyle(Theme.textMuted)
            }

            VStack(spacing: 8) {
                Text("Place \(result.place) of \(result.groupSize)")
                    .font(.text(15))
                    .foregroundStyle(accent.color)
                Text(result.outcome.headline)
                    .font(.grotesk(40))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity)

            podium
                .padding(.horizontal, 8)

            HStack(spacing: 14) {
                LeagueBadge(league: result.newLeague, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("From Monday")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                    Text(result.newLeague.name)
                        .font(.grotesk(22))
                        .foregroundStyle(result.newLeague.color)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(result.newLeague.color, lineWidth: 1))
            .glow(result.newLeague.color, radius: Theme.Glow.medium)
            .accessibilityElement(children: .combine)

            VStack(spacing: 8) {
                PrimaryButton("Continue") {
                    dismiss()
                }
                Button {
                    shareContent = .league(ShareContent.LeagueResult(
                        place: result.place,
                        groupSize: result.groupSize,
                        outcome: result.outcome,
                        league: result.newLeague
                    ))
                } label: {
                    Text("Share")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
            }
        }
        .sheet(item: $shareContent) { content in
            ShareSheet(content: content)
        }
    }

    /// Second, first and third place side by side; the first is the highest block.
    private var podium: some View {
        let members = result.podium
        let order = [PodiumSlot(index: 1, height: 96, avatar: 64), PodiumSlot(index: 0, height: 132, avatar: 76), PodiumSlot(index: 2, height: 72, avatar: 64)]
        return HStack(alignment: .bottom, spacing: 10) {
            ForEach(order) { slot in
                if slot.index < members.count {
                    let member = members[slot.index]
                    VStack(spacing: 6) {
                        LeagueAvatarView(avatar: member.avatar, size: slot.avatar)
                        Group {
                            if member.isMe { Text("You") } else { Text(verbatim: member.name) }
                        }
                        .font(member.isMe ? .textSemibold(14) : .text(14))
                        .foregroundStyle(member.isMe ? accent.color : Theme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        Text(verbatim: "\(slot.index + 1)")
                            .font(.grotesk(28))
                            .foregroundStyle(member.isMe ? accent.color : Theme.text)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, minHeight: slot.height, maxHeight: slot.height, alignment: .top)
                            .background(member.isMe ? Theme.surfaceSelected : Theme.surface)
                            .overlay(Rectangle().strokeBorder(member.isMe ? accent.color : Theme.line, lineWidth: 1))
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("Place \(slot.index + 1), \(member.isMe ? Text("You") : Text(verbatim: member.name))"))
                }
            }
        }
    }
}

/// One place on the podium: which member, how high the block, how large the avatar.
private struct PodiumSlot: Identifiable {
    let index: Int
    let height: CGFloat
    let avatar: CGFloat

    var id: Int { index }
}

#Preview {
    let members = SampleLeague.rivals(in: LeagueWeek(containing: .now), share: 1)
    return WeekResultScreen(result: WeekResult(
        week: LeagueWeek(containing: .now),
        place: 3,
        groupSize: 20,
        outcome: .promoted,
        newLeague: .gold,
        podium: Array(members.prefix(3))
    ))
}
