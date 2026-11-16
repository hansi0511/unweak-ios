import SwiftUI

/// Journal tab. Step 1 placeholder: header with the current month and the three metrics.
/// Entries and local storage follow in step 4.
struct JournalScreen: View {
    @Environment(\.locale) private var locale

    private var monthTitle: String {
        Date.now.formatted(.dateTime.month(.wide).year().locale(locale))
    }

    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel(verbatim: monthTitle), title: "Journal")

            HStack(spacing: 10) {
                MetricTile(value: "0", label: "Sessions")
                MetricTile(value: "0", label: "Time")
                MetricTile(value: "0", label: "Records")
            }

            PlaceholderNote()
        }
    }
}

/// Small card with a large number and a label below.
struct MetricTile: View {
    private let value: String
    private let label: LocalizedStringKey

    init(value: String, label: LocalizedStringKey) {
        self.value = value
        self.label = label
    }

    var body: some View {
        Card(padding: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: value)
                    .font(.metric)
                    .foregroundStyle(Theme.text)
                MonoLabel(label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        JournalScreen()
    }
}

#Preview("German") {
    NavigationStack {
        JournalScreen()
    }
    .environment(\.locale, Locale(identifier: "de"))
}
