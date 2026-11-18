import SwiftUI

/// The weekly league (`V2-Liga`, docs/SOCIAL.md): badge, league name, days left and how
/// many move up; tiles for the first-place prize and the running duels; the ranking with
/// the promotion and relegation lines. A long press on someone else offers "Report" and
/// "Block". The info button explains the points. Without a display name the user picks
/// one first.
struct LeagueScreen: View {
    @Environment(\.accent) private var accent
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @Environment(LeagueStore.self) private var league
    @State private var isShowingPoints = false
    @State private var isChoosingName = false
    @State private var isChallenging = false
    @State private var reporting: LeagueMember?
    @State private var blocking: LeagueMember?
    @State private var reportedName: String?
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let now = Date.now
        let week = LeagueWeek(containing: now)
        let standing = league.standing(store: store, weeklyTarget: reminders.weeklyTarget, catalog: catalog, now: now)
        let duels = league.runningDuels(at: now)

        ScreenContainer {
            HStack {
                BackButton()
                Spacer()
                IconButton(systemImage: "info.circle", accessibilityLabel: "How you earn points") {
                    isShowingPoints = true
                }
            }

            HStack(spacing: 14) {
                LeagueBadge(league: league.league, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(league.league.name)
                        .font(.grotesk(32))
                        .foregroundStyle(Theme.text)
                        .accessibilityAddTraits(.isHeader)
                    HStack(spacing: 0) {
                        DaysLeftText(days: week.daysLeft(at: now))
                        if let standing {
                            Text(verbatim: " · ")
                            Text("Top \(standing.movingPlaces) move up")
                        }
                    }
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                }
            }

            HStack(spacing: 10) {
                prizeTile
                duelTile(duels)
            }

            if let standing {
                ranking(standing)
            } else {
                Text("You join the league as soon as you finish a workout of at least 10 minutes this week.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if league.usesSampleData {
                SampleDataNote()
            }
        }
        .onAppear {
            if league.displayName == nil { isChoosingName = true }
        }
        .sheet(isPresented: $isShowingPoints) {
            PointsSheet()
        }
        .sheet(isPresented: $isChoosingName) {
            DisplayNameSheet()
        }
        .sheet(isPresented: $isChallenging) {
            ChallengeScreen()
        }
        .confirmationDialog(
            "Report name?",
            isPresented: Binding(get: { reporting != nil }, set: { if !$0 { reporting = nil } }),
            titleVisibility: .visible,
            presenting: reporting
        ) { member in
            ForEach(ReportReason.allCases) { reason in
                Button {
                    league.report(member.id, reason: reason)
                    reportedName = member.name
                } label: {
                    Text(reason.title)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("We check reported names.")
        }
        .confirmationDialog(
            "Block this person?",
            isPresented: Binding(get: { blocking != nil }, set: { if !$0 { blocking = nil } }),
            titleVisibility: .visible,
            presenting: blocking
        ) { member in
            Button("Block", role: .destructive) {
                league.block(member)
            }
            Button("Cancel", role: .cancel) {}
        } message: { member in
            Text("\(member.name) no longer appears in your rankings and cannot challenge you.")
        }
        .alert(
            "Thanks for reporting",
            isPresented: Binding(get: { reportedName != nil }, set: { if !$0 { reportedName = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("After three reports a name is hidden until it is checked.")
        }
    }

    // MARK: Tiles

    private var prizeTile: some View {
        let prize = league.league.prize
        return HStack(spacing: 10) {
            AvatarView(style: AvatarStyle(color: .mono), body: .trained, extra: prize, breathes: false, framed: false)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("First place wins")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
                Text(prize.name)
                    .font(.textSemibold(14))
                    .foregroundStyle(Theme.text)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func duelTile(_ duels: [Duel]) -> some View {
        let label = HStack(spacing: 10) {
            Image(systemName: "figure.fencing")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(accent.color)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    if duels.isEmpty {
                        Text("Challenge a friend")
                    } else {
                        Text("\(duels.count) running")
                    }
                }
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
                Text("Duel")
                    .font(.textSemibold(14))
                    .foregroundStyle(accent.color)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .overlay(Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4])))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)

        if let first = duels.first {
            NavigationLink {
                DuelScreen(duelID: first.id, catalog: catalog)
            } label: {
                label
            }
            .buttonStyle(PressFeedbackStyle())
        } else {
            Button {
                isChallenging = true
            } label: {
                label
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }

    // MARK: Ranking

    private func ranking(_ standing: LeagueStanding) -> some View {
        let moving = standing.movingPlaces
        let size = standing.groupSize
        return LazyVStack(spacing: 6) {
            ForEach(Array(standing.members.enumerated()), id: \.element.id) { index, member in
                let place = index + 1
                if place == moving + 1 {
                    ZoneSeparator(title: "Promotion up to here", color: accent.color)
                }
                if place == size - moving + 1, size - moving + 1 > moving + 1 {
                    ZoneSeparator(title: "Relegation from here", color: Theme.relegation)
                }
                if member.isMe {
                    row(member, place: place, standing: standing)
                } else {
                    row(member, place: place, standing: standing)
                        .contextMenu {
                            Button {
                                reporting = member
                            } label: {
                                Label("Report", systemImage: "flag")
                            }
                            Button(role: .destructive) {
                                blocking = member
                            } label: {
                                Label("Block", systemImage: "hand.raised")
                            }
                        }
                        .accessibilityHint(Text("Touch and hold to report or block"))
                }
            }
        }
    }

    private func row(_ member: LeagueMember, place: Int, standing: LeagueStanding) -> some View {
        let zone = LeagueRules.zone(place: place, groupSize: standing.groupSize)
        let placeColor: Color = switch zone {
        case .promotion: accent.color
        case .middle: Theme.textMuted
        case .relegation: Theme.relegation
        }
        return HStack(spacing: 12) {
            Text(verbatim: "\(place)")
                .font(.grotesk(17))
                .foregroundStyle(placeColor)
                .frame(width: 26)
            LeagueAvatarView(avatar: member.avatar)
            Group {
                if member.isMe {
                    Text("You")
                } else {
                    Text(verbatim: member.name)
                }
            }
            .font(member.isMe ? .textSemibold(16) : .text(16))
            .foregroundStyle(Theme.text)
            .lineLimit(1)
            .truncationMode(.tail)
            Spacer(minLength: 0)
            Text(verbatim: "\(member.points)")
                .font(.grotesk(17))
                .foregroundStyle(Theme.text)
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .frame(height: 56)
        .background(member.isMe ? Theme.surfaceSelected : Theme.surface)
        .overlay(Rectangle().strokeBorder(member.isMe ? accent.color : Theme.line, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowLabel(member, place: place))
    }

    private func rowLabel(_ member: LeagueMember, place: Int) -> Text {
        let name = member.isMe ? Text("You") : Text(verbatim: member.name)
        return Text("Place \(place), \(name), \(member.points) points")
    }
}

#Preview {
    NavigationStack {
        LeagueScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        LeagueScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
