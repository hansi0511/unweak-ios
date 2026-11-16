import SwiftUI

/// Dashboard tab. Step 1 placeholder: shows the header, navigation to settings
/// and the design components. Week, goal and achievements follow in step 4.
struct DashboardScreen: View {
    var body: some View {
        ScreenContainer {
            ScreenHeader(label: MonoLabel("This week"), title: "Dashboard") {
                NavigationLink {
                    SettingsScreen()
                } label: {
                    IconButtonLabel(systemImage: "slider.horizontal.3")
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityLabel(Text("Settings"))
            }

            HUDPanel {
                VStack(alignment: .leading, spacing: 10) {
                    MonoLabel("Next goal")
                    Text("No goal yet")
                        .font(.metric)
                        .foregroundStyle(Theme.text)
                    SegmentedProgress(total: 5, filled: 0, label: "Stage")
                }
            }

            PlaceholderNote()
        }
    }
}

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

#Preview {
    NavigationStack {
        DashboardScreen()
    }
}

#Preview("German") {
    NavigationStack {
        DashboardScreen()
    }
    .environment(\.locale, Locale(identifier: "de"))
}
