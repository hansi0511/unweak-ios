import SwiftUI

/// Settings, opened from the dashboard. Step 1 contains only the accent color
/// (needed to check the design in all six colors). Account, reminders and
/// language follow in step 5.
struct SettingsScreen: View {
    @AppStorage(Accent.storageKey) private var accent: Accent = .default

    var body: some View {
        ScreenContainer {
            HStack {
                BackButton()
                Spacer()
            }

            ScreenHeader(label: MonoLabel(verbatim: "Unweak"), title: "Settings")

            VStack(alignment: .leading, spacing: 12) {
                MonoLabel("Appearance")
                Card {
                    VStack(alignment: .leading, spacing: 12) {
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
                }
            }

            PlaceholderNote()
        }
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
}

#Preview("German") {
    NavigationStack {
        SettingsScreen()
    }
    .environment(\.locale, Locale(identifier: "de"))
}
