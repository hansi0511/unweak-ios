import SwiftUI

/// Localized display of journal values.
enum ValueText {
    /// "8 reps", "30 s" or "1:30".
    static func result(_ value: Int, unit: ExerciseResult.Unit) -> Text {
        switch unit {
        case .reps: Text("\(value) reps")
        case .seconds: seconds(value)
        }
    }

    /// "45 s" below a minute, "1:30" from one minute on.
    static func seconds(_ value: Int) -> Text {
        value < 60 ? Text("\(value) s") : Text(verbatim: TimeText.clock(value))
    }

    /// Whole minutes, at least 1: "21 min".
    static func minutes(_ seconds: Int) -> Text {
        Text("\(max(1, (seconds + 30) / 60)) min")
    }

    /// Total time such as "5 h 20 min" in the user's language.
    static func totalTime(_ seconds: Int, locale: Locale) -> Text {
        let style = Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes], width: .abbreviated).locale(locale)
        return Text(verbatim: Duration.seconds(seconds).formatted(style))
    }

    /// Threshold of an achievement: "10", "3 min", "20 s".
    static func threshold(of achievement: Achievement) -> Text {
        let value = achievement.threshold
        switch achievement.kind {
        case .workouts, .reps, .streak:
            return Text(verbatim: "\(value)")
        case .seconds:
            return value >= 60 && value % 60 == 0 ? Text("\(value / 60) min") : Text("\(value) s")
        }
    }
}
