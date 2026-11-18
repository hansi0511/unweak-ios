import SwiftUI

/// Journey tab (Design V2, `V2-Journey`): this week as seven day circles, three totals
/// (workouts, hours, records), a row to the achievements and the recent workouts. The
/// plus adds a workout by hand.
struct JournalScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @State private var isPickingPlan = false
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let target = reminders.weeklyTarget
        let week = stats.week(containing: .now, target: target)
        let totals = stats.overall()
        let achievements = catalog.achievements.map { stats.progress(of: $0, target: target) }
        let entries = store.sortedEntries

        ScreenContainer {
            HStack {
                Text("Journey")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                IconButton(systemImage: "plus", accessibilityLabel: "Add workout") {
                    isPickingPlan = true
                }
            }

            WeekCard(week: week)

            HStack(spacing: 0) {
                total(Text(verbatim: "\(totals.workouts)"), label: "Workouts")
                total(hoursText(totals.seconds), label: "trained")
                total(Text(verbatim: "\(totals.records)"), label: "Records")
            }
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))

            NavigationLink(value: JournalRoute.achievements) {
                AchievementsRow(achieved: achievements.filter(\.isAchieved).count, total: achievements.count)
            }
            .buttonStyle(PressFeedbackStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Recent workouts")
                    .font(.buttonTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                if entries.isEmpty {
                    Text("Finish a workout or tap + to add one.")
                        .font(.text(15))
                        .foregroundStyle(Theme.textSoft)
                        .padding(.vertical, 10)
                } else {
                    ForEach(entries) { entry in
                        NavigationLink(value: JournalRoute.entry(entry.id)) {
                            JournalRow(entry: entry, hasRecord: !stats.records(in: entry).isEmpty, catalog: catalog)
                        }
                        .buttonStyle(PressFeedbackStyle())
                        Rectangle().fill(Theme.line).frame(height: 1)
                    }
                }
            }
        }
        .navigationDestination(for: JournalRoute.self) { route in
            switch route {
            case .entry(let id):
                if let entry = store.entry(id) {
                    WorkoutDoneScreen(entry: entry, mode: .existing, catalog: catalog)
                }
            case .newEntry(let planID):
                if let plan = store.plan(planID, in: catalog) {
                    WorkoutDoneScreen(entry: JournalEntry(plan: plan, date: .now), mode: .addedByHand, catalog: catalog)
                }
            case .achievements:
                AchievementsScreen(catalog: catalog)
            }
        }
        .sheet(isPresented: $isPickingPlan) {
            PlanPickerSheet(catalog: catalog)
        }
    }

    private func total(_ value: Text, label: LocalizedStringKey) -> some View {
        VStack(spacing: 2) {
            value
                .font(.grotesk(26))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.text(13))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// "9 h" from one hour on, before that "45 min".
    private func hoursText(_ seconds: Int) -> Text {
        let hours = Int((Double(seconds) / 3600).rounded())
        return hours >= 1 ? Text(verbatim: "\(hours) h") : Text(verbatim: "\(seconds / 60) min")
    }
}

/// "This week": seven day circles Monday to Sunday (trained filled, today outlined)
/// and "2 of 3".
private struct WeekCard: View {
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let week: WeekSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("This week")
                    .font(.textSemibold(17))
                    .foregroundStyle(Theme.text)
                Spacer()
                Text("\(week.workouts) of \(week.target)")
                    .font(.text(15))
                    .foregroundStyle(accent.color)
            }
            HStack(spacing: 6) {
                ForEach(week.days, id: \.date) { day in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(day.trained ? accent.color : Color.clear)
                            .overlay(Circle().strokeBorder(
                                day.trained ? accent.color : (day.isToday ? Theme.text : Theme.lineStrong),
                                lineWidth: day.isToday && !day.trained ? 2 : 1
                            ))
                            .frame(width: 32, height: 32)
                        Text(verbatim: day.date.formatted(.dateTime.weekday(.short).locale(locale)))
                            .font(.text(12))
                            .foregroundStyle(day.isToday ? Theme.text : Theme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(verbatim: day.date.formatted(.dateTime.weekday(.wide).locale(locale))))
                    .accessibilityValue(day.trained ? Text("Trained") : Text("Not trained"))
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .overlay {
            DiagonalCornerMarks()
                .stroke(accent.color, lineWidth: Theme.Layout.cornerMarkWidth)
                .accessibilityHidden(true)
        }
    }
}

/// "Achievements · 4 of 12" with a bar; opens the achievements.
private struct AchievementsRow: View {
    @Environment(\.accent) private var accent
    let achieved: Int
    let total: Int

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(accent.color)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Achievements")
                        .font(.textSemibold(16))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Text("\(achieved) of \(total)")
                        .font(.text(14))
                        .foregroundStyle(Theme.textMuted)
                }
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Theme.line)
                        Rectangle()
                            .fill(accent.color)
                            .frame(width: max(0, proxy.size.width * Double(achieved) / Double(max(total, 1))))
                    }
                }
                .frame(height: 5)
                .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// One workout in the list: pose, name, "Wed, 11 Nov · 36 min" and a "Record" badge.
private struct JournalRow: View {
    @Environment(UserDataStore.self) private var store
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    let entry: JournalEntry
    let hasRecord: Bool
    let catalog: Catalog

    private var plan: WorkoutPlan? { entry.planID.flatMap { store.plan($0, in: catalog) } }

    var body: some View {
        HStack(spacing: 14) {
            StickyPoseView(plan?.pose ?? .pushUp, highlighted: hasRecord)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                planName
                    .font(.textSemibold(16))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.leading)
                Text("\(Text(verbatim: entry.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale)))) · \(entry.durationSeconds / 60) min")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            if hasRecord {
                Text("Record")
                    .font(.text(13))
                    .foregroundStyle(accent.color)
            }
        }
        .padding(.vertical, 10)
        .frame(minHeight: Theme.Layout.minTouchTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var planName: Text {
        if let plan { plan.title } else { Text("Workout") }
    }
}

/// Choose the plan for a workout added by hand.
private struct PlanPickerSheet: View {
    @Environment(UserDataStore.self) private var store
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigation.self) private var navigation: AppNavigation?
    let catalog: Catalog

    /// Custom workouts first, then the catalog plans the user can train.
    private var pickablePlans: [WorkoutPlan] {
        let access = subscription.access
        let custom: [WorkoutPlan] = store.customWorkouts.map { $0.plan(in: catalog) }
        let available: [WorkoutPlan] = catalog.plans.filter { access.canTrain($0) }
        return custom + available
    }

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
            }
            Text("Add workout")
                .font(.grotesk(28))
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            Text("Choose the plan you trained.")
                .font(.text(15))
                .foregroundStyle(Theme.textSoft)
            VStack(spacing: 10) {
                ForEach(pickablePlans) { plan in
                    Button {
                        navigation?.journalPath.append(.newEntry(planID: plan.id))
                        dismiss()
                    } label: {
                        WorkoutCard(plan: plan, badge: plan.customName != nil ? .custom : nil)
                    }
                    .buttonStyle(PressFeedbackStyle())
                }
            }
        }
        .presentationBackground(Theme.background)
    }
}

#Preview {
    NavigationStack {
        JournalScreen()
    }
    .previewEnvironment()
}

#Preview("German, empty") {
    NavigationStack {
        JournalScreen()
    }
    .environment(UserDataStore(fileURL: nil))
    .environment(ReminderSettings(defaults: UserDefaults(suiteName: "unweak.preview") ?? .standard))
    .environment(AppNavigation())
    .environment(SubscriptionStore.preview(isPro: false))
    .environment(\.locale, Locale(identifier: "de"))
}
