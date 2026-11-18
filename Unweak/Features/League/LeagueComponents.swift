import SwiftUI

/// The league badge: a shield with a check in the league's color.
struct LeagueBadge: View {
    let league: League
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: "checkmark.shield")
            .font(.system(size: size * 0.8, weight: .medium))
            .foregroundStyle(league.color)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// "2 days left", "Last day".
struct DaysLeftText: View {
    let days: Int

    var body: some View {
        if days <= 1 {
            Text("Last day")
        } else {
            Text("\(days) days left")
        }
    }
}

/// Someone's avatar in the league: figure only, without breathing.
struct LeagueAvatarView: View {
    let avatar: LeagueAvatar
    var size: CGFloat = 40
    var isMirrored = false

    var body: some View {
        AvatarView(style: avatar.style, body: avatar.body, extra: avatar.extra, breathes: false, framed: false)
            .frame(width: size, height: size)
            .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
            .accessibilityHidden(true)
    }
}

/// "Sample data" note while the league has no server.
struct SampleDataNote: View {
    var body: some View {
        Text("Sample data: other people appear once the league server is ready.")
            .font(.text(13))
            .foregroundStyle(Theme.textMuted)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// Line with a centered label: "Promotion up to here", "Relegation from here".
struct ZoneSeparator: View {
    let title: LocalizedStringKey
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(color).frame(height: 1)
            Text(title)
                .font(.textSemibold(13))
                .foregroundStyle(color)
                .fixedSize()
            Rectangle().fill(color).frame(height: 1)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

extension LeagueStore {
    /// The running week's standing for the user, `nil` if they do not take part this week.
    func standing(store: UserDataStore, weeklyTarget: Int, catalog: Catalog, now: Date = .now) -> LeagueStanding? {
        standing(
            entries: store.entries,
            stageDates: store.data.stageReachedDates,
            weeklyTarget: weeklyTarget,
            avatar: LeagueAvatar.mine(store: store, catalog: catalog, weeklyTarget: weeklyTarget),
            now: now
        )
    }
}

/// Row in the Me tab under "Due today": badge, "Silver League", days left, the place and
/// the zone. Opens the league.
struct LeagueRow: View {
    @Environment(\.accent) private var accent
    let league: League
    let standing: LeagueStanding?
    let daysLeft: Int

    var body: some View {
        HStack(spacing: 14) {
            LeagueBadge(league: league)
            VStack(alignment: .leading, spacing: 4) {
                Text(league.name)
                    .font(.textSemibold(16))
                    .foregroundStyle(Theme.text)
                Group {
                    if standing == nil {
                        Text("Finish a workout to join this week")
                    } else {
                        DaysLeftText(days: daysLeft)
                    }
                }
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            if let standing, let place = standing.myPlace, let zone = standing.myZone {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Place \(place)")
                        .font(.grotesk(17))
                        .foregroundStyle(Theme.text)
                    Text(zone.title)
                        .font(.text(13))
                        .foregroundStyle(color(for: zone))
                }
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private func color(for zone: LeagueZone) -> Color {
        switch zone {
        case .promotion: accent.color
        case .middle: Theme.textMuted
        case .relegation: Theme.relegation
        }
    }
}

extension Theme {
    /// Relegation zone in the league (docs/SOCIAL.md: `#FF7566`).
    static let relegation = Color(hex: 0xFF7566)
}
