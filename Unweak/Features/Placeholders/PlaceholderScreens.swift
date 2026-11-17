import SwiftUI

/// Short note on screens whose content follows in a later step.
struct PlaceholderNote: View {
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 6) {
                MonoLabel("In progress", bold: true)
                Text("This screen is filled in a later development step.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
            }
        }
    }
}

/// Pushed screen for a feature that follows in a later step (e.g. creating a workout).
struct ComingLaterScreen: View {
    private let title: LocalizedStringKey

    init(title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        ScreenContainer {
            HStack {
                BackButton()
                Spacer()
            }
            Text(title)
                .font(.screenTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)
            PlaceholderNote()
        }
    }
}
