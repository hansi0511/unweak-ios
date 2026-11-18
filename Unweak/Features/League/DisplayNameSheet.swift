import SwiftUI

/// Choose or change the public display name (docs/SOCIAL.md): 3 to 20 letters, digits,
/// dots and underscores, no offensive words, changeable once every 30 days.
struct DisplayNameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(LeagueStore.self) private var league
    @State private var name = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        let problem = DisplayName.problem(with: name)
        let nextChange = DisplayName.nextChange(lastChange: league.displayNameChangedAt, now: .now)
        let isFirstName = league.displayName == nil

        ScreenContainer {
            IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                dismiss()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(isFirstName ? LocalizedStringKey("Choose your name") : LocalizedStringKey("Change your name"))
                    .font(.grotesk(32))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Text("Others in the league only see this name, your avatar and your points.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let nextChange, !isFirstName {
                Text("You can change your name again on \(nextChange.formatted(.dateTime.day().month(.wide).locale(locale))).")
                    .font(.text(15))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    TextField(text: $name, prompt: Text(verbatim: "bar.joe").foregroundStyle(Theme.textMuted)) {
                        Text("Display name")
                    }
                    .font(.text(17))
                    .foregroundStyle(Theme.text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 52)
                    .background(Theme.surface)
                    .overlay(Rectangle().strokeBorder(isFocused ? accent.color : Theme.lineStrong, lineWidth: 1))
                    .submitLabel(.done)
                    .onSubmit(save)

                    if let problem, !name.isEmpty {
                        Text(problem.message)
                            .font(.text(13))
                            .foregroundStyle(Theme.danger)
                    } else {
                        Text("3 to 20 characters: letters, digits, dot and underscore.")
                            .font(.text(13))
                            .foregroundStyle(Theme.textMuted)
                    }
                }

                if !isFirstName {
                    Text("You can change your name once every 30 days.")
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                }

                PrimaryButton("Save") {
                    save()
                }
                .disabled(problem != nil)
            }
        }
        .presentationBackground(Theme.background)
        .onAppear {
            name = league.displayName ?? ""
            isFocused = true
        }
    }

    private func save() {
        guard DisplayName.problem(with: name) == nil else { return }
        league.setDisplayName(name)
        dismiss()
    }
}

#Preview {
    DisplayNameSheet()
        .environment(LeagueStore.preview(named: nil))
}

#Preview("German") {
    DisplayNameSheet()
        .environment(LeagueStore.preview(named: nil))
        .environment(\.locale, Locale(identifier: "de"))
}
