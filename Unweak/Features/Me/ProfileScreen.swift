import SwiftUI

/// The "Me" area, opened from the title of the Me tab: the level of the avatar, its
/// customization (body, colors, background, extra) and the settings. Locked bodies and
/// extras show what unlocks them. Every choice is saved at once.
struct ProfileScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    private let catalog: Catalog

    init(catalog: Catalog = .main) {
        self.catalog = catalog
    }

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        let stats = JournalStats(entries: store.entries)
        let unlocks = AvatarUnlocks(stats: stats, catalog: catalog, weeklyTarget: reminders.weeklyTarget) {
            store.reachedStages(of: $0)
        }
        let style = store.data.avatar
        let currentBody = unlocks.body(for: style)
        let currentExtra = unlocks.extra(for: style)

        ScreenContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BackButton()
                    Spacer()
                }
                Text("Me")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }

            AvatarView(style: style, body: currentBody, extra: currentExtra)
                .frame(width: 200, height: 200)
                .frame(maxWidth: .infinity)

            section("Level") {
                Text("Your avatar grows with your training. Achievements and skills unlock more.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 8) {
                    ForEach(AvatarBody.allCases) { body in
                        LevelRow(
                            level: body,
                            unlocks: unlocks,
                            style: style,
                            extra: currentExtra,
                            requirement: requirement(body.unlock)
                        )
                    }
                }
            }

            MonoLabel("Your avatar", color: Theme.text, bold: true)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 6)

            section("Body") {
                LazyVGrid(columns: columns, spacing: 10) {
                    OptionTile(
                        title: "Automatic",
                        caption: Text("Grows with you"),
                        isSelected: style.body == nil,
                        isLocked: false
                    ) {
                        AvatarView(style: style, body: unlocks.highestBody, extra: currentExtra, breathes: false)
                    } action: {
                        update { $0.body = nil }
                    }
                    ForEach(AvatarBody.allCases) { body in
                        let isLocked = !unlocks.isUnlocked(body)
                        OptionTile(
                            title: body.name,
                            caption: isLocked ? requirement(body.unlock) : nil,
                            isSelected: style.body == body,
                            isLocked: isLocked
                        ) {
                            AvatarView(style: style, body: body, extra: currentExtra, breathes: false)
                        } action: {
                            update { $0.body = body }
                        }
                    }
                }
            }

            section("Color") {
                ColorRow(selection: style.color) { color in
                    update { $0.color = color }
                }
            }

            section("Second color") {
                ColorRow(selection: style.extraColor) { color in
                    update { $0.extraColor = color }
                }
            }

            section("Background") {
                HStack(spacing: 8) {
                    ForEach(AvatarBackground.allCases) { background in
                        SelectChip(background.name, isSelected: style.background == background, expands: true) {
                            update { $0.background = background }
                        }
                    }
                }
            }

            section("Extras") {
                LazyVGrid(columns: columns, spacing: 10) {
                    OptionTile(title: "None", caption: nil, isSelected: currentExtra == nil, isLocked: false) {
                        AvatarView(style: style, body: currentBody, extra: nil, breathes: false)
                    } action: {
                        update { $0.extra = nil }
                    }
                    ForEach(AvatarExtra.allCases) { extra in
                        let isLocked = !unlocks.isUnlocked(extra)
                        OptionTile(
                            title: extra.name,
                            caption: isLocked ? requirement(extra.unlock) : nil,
                            isSelected: currentExtra == extra,
                            isLocked: isLocked
                        ) {
                            AvatarView(style: style, body: currentBody, extra: extra, breathes: false)
                        } action: {
                            update { $0.extra = extra }
                        }
                    }
                }
            }

            NavigationLink {
                SettingsScreen()
            } label: {
                SettingsRow()
            }
            .buttonStyle(PressFeedbackStyle())
            .padding(.top, 6)
        }
    }

    private func update(_ change: (inout AvatarStyle) -> Void) {
        var style = store.data.avatar
        change(&style)
        store.setAvatar(style)
    }

    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            MonoLabel(title)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    /// What unlocks a locked body or extra.
    private func requirement(_ unlock: AvatarUnlock) -> Text? {
        switch unlock {
        case .always:
            return nil
        case .workouts(let count):
            return Text("From \(count) workouts")
        case .masteredSkill:
            return Text("Master a skill")
        case .achievement(let id):
            guard let achievement = catalog.achievements.first(where: { $0.id == id }) else { return nil }
            let label = Text(catalog: achievement.labelKey)
            if achievement.kind == .workouts && achievement.threshold == 1 {
                return Text("Achievement: \(label)")
            }
            return Text("Achievement: \(ValueText.threshold(of: achievement)) \(label)")
        }
    }
}

/// One level of the avatar: still preview, name and its state — unlocked, the next one
/// with the workouts still missing, or what unlocks it.
private struct LevelRow: View {
    @Environment(\.accent) private var accent
    let level: AvatarBody
    let unlocks: AvatarUnlocks
    let style: AvatarStyle
    let extra: AvatarExtra?
    let requirement: Text?

    var body: some View {
        let isUnlocked = unlocks.isUnlocked(level)
        let isNext = unlocks.nextBody == level
        HStack(spacing: 12) {
            AvatarView(style: style, body: level, extra: extra, breathes: false)
                .frame(width: 56, height: 56)
                .opacity(isUnlocked || isNext ? 1 : 0.45)
            VStack(alignment: .leading, spacing: 6) {
                Text(level.name)
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
                if isUnlocked {
                    MonoLabel("Unlocked", color: accent.color, bold: true)
                } else if isNext, case .workouts(let count) = level.unlock {
                    Text("\(max(0, count - unlocks.workouts)) more workouts")
                        .font(.text(13))
                        .foregroundStyle(Theme.textSoft)
                    SegmentedProgress(total: 10, filled: unlocks.workouts * 10 / max(count, 1), height: 4, label: "Level progress")
                } else if let requirement {
                    requirement
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            if isUnlocked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent.color)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                    .accessibilityHidden(true)
            }
        }
        .padding(10)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(isNext ? accent.color : Theme.line, lineWidth: isNext ? 2 : 1))
        .accessibilityElement(children: .combine)
    }
}

/// Row that opens the settings.
private struct SettingsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Settings")
                    .font(.textSemibold(15))
                    .foregroundStyle(Theme.text)
                Text("Account, subscription, reminders, color, language")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textMuted)
                .accessibilityHidden(true)
        }
        .padding(12)
        .frame(minHeight: Theme.Layout.minTouchTarget)
        .background(Theme.surface)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// A selectable tile with a small avatar preview, a title and an optional caption.
/// Locked tiles are dimmed, show a lock and cannot be chosen.
private struct OptionTile<Preview: View>: View {
    @Environment(\.accent) private var accent
    let title: LocalizedStringKey
    let caption: Text?
    let isSelected: Bool
    let isLocked: Bool
    @ViewBuilder let preview: () -> Preview
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                preview()
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .topTrailing) {
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text)
                                .padding(5)
                                .background(Theme.background.opacity(0.8))
                                .accessibilityHidden(true)
                        }
                    }
                Text(title)
                    .font(.textSemibold(13))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let caption {
                    caption
                        .font(.text(11))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.line, lineWidth: isSelected ? 2 : 1))
            .opacity(isLocked ? 0.5 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .disabled(isLocked)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var accessibilityValue: Text {
        guard isLocked else { return Text(verbatim: "") }
        guard let caption else { return Text("Locked") }
        return Text("Locked, \(caption)")
    }
}

/// Seven color swatches, 44 pt each.
private struct ColorRow: View {
    let selection: AvatarColor
    let onSelect: (AvatarColor) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AvatarColor.allCases) { color in
                let isSelected = color == selection
                Button {
                    onSelect(color)
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 28, height: 28)
                        .padding(4)
                        .overlay(Circle().strokeBorder(isSelected ? Theme.text : Color.clear, lineWidth: 2))
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityLabel(Text(color.name))
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
    .previewEnvironment()
}

#Preview("German") {
    NavigationStack {
        ProfileScreen()
    }
    .previewEnvironment()
    .environment(\.locale, Locale(identifier: "de"))
}
