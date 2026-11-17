import SwiftUI

/// Settings, opened from the Me tab: account and subscription, training reminder,
/// accent color, language, legal and account actions.
struct SettingsScreen: View {
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(ReminderSettings.self) private var reminders
    @Environment(SubscriptionStore.self) private var subscription
    @AppStorage(Accent.storageKey) private var accent: Accent = .default
    @AppStorage(AppLanguage.storageKey) private var storedLanguage = ""
    @State private var isShowingSubscription = false
    @State private var isPermissionDenied = false

    private var language: AppLanguage { AppLanguage.resolve(stored: storedLanguage) }

    var body: some View {
        ScreenContainer {
            HStack {
                BackButton()
                Spacer()
            }
            ScreenHeader(label: MonoLabel(verbatim: "Unweak"), title: "Settings")

            section("Account and subscription") {
                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        settingRow("Account") {
                            Text("Not signed in")
                        }
                        Rectangle().fill(Theme.line).frame(height: 1)
                        HStack(spacing: 12) {
                            settingRow("Subscription") {
                                if subscription.isPro { Text(verbatim: "Pro") } else { Text("Free") }
                            }
                            Button {
                                isShowingSubscription = true
                            } label: {
                                ChipLabel("View subscription", style: .dashed)
                            }
                            .buttonStyle(PressFeedbackStyle())
                        }
                    }
                }
            }

            section("Training reminder") {
                reminderCard
            }

            section("Appearance") {
                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Accent color")
                                .font(.textSemibold(15))
                                .foregroundStyle(Theme.text)
                            HStack(spacing: 10) {
                                ForEach(Accent.allCases) { item in
                                    AccentSwatch(accent: item, isSelected: item == accent) {
                                        accent = item
                                    }
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Language")
                                .font(.textSemibold(15))
                                .foregroundStyle(Theme.text)
                            HStack(spacing: 8) {
                                ForEach(AppLanguage.allCases) { item in
                                    SelectChip(LocalizedStringKey(item.code), isSelected: item == language) {
                                        storedLanguage = AppLanguage.storedValue(for: item)
                                    }
                                    .accessibilityLabel(Text(verbatim: item.locale.localizedString(forLanguageCode: item.rawValue) ?? item.code))
                                }
                            }
                        }
                    }
                }
            }

            section("Legal") {
                // One row if it fits, otherwise stacked (long German labels).
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { legalLinks }
                    VStack(alignment: .leading, spacing: 8) { legalLinks }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    accountButton("Sign out", color: Theme.text)
                    accountButton("Delete account", color: Theme.danger)
                }
                Text("Deleting your account is permanent. Both are available once you are signed in.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .sheet(isPresented: $isShowingSubscription) {
            PaywallSheet()
        }
        .onChange(of: storedLanguage) { _, _ in
            // Notification texts follow the app language.
            reschedule(reminders.schedule)
        }
    }

    // MARK: Reminder

    private var reminderCard: some View {
        let schedule = reminders.schedule
        return Card {
            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: Binding(
                    get: { schedule.isEnabled },
                    set: { setReminder(enabled: $0) }
                )) {
                    Text("Reminder")
                        .font(.textSemibold(15))
                        .foregroundStyle(Theme.text)
                }
                .tint(accentColor)
                .frame(minHeight: Theme.Layout.minTouchTarget)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 4) {
                        ForEach(ReminderSchedule.displayOrder, id: \.self) { weekday in
                            DayChip(
                                title: ReminderText.shortName(weekday, locale: locale),
                                accessibilityName: ReminderText.fullName(weekday, locale: locale),
                                isSelected: schedule.weekdays.contains(weekday)
                            ) {
                                reminders.schedule.toggle(weekday)
                            }
                        }
                    }

                    CounterControl(label: "Time", value: Text(verbatim: ReminderText.time(schedule, locale: locale))) {
                        reminders.schedule.shiftTime(by: -1)
                    } increase: {
                        reminders.schedule.shiftTime(by: 1)
                    }
                }
                .disabled(!schedule.isEnabled)
                .opacity(schedule.isEnabled ? 1 : 0.4)

                reminderSummary(schedule)
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)

                if isPermissionDenied {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications are turned off for Unweak in the iOS settings.")
                            .font(.text(13))
                            .foregroundStyle(Theme.danger)
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                        } label: {
                            ChipLabel("Open iOS settings")
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            }
        }
        .onChange(of: schedule) { _, newValue in
            reschedule(newValue)
        }
    }

    private var accentColor: Color { accent.color }

    private func reminderSummary(_ schedule: ReminderSchedule) -> Text {
        if !schedule.isEnabled { return Text("Reminders are off.") }
        if schedule.weekdays.isEmpty { return Text("Choose at least one day.") }
        let days = ReminderText.dayList(schedule, locale: locale)
        let time = ReminderText.time(schedule, locale: locale)
        return Text("You will get a notification on \(days) at \(time).")
    }

    private func setReminder(enabled: Bool) {
        guard enabled else {
            reminders.schedule.isEnabled = false
            return
        }
        Task {
            let allowed = await ReminderScheduler.requestPermission()
            isPermissionDenied = !allowed
            reminders.schedule.isEnabled = allowed
        }
    }

    private func reschedule(_ schedule: ReminderSchedule) {
        let language = language
        Task {
            await ReminderScheduler.apply(schedule, language: language)
        }
    }

    // MARK: Building blocks

    private func section<Content: View>(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            MonoLabel(title)
            content()
        }
    }

    private func settingRow<Value: View>(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MonoLabel(title)
            value()
                .font(.textSemibold(15))
                .foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var legalLinks: some View {
        legalLink("Privacy")
        legalLink("Terms")
        legalLink("Imprint")
    }

    /// Legal texts are still open (docs/SPEC.md); until then a placeholder page.
    private func legalLink(_ title: LocalizedStringKey) -> some View {
        NavigationLink {
            ComingLaterScreen(title: title)
        } label: {
            ChipLabel(title)
                .fixedSize()
        }
        .buttonStyle(PressFeedbackStyle())
    }

    /// Sign out and delete account work from step 6 on (sign-in); until then disabled.
    private func accountButton(_ title: LocalizedStringKey, color: Color) -> some View {
        Button {} label: {
            Text(title)
                .font(.monoBold)
                .tracking(1)
                .textCase(.uppercase)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                .overlay(Rectangle().strokeBorder(color, lineWidth: 1))
        }
        .buttonStyle(PressFeedbackStyle())
        .disabled(true)
        .opacity(0.4)
    }
}

/// Weekday button for the reminder: 44 pt high, fills its share of the row.
private struct DayChip: View {
    @Environment(\.accent) private var accent
    let title: String
    let accessibilityName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.monoBold)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Theme.onAccent : Theme.textSoft)
                .frame(maxWidth: .infinity, minHeight: Theme.Layout.selectHeight)
                .background(isSelected ? accent.color : Color.clear)
                .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.lineStrong, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(Text(verbatim: accessibilityName))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Square color field, 44 pt, outlined when selected.
struct AccentSwatch: View {
    private let accent: Accent
    private let isSelected: Bool
    private let action: () -> Void

    init(accent: Accent, isSelected: Bool, action: @escaping () -> Void) {
        self.accent = accent
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(accent.color)
                .padding(isSelected ? 4 : 0)
                .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                .overlay(Rectangle().strokeBorder(isSelected ? Theme.text : Color.clear, lineWidth: 2))
                .glow(isSelected ? accent.color : .clear, radius: Theme.Glow.small)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(Text(accent.name))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        SettingsScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
