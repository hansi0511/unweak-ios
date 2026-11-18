import SwiftUI

/// "Challenge a friend" (`V2-Herausfordern`): what the duel is about, against whom
/// (people from earlier duels) or an invitation by link, then "Challenge".
struct ChallengeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(LeagueStore.self) private var league
    @State private var kind: DuelKind = .moreWorkouts
    @State private var friendID: String?

    var body: some View {
        let friends = league.friends
        let friend = friends.first { $0.id == (friendID ?? friends.first?.id) }
        let canStart = DuelRules.canStart(running: league.runningDuels(at: .now).count)

        ScreenContainer {
            IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                dismiss()
            }

            Text("Challenge a friend")
                .font(.grotesk(32))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("What is it about?")
                ForEach(DuelKind.allCases) { item in
                    let available = DuelRules.isAvailable(item, meIsPro: subscription.isPro, opponentIsPro: friend?.isPro ?? false)
                    choice(isSelected: kind == item, isEnabled: available) {
                        kind = item
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.textSemibold(16))
                                .foregroundStyle(kind == item ? accent.color : Theme.text)
                            Group {
                                if available { Text(item.subtitle) } else { Text("Only when you both have Pro") }
                            }
                            .font(.text(13))
                            .foregroundStyle(Theme.textMuted)
                        }
                        .padding(14)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Against whom?")
                ForEach(friends) { item in
                    choice(isSelected: friend?.id == item.id, isEnabled: true) {
                        friendID = item.id
                    } label: {
                        HStack(spacing: 12) {
                            LeagueAvatarView(avatar: item.avatar)
                            Text(verbatim: item.name)
                                .font(.textSemibold(16))
                                .foregroundStyle(Theme.text)
                            Spacer(minLength: 0)
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 14)
                        .frame(minHeight: 60)
                    }
                }
                if let link = LeagueLinks.invitation {
                    ShareLink(
                        item: link,
                        subject: Text(verbatim: "Unweak"),
                        message: Text("Train against me in a 7-day duel on Unweak.")
                    ) {
                        Text("Invite via link")
                            .font(.textSemibold(15))
                            .foregroundStyle(accent.color)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .overlay(Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4])))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }

            if !canStart {
                Text("You already have 3 running duels.")
                    .font(.text(13))
                    .foregroundStyle(Theme.danger)
            }

            PrimaryButton("Challenge") {
                guard let friend else { return }
                league.challenge(friend, kind: kind)
                dismiss()
            }
            .disabled(!canStart || friend == nil
                || !DuelRules.isAvailable(kind, meIsPro: subscription.isPro, opponentIsPro: friend?.isPro ?? false))
        }
        .presentationBackground(Theme.background)
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.grotesk(18))
            .foregroundStyle(Theme.text)
            .accessibilityAddTraits(.isHeader)
    }

    /// A selectable card: 2 pt accent border when selected.
    private func choice<Content: View>(
        isSelected: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Content
    ) -> some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isSelected ? Theme.surfaceSelected : Theme.surface)
                .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.line, lineWidth: 2))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Links for the league. The invitation link needs the app's domain for universal links,
/// which is not decided yet (docs/SOCIAL.md); accepting it comes with the server.
enum LeagueLinks {
    static let invitation = URL(string: "https://unweak.app/duel")
}

#Preview {
    ChallengeScreen()
        .previewEnvironment()
}
