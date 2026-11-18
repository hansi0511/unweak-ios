import SwiftUI

/// Settings (Design V2, `V2-Einstellungen`), opened from the top right of the Me area:
/// grouped rows without explanations — account, subscription, reminder with days and
/// time, accent color, language, league, legal — and the account actions at the bottom.
struct SettingsScreen: View {
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(ReminderSettings.self) private var reminders
    @Environment(SubscriptionStore.self) private var subscription
    @Environment(LeagueStore.self) private var league
    @AppStorage(Accent.storageKey) private var accent: Accent = .default
    @AppStorage(AppLanguage.storageKey) private var storedLanguage = ""
    @State private var isShowingSubscription = false
    @State private var isPermissionDenied = false
    @State private var isEditingName = false

    private var language: AppLanguage { AppLanguage.resolve(stored: storedLanguage) }

    var body: some View {
        let schedule = reminders.schedule

        ScreenContainer {
            VStack(alignment: .leading, spacing: 14) {
                BackButton()
                Text("Settings")
                    .font(.grotesk(28))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(spacing: 10) {
                SettingsGroup {
                    SettingsRow("Account") {
                        // Sign-in comes with step 6; until then nobody is signed in.
                        Text("Not signed in")
                            .font(.text(15))
                            .foregroundStyle(Theme.textMuted)
                    }
                }

                Button {
                    isShowingSubscription = true
                } label: {
                    SettingsGroup {
                        SettingsRow("Subscription") {
                            HStack(spacing: 8) {
                                if subscription.isPro { Text(verbatim: "Pro") } else { Text("Free") }
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .accessibilityHidden(true)
                            }
                            .font(.text(15))
                            .foregroundStyle(Theme.textMuted)
                        }
                    }
                }
                .buttonStyle(PressFeedbackStyle())

                SettingsGroup {
                    SettingsRow("Reminder") {
                        Toggle(isOn: Binding(
                            get: { schedule.isEnabled },
                            set: { setReminder(enabled: $0) }
                        )) {
                            Text("Reminder")
                        }
                        .labelsHidden()
                        .tint(accent.color)
                        .frame(minWidth: 60, minHeight: Theme.Layout.minTouchTarget)
                    }
                    if schedule.isEnabled {
                        reminderDetails(schedule)
                    }
                    if isPermissionDenied {
                        permissionHint
                    }
                }

                SettingsGroup {
                    SettingsRow("Color") {
                        HStack(spacing: 0) {
                            ForEach(Accent.allCases) { item in
                                AccentSwatch(accent: item, isSelected: item == accent) {
                                    accent = item
                                }
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(Text("Accent color"))
                    }
                }

                SettingsGroup {
                    SettingsRow("Language") {
                        HStack(spacing: 0) {
                            ForEach(AppLanguage.allCases) { item in
                                SegmentButton(LocalizedStringKey(item.code), isSelected: item == language) {
                                    storedLanguage = AppLanguage.storedValue(for: item)
                                }
                                .accessibilityLabel(Text(verbatim: item.locale.localizedString(forLanguageCode: item.rawValue) ?? item.code))
                            }
                        }
                        .frame(width: 120)
                    }
                }

                leagueGroup

                NavigationLink {
                    LegalScreen()
                } label: {
                    SettingsGroup {
                        SettingsRow("Legal") {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.textMuted)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .buttonStyle(PressFeedbackStyle())
            }

            HStack(spacing: 24) {
                accountButton("Sign out", color: Theme.text)
                accountButton("Delete account", color: Theme.danger)
                Spacer(minLength: 0)
            }
        }
        .sheet(isPresented: $isShowingSubscription) {
            PaywallSheet()
        }
        .sheet(isPresented: $isEditingName) {
            DisplayNameSheet()
        }
        .onChange(of: schedule) { _, newValue in
            reschedule(newValue)
        }
        .onChange(of: storedLanguage) { _, _ in
            // Notification texts follow the app language.
            reschedule(reminders.schedule)
        }
    }

    // MARK: League

    /// Display name, taking part, blocked people (docs/SOCIAL.md).
    private var leagueGroup: some View {
        SettingsGroup {
            Button {
                isEditingName = true
            } label: {
                SettingsRow("Display name") {
                    HStack(spacing: 8) {
                        if let name = league.displayName {
                            Text(verbatim: name)
                        } else {
                            Text("Not chosen")
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .accessibilityHidden(true)
                    }
                    .font(.text(15))
                    .foregroundStyle(Theme.textMuted)
                    .lineLimit(1)
                }
            }
            .buttonStyle(PressFeedbackStyle())
            divider
            SettingsRow("Take part in the league") {
                Toggle(isOn: Binding(get: { league.isTakingPart }, set: { league.setTakingPart($0) })) {
                    Text("Take part in the league")
                }
                .labelsHidden()
                .tint(accent.color)
                .frame(minWidth: 60, minHeight: Theme.Layout.minTouchTarget)
            }
            if !league.isTakingPart {
                Text("You are not placed in a group, cannot be challenged, and your name is not shown anywhere.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            divider
            NavigationLink {
                BlockedUsersScreen()
            } label: {
                SettingsRow("Blocked users") {
                    HStack(spacing: 8) {
                        Text(verbatim: "\(league.blocked.count)")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .accessibilityHidden(true)
                    }
                    .font(.text(15))
                    .foregroundStyle(Theme.textMuted)
                }
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }

    private var divider: some View {
        Rectangle().fill(Theme.line).frame(height: 1)
    }

    // MARK: Reminder

    /// Seven round day buttons and the time with − / +.
    private func reminderDetails(_ schedule: ReminderSchedule) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("Training days"))

            HStack(spacing: 4) {
                Text("Time")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                Spacer(minLength: 0)
                StepButton(symbol: "minus", label: "Earlier") {
                    reminders.schedule.shiftTime(by: -1)
                }
                Text(verbatim: ReminderText.time(schedule, locale: locale))
                    .font(.grotesk(20))
                    .foregroundStyle(Theme.text)
                    .frame(width: 70)
                StepButton(symbol: "plus", label: "Later") {
                    reminders.schedule.shiftTime(by: 1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.line).frame(height: 1)
        }
    }

    private var permissionHint: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notifications are turned off for Unweak in the iOS settings.")
                .font(.text(13))
                .foregroundStyle(Theme.danger)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            } label: {
                Text("Open iOS settings")
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
                    .frame(minHeight: Theme.Layout.minTouchTarget)
            }
            .buttonStyle(PressFeedbackStyle())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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

    /// Sign out and delete account work from step 6 on (sign-in); until then disabled.
    /// Delete account will ask before it acts.
    private func accountButton(_ title: LocalizedStringKey, color: Color) -> some View {
        Button {} label: {
            Text(title)
                .font(.text(15))
                .foregroundStyle(color)
                .frame(minHeight: Theme.Layout.minTouchTarget)
        }
        .buttonStyle(PressFeedbackStyle())
        .disabled(true)
        .opacity(0.4)
    }
}

/// A group of settings rows on the surface color with a thin outline.
private struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }
}

/// One settings row: title on the left (Inter 16), the value or control on the right.
private struct SettingsRow<Value: View>: View {
    private let title: LocalizedStringKey
    private let value: Value

    init(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) {
        self.title = title
        self.value = value()
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.text(16))
                .foregroundStyle(Theme.text)
            Spacer(minLength: 0)
            value
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// Round weekday button for the reminder, 44 pt.
private struct DayChip: View {
    @Environment(\.accent) private var accent
    let title: String
    let accessibilityName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.text(13))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Theme.onAccent : Theme.textSoft)
                .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                .background(Circle().fill(isSelected ? accent.color : Color.clear))
                .overlay(Circle().strokeBorder(isSelected ? accent.color : Theme.lineStrong, lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(Text(verbatim: accessibilityName))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Square − / + button, 44 pt.
private struct StepButton: View {
    let symbol: String
    let label: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.text)
                .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(Text(label))
    }
}

/// Accent color circle (24 pt) in a 40 × 44 pt touch area, ringed when selected.
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
            Circle()
                .fill(accent.color)
                .frame(width: 24, height: 24)
                .padding(3)
                .overlay(Circle().strokeBorder(isSelected ? Theme.text : Color.clear, lineWidth: 2))
                .frame(width: 40, height: Theme.Layout.minTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(Text(accent.name))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// People the user blocked in the league, each with "Unblock".
private struct BlockedUsersScreen: View {
    @Environment(\.accent) private var accent
    @Environment(LeagueStore.self) private var league

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 14) {
                BackButton()
                Text("Blocked users")
                    .font(.grotesk(28))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }
            if league.blocked.isEmpty {
                Text("You have not blocked anyone. Touch and hold a name in the league to block it.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                SettingsGroup {
                    ForEach(league.blocked) { person in
                        HStack(spacing: 12) {
                            LeagueAvatarView(avatar: person.avatar)
                            Text(verbatim: person.name)
                                .font(.text(16))
                                .foregroundStyle(Theme.text)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                            Button {
                                league.unblock(person.id)
                            } label: {
                                Text("Unblock")
                                    .font(.textSemibold(15))
                                    .foregroundStyle(accent.color)
                                    .frame(minWidth: Theme.Layout.minTouchTarget, minHeight: Theme.Layout.minTouchTarget)
                            }
                            .buttonStyle(PressFeedbackStyle())
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 56)
                    }
                }
            }
        }
    }
}

/// Legal texts are still open (docs/SPEC.md); each row leads to a placeholder page.
private struct LegalScreen: View {
    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 14) {
                BackButton()
                Text("Legal")
                    .font(.grotesk(28))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }
            SettingsGroup {
                row("Privacy")
                Rectangle().fill(Theme.line).frame(height: 1)
                row("Terms")
                Rectangle().fill(Theme.line).frame(height: 1)
                row("Imprint")
            }
        }
    }

    private func row(_ title: LocalizedStringKey) -> some View {
        NavigationLink {
            ComingLaterScreen(title: title)
        } label: {
            SettingsRow(title) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(PressFeedbackStyle())
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
