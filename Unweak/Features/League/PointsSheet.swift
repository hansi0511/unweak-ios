import SwiftUI

/// "How you earn points" (`V2-Punkte`): the four ways to earn points, how groups and the
/// weekly evaluation work, and the four leagues.
struct PointsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent

    var body: some View {
        ScreenContainer {
            IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                dismiss()
            }

            Text("How you earn points")
                .font(.grotesk(32))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 10) {
                row(icon: "play.fill", title: "Workout finished", detail: "At most one per day, from 10 minutes", points: LeaguePoints.perWorkout)
                row(icon: "checkmark", title: "Weekly target reached", detail: "e.g. 3 workouts", points: LeaguePoints.weeklyTargetBonus)
                row(icon: "stairs", title: "Skill stage reached", detail: "A new stage of your skill", points: LeaguePoints.perSkillStage)
                row(icon: "flame", title: "Streak", detail: "Per week in a row", points: LeaguePoints.perStreakWeek)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Every Monday you start in a new group with people at your level.")
                Text("On Sunday at midnight (UTC) the week is scored: the top 5 move up, the last 5 move down. Workouts added by hand bring no points.")
            }
            .font(.text(15))
            .foregroundStyle(Theme.text)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))

            HStack(spacing: 12) {
                ForEach(League.allCases) { league in
                    HStack(spacing: 4) {
                        LeagueBadge(league: league, size: 24)
                        Text(league.shortName)
                            .font(.text(14))
                            .foregroundStyle(Theme.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        }
        .presentationBackground(Theme.background)
    }

    private func row(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey, points: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(accent.color)
                .frame(width: 44, height: 44)
                .background(Theme.surfaceSelected)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.textSemibold(16))
                    .foregroundStyle(Theme.text)
                Text(detail)
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            Text(verbatim: "+\(points)")
                .font(.grotesk(22))
                .foregroundStyle(accent.color)
        }
        .padding(14)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PointsSheet()
}

#Preview("German") {
    PointsSheet()
        .environment(\.locale, Locale(identifier: "de"))
}
