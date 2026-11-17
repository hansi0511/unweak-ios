import Foundation
import Observation
import UserNotifications

/// When the training reminder comes: chosen weekdays at one time of day.
/// Weekdays use `Calendar` numbering (1 = Sunday … 7 = Saturday).
struct ReminderSchedule: Equatable, Sendable {
    static let displayOrder = [2, 3, 4, 5, 6, 7, 1]
    static let stepMinutes = 30
    static let defaultWeekdays: Set<Int> = [2, 4, 6]
    static let defaultMinutes = 18 * 60

    var isEnabled = false
    var weekdays: Set<Int> = ReminderSchedule.defaultWeekdays
    /// Minutes after midnight, a multiple of 30.
    var minutes = ReminderSchedule.defaultMinutes

    var hour: Int { minutes / 60 }
    var minute: Int { minutes % 60 }

    /// Chosen weekdays, Monday first.
    var orderedWeekdays: [Int] { Self.displayOrder.filter(weekdays.contains) }

    /// One repeating trigger per chosen weekday; none when switched off.
    var triggers: [DateComponents] {
        guard isEnabled else { return [] }
        return orderedWeekdays.map { DateComponents(hour: hour, minute: minute, weekday: $0) }
    }

    mutating func toggle(_ weekday: Int) {
        if weekdays.contains(weekday) { weekdays.remove(weekday) } else { weekdays.insert(weekday) }
    }

    /// Moves the time by `steps` × 30 minutes, wrapping around midnight.
    mutating func shiftTime(by steps: Int) {
        let day = 24 * 60
        minutes = ((minutes + steps * Self.stepMinutes) % day + day) % day
    }
}

/// The reminder settings, stored in `UserDefaults`. The number of chosen weekdays is
/// also the weekly training target on the dashboard.
@MainActor
@Observable
final class ReminderSettings {
    private enum Key {
        static let enabled = "reminderEnabled"
        static let weekdays = WeeklyTarget.weekdaysKey
        static let minutes = "reminderMinutes"
    }

    var schedule: ReminderSchedule {
        didSet { save() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var schedule = ReminderSchedule()
        schedule.isEnabled = defaults.bool(forKey: Key.enabled)
        if let days = defaults.array(forKey: Key.weekdays) as? [Int] {
            schedule.weekdays = Set(days.filter { (1...7).contains($0) })
        }
        if let minutes = defaults.object(forKey: Key.minutes) as? Int {
            schedule.minutes = minutes
        }
        self.schedule = schedule
    }

    /// Chosen training days per week, 3 if none are chosen.
    var weeklyTarget: Int {
        schedule.weekdays.isEmpty ? WeeklyTarget.defaultValue : schedule.weekdays.count
    }

    private func save() {
        defaults.set(schedule.isEnabled, forKey: Key.enabled)
        defaults.set(schedule.orderedWeekdays, forKey: Key.weekdays)
        defaults.set(schedule.minutes, forKey: Key.minutes)
    }
}

/// Hands the schedule to iOS as repeating local notifications.
enum ReminderScheduler {
    static let identifierPrefix = "unweak.reminder."

    /// Replaces all reminder notifications with the given schedule.
    static func apply(_ schedule: ReminderSchedule, language: AppLanguage) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: (1...7).map { identifierPrefix + "\($0)" })
        guard schedule.isEnabled else { return }

        for components in schedule.triggers {
            let content = UNMutableNotificationContent()
            content.title = "Unweak"
            content.body = LocalizedLookup.string("Time for your workout. Your plan is ready.", language: language)
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: identifierPrefix + "\(components.weekday ?? 0)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// Asks for permission to show notifications. Returns whether they are allowed.
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        if granted { return true }
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }
}

/// Texts for the reminder settings.
enum ReminderText {
    /// A Monday (Gregorian), used to name weekdays in any language.
    private static let referenceMonday = DateComponents(year: 2026, month: 11, day: 16, hour: 12)

    /// Gregorian calendar in the user's time zone, independent of the phone's calendar setting.
    static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    static func date(forWeekday weekday: Int, calendar: Calendar = gregorian) -> Date {
        let monday = calendar.date(from: referenceMonday) ?? .now
        let offset = (weekday + 5) % 7 // Monday (2) → 0 … Sunday (1) → 6
        return calendar.date(byAdding: .day, value: offset, to: monday) ?? monday
    }

    /// "Mo" / "Mo" (short), for the day buttons.
    static func shortName(_ weekday: Int, locale: Locale) -> String {
        date(forWeekday: weekday).formatted(.dateTime.weekday(.short).locale(locale))
    }

    /// "Mon" / "Mo." (abbreviated), for the summary sentence.
    static func abbreviatedName(_ weekday: Int, locale: Locale) -> String {
        date(forWeekday: weekday).formatted(.dateTime.weekday(.abbreviated).locale(locale))
    }

    /// "Monday" / "Montag", for VoiceOver.
    static func fullName(_ weekday: Int, locale: Locale) -> String {
        date(forWeekday: weekday).formatted(.dateTime.weekday(.wide).locale(locale))
    }

    /// "Mon, Wed, and Fri" / "Mo., Mi. und Fr.".
    static func dayList(_ schedule: ReminderSchedule, locale: Locale) -> String {
        schedule.orderedWeekdays.map { abbreviatedName($0, locale: locale) }
            .formatted(.list(type: .and).locale(locale))
    }

    /// "6:00 PM" / "18:00".
    static func time(_ schedule: ReminderSchedule, locale: Locale, calendar: Calendar = gregorian) -> String {
        let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: schedule.hour, minute: schedule.minute)) ?? .now
        return date.formatted(.dateTime.hour().minute().locale(locale))
    }
}
