import SwiftUI

/// The share image in the HUD look: brand, Sticky Man, what happened, details.
/// Fixed size per format and fixed font sizes, so the rendered image always looks the same.
struct ShareCardView: View {
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    private let content: ShareContent
    private let format: ShareFormat
    /// Date shown in the footer.
    private let date: Date
    /// Animation progress (0...1) of Sticky Man; `nil` shows the key pose (still image).
    private let progress: Double?

    init(content: ShareContent, format: ShareFormat, date: Date = .now, progress: Double? = nil) {
        self.content = content
        self.format = format
        self.date = date
        self.progress = progress
    }

    private var isStory: Bool { format == .story }

    var body: some View {
        let size = format.size
        ZStack {
            Theme.background
            GridBackground()
            CornerMarks(length: 22, lineWidth: 2)
                .stroke(accent.color, lineWidth: 2)
                .padding(14)

            VStack(alignment: .leading, spacing: 0) {
                brand
                Spacer(minLength: 6)
                StickyFigureCanvas(figure: content.animation.figure(at: progress ?? content.animation.endPoseProgress))
                    .frame(maxWidth: .infinity)
                    .frame(height: isStory ? 230 : 130)
                Spacer(minLength: 6)
                details
                Spacer(minLength: isStory ? 18 : 10)
                footer
            }
            .padding(.horizontal, 30)
            .padding(.vertical, isStory ? 36 : 28)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    // MARK: Parts

    private var brand: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: "UNWEAK")
                .font(.fixed(.spaceGroteskBold, size: 26))
                .tracking(3)
                .foregroundStyle(accent.color)
                .glow(accent.color, radius: Theme.Glow.small)
            Text(verbatim: "PROGRESS FROM WEEK TO WEEK")
                .font(.fixed(.monoMedium, size: 9))
                .tracking(1.5)
                .foregroundStyle(Theme.textMuted)
        }
    }

    @ViewBuilder
    private var details: some View {
        switch content {
        case .workout(let workout):
            kindLabel("Workout done")
            headline(workoutTitle(workout.title), size: isStory ? 34 : 28)
            HStack(spacing: 10) {
                metric(ValueText.minutes(workout.durationSeconds), label: "Time")
                metric(Text(verbatim: "\(workout.exercises)"), label: "Exercises")
                metric(Text(verbatim: "\(workout.sets)"), label: "Sets")
            }
            .padding(.top, 14)
            if let record = workout.record {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                    Text("Record: \(Text(catalog: record.exerciseNameKey))")
                    Text(verbatim: "·")
                    ValueText.result(record.value, unit: record.unit)
                }
                .font(.fixed(.interSemiBold, size: 14))
                .foregroundStyle(accent.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 12)
            }

        case .record(let record):
            kindLabel("New record")
            ValueText.result(record.value, unit: record.unit)
                .font(.fixed(.spaceGroteskBold, size: isStory ? 64 : 52))
                .foregroundStyle(accent.color)
                .glow(accent.color, radius: Theme.Glow.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            headline(Text(catalog: record.exerciseNameKey), size: 26)

        case .achievement(let achievement):
            kindLabel("Achievement unlocked")
            ValueText.threshold(of: achievement)
                .font(.fixed(.spaceGroteskBold, size: isStory ? 72 : 56))
                .foregroundStyle(accent.color)
                .glow(accent.color, radius: Theme.Glow.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            headline(Text(catalog: achievement.labelKey), size: 26)

        case .streak(let streak):
            kindLabel("Streak")
            Text(verbatim: "\(streak.weeks)")
                .font(.fixed(.spaceGroteskBold, size: isStory ? 72 : 56))
                .foregroundStyle(accent.color)
                .glow(accent.color, radius: Theme.Glow.medium)
            headline(Text("Weeks in a row"), size: 26)
            weekBars(streak)
                .padding(.top, 14)

        case .skill(let skill):
            kindLabel("Skill progress")
            headline(Text(catalog: skill.nameKey), size: isStory ? 34 : 28)
            segments(filled: skill.filledSegments, total: GoalProgress.segmentCount)
                .padding(.top, 14)
            HStack(spacing: 6) {
                switch skill.state {
                case let .stages(reached, count, lastStageKey):
                    Text("Stage \(reached) / \(count)")
                    if let lastStageKey {
                        Text(verbatim: "·")
                        Text(catalog: lastStageKey)
                    }
                case let .time(bestSeconds, targetSeconds):
                    Text("Best time \(ValueText.seconds(bestSeconds)) of \(ValueText.seconds(targetSeconds))")
                }
            }
            .font(.fixed(.interSemiBold, size: 15))
            .foregroundStyle(Theme.textSoft)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.top, 10)

        case .league(let result):
            kindLabel("Weekly league")
            Text(verbatim: "#\(result.place)")
                .font(.fixed(.spaceGroteskBold, size: isStory ? 72 : 56))
                .foregroundStyle(accent.color)
                .glow(accent.color, radius: Theme.Glow.medium)
            headline(Text(result.outcome.headline), size: isStory ? 34 : 28)
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield")
                    .foregroundStyle(result.league.color)
                Text("Place \(result.place) of \(result.groupSize) · from Monday \(Text(result.league.name))")
            }
            .font(.fixed(.interSemiBold, size: 15))
            .foregroundStyle(Theme.textSoft)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .padding(.top, 10)
        }
    }

    private var footer: some View {
        HStack {
            Text(verbatim: date.formatted(.dateTime.day().month(.wide).year().locale(locale)).uppercased())
            Spacer()
            Text(verbatim: "#UNWEAK  #CALISTHENICS")
        }
        .font(.fixed(.monoMedium, size: 9))
        .tracking(1)
        .foregroundStyle(Theme.textMuted)
    }

    // MARK: Building blocks

    private func kindLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.fixed(.monoBold, size: 12))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(Theme.textMuted)
            .padding(.bottom, 6)
    }

    private func headline(_ text: Text, size: CGFloat) -> some View {
        text
            .font(.fixed(.spaceGroteskBold, size: size))
            .foregroundStyle(Theme.text)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
    }

    private func metric(_ value: Text, label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            value
                .font(.fixed(.spaceGroteskBold, size: 22))
                .foregroundStyle(Theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.fixed(.monoMedium, size: 10))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundStyle(Theme.textMuted)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }

    private func segments(filled: Int, total: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Rectangle()
                    .fill(index < filled ? accent.color : Theme.line)
                    .frame(height: 8)
            }
        }
    }

    private func weekBars(_ streak: ShareContent.Streak) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(Array(streak.days.enumerated()), id: \.offset) { index, trained in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(trained ? accent.color : Theme.line)
                            .frame(height: 8)
                        Text(verbatim: ReminderText.shortName(ReminderSchedule.displayOrder[index], locale: locale))
                            .font(.fixed(.monoMedium, size: 9))
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.textMuted)
                    }
                }
            }
            Text("\(streak.workoutsThisWeek) / \(streak.target) workouts")
                .font(.fixed(.interSemiBold, size: 14))
                .foregroundStyle(Theme.textSoft)
        }
    }

    private func workoutTitle(_ title: ShareContent.Title) -> Text {
        switch title {
        case .catalog(let key): Text(catalog: key)
        case .custom(let name): Text(verbatim: name)
        case .generic: Text("Workout")
        }
    }
}

#Preview("Workout, story") {
    let catalog = Catalog.main
    let plan = catalog.plans[0]
    let entry = JournalEntry(plan: plan, date: .now)
    let record = ExerciseResult(exercise: "pushUp", sets: 4, value: 12, unit: .reps)
    return ShareCardView(
        content: .workoutCard(entry: entry, plan: plan, records: [record], catalog: catalog),
        format: .story
    )
}

#Preview("Achievement, post, German") {
    ShareCardView(content: .achievement(Catalog.main.achievements[4]), format: .post)
        .environment(\.locale, Locale(identifier: "de"))
}

#Preview("Streak, story") {
    ShareCardView(
        content: .streak(ShareContent.Streak(weeks: 4, workoutsThisWeek: 2, target: 3, days: [true, false, true, false, false, false, false])),
        format: .story
    )
}
