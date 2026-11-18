import SwiftUI

/// The three tabs of the Me area.
private enum ProfileTab: CaseIterable, Hashable {
    case body
    case colors
    case extras

    var title: LocalizedStringKey {
        switch self {
        case .body: "Body"
        case .colors: "Colors"
        case .extras: "Extras"
        }
    }
}

/// The Me area (Design V2, `V2-Profil`), opened from the avatar in the Me tab: the level
/// with the way to the next body, and the avatar customization in three tabs — body,
/// colors, extras. Locked tiles are dimmed with a lock; tapping one shows what unlocks
/// it below the grid. Every choice is saved at once. Settings open from the top right.
struct ProfileScreen: View {
    @Environment(UserDataStore.self) private var store
    @Environment(ReminderSettings.self) private var reminders
    @State private var tab: ProfileTab = .body
    /// What unlocks the locked tile tapped last; `nil` shows the general hint.
    @State private var lockedHint: AvatarUnlock?
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
        let unlocks = AvatarUnlocks(stats: stats, catalog: catalog, weeklyTarget: reminders.weeklyTarget, leagueWins: Set(store.data.leagueWins)) {
            store.reachedStages(of: $0)
        }
        let style = store.data.avatar
        let currentBody = unlocks.body(for: style)
        let currentExtra = unlocks.extra(for: style)

        ScreenContainer {
            HStack {
                BackButton()
                Spacer()
                NavigationLink {
                    SettingsScreen()
                } label: {
                    IconButtonLabel(systemImage: "slider.horizontal.3")
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityLabel(Text("Settings"))
            }

            LevelHeader(style: style, body: currentBody, extra: currentExtra, unlocks: unlocks)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    ForEach(ProfileTab.allCases, id: \.self) { item in
                        SegmentButton(item.title, isSelected: tab == item) {
                            tab = item
                            lockedHint = nil
                        }
                    }
                }

                switch tab {
                case .body:
                    LazyVGrid(columns: columns, spacing: 10) {
                        OptionTile(title: "Automatic", isSelected: style.body == nil, isLocked: false) {
                            AvatarView(style: style, body: unlocks.highestBody, extra: currentExtra, breathes: false)
                        } action: {
                            update { $0.body = nil }
                        }
                        ForEach(AvatarBody.allCases) { body in
                            let isLocked = !unlocks.isUnlocked(body)
                            OptionTile(title: body.name, isSelected: style.body == body, isLocked: isLocked) {
                                AvatarView(style: style, body: body, extra: currentExtra, breathes: false)
                            } action: {
                                if isLocked {
                                    lockedHint = body.unlock
                                } else {
                                    update { $0.body = body }
                                }
                            }
                        }
                    }
                    hintLine
                case .colors:
                    colorsTab(style)
                case .extras:
                    LazyVGrid(columns: columns, spacing: 10) {
                        OptionTile(title: "None", isSelected: currentExtra == nil, isLocked: false) {
                            AvatarView(style: style, body: currentBody, extra: nil, breathes: false)
                        } action: {
                            update { $0.extra = nil }
                        }
                        ForEach(AvatarExtra.allCases) { extra in
                            let isLocked = !unlocks.isUnlocked(extra)
                            OptionTile(title: extra.name, isSelected: currentExtra == extra, isLocked: isLocked) {
                                AvatarView(style: style, body: currentBody, extra: extra, breathes: false)
                            } action: {
                                if isLocked {
                                    lockedHint = extra.unlock
                                } else {
                                    update { $0.extra = extra }
                                }
                            }
                        }
                    }
                    hintLine
                }
            }
        }
    }

    private func colorsTab(_ style: AvatarStyle) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Figure")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                ColorRow(selection: style.color) { color in
                    update { $0.color = color }
                }
                .accessibilityLabel(Text("Color of the figure"))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Extra")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                ColorRow(selection: style.extraColor) { color in
                    update { $0.extraColor = color }
                }
                .accessibilityLabel(Text("Color of the extra"))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Background")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
                HStack(spacing: 6) {
                    ForEach(AvatarBackground.allCases) { background in
                        SegmentButton(background.name, isSelected: style.background == background) {
                            update { $0.background = background }
                        }
                    }
                }
            }
        }
    }

    /// Below the grid: how to see conditions, or the condition of the tapped locked tile.
    private var hintLine: some View {
        Group {
            if let lockedHint, let requirement = AvatarRequirementText.text(for: lockedHint, catalog: catalog) {
                Text("Locked: \(requirement)")
                    .foregroundStyle(Theme.text)
            } else {
                Text("Tap a locked item to see how to unlock it.")
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .font(.text(14))
        .fixedSize(horizontal: false, vertical: true)
    }

    private func update(_ change: (inout AvatarStyle) -> Void) {
        var style = store.data.avatar
        change(&style)
        store.setAvatar(style)
    }
}

/// What unlocks a locked body or extra, as a short phrase ("From 50 workouts").
enum AvatarRequirementText {
    static func text(for unlock: AvatarUnlock, catalog: Catalog) -> Text? {
        switch unlock {
        case .always:
            return nil
        case .workouts(let count):
            return Text("From \(count) workouts")
        case .masteredSkill:
            return Text("Master a skill")
        case .leagueWin(let league):
            return Text("First place in the \(Text(league.name))")
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

/// Avatar (132 pt, breathing) next to "Level", the body's name, a bar towards the next
/// body and how many workouts are still missing.
private struct LevelHeader: View {
    @Environment(\.accent) private var accent
    let style: AvatarStyle
    let avatarBody: AvatarBody
    let extra: AvatarExtra?
    let unlocks: AvatarUnlocks

    init(style: AvatarStyle, body: AvatarBody, extra: AvatarExtra?, unlocks: AvatarUnlocks) {
        self.style = style
        self.avatarBody = body
        self.extra = extra
        self.unlocks = unlocks
    }

    /// Share of the way to the next body that is unlocked by workouts; `nil` otherwise.
    private var fraction: Double? {
        guard let next = unlocks.nextBody, case .workouts(let count) = next.unlock, count > 0 else { return nil }
        return min(1, Double(unlocks.workouts) / Double(count))
    }

    var body: some View {
        HStack(spacing: 18) {
            AvatarView(style: style, body: avatarBody, extra: extra)
                .frame(width: 132, height: 132)
            VStack(alignment: .leading, spacing: 8) {
                Text("Level")
                    .font(.text(14))
                    .foregroundStyle(Theme.textMuted)
                Text(unlocks.highestBody.name)
                    .font(.grotesk(28))
                    .foregroundStyle(Theme.text)
                if let fraction {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Theme.line)
                            Rectangle()
                                .fill(accent.color)
                                .frame(width: max(0, proxy.size.width * fraction))
                        }
                    }
                    .frame(height: 6)
                    .accessibilityHidden(true)
                }
                nextText
                    .font(.text(13))
                    .foregroundStyle(Theme.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var nextText: Text {
        guard let next = unlocks.nextBody else { return Text("All levels reached") }
        if let missing = unlocks.workoutsToNextBody {
            return Text("\(missing) more workouts to \(Text(next.name).foregroundColor(Theme.text))")
        }
        return Text("Master a skill to become a legend")
    }
}

/// A tile with a large still preview and a name. Locked tiles are dimmed with a lock and
/// no text; tapping them reports the tap so the screen can show the condition.
private struct OptionTile<Preview: View>: View {
    @Environment(\.accent) private var accent
    let title: LocalizedStringKey
    let isSelected: Bool
    let isLocked: Bool
    @ViewBuilder let preview: () -> Preview
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                preview()
                    .frame(maxWidth: .infinity)
                    .opacity(isLocked ? 0.35 : 1)
                    .overlay {
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.text)
                                .accessibilityHidden(true)
                        }
                    }
                Text(title)
                    .font(.text(13))
                    .foregroundStyle(isLocked ? Theme.textMuted : Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(EdgeInsets(top: 8, leading: 4, bottom: 10, trailing: 4))
            .frame(maxWidth: .infinity)
            .background(isSelected ? Theme.surfaceSelected : Theme.surface)
            .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.line, lineWidth: isSelected ? 2 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(isLocked ? Text("Locked") : Text(verbatim: ""))
        .accessibilityHint(isLocked ? Text("Shows how to unlock it") : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Seven color circles, 32 pt in a 44 pt touch area.
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
                        .frame(width: 32, height: 32)
                        .padding(3)
                        .overlay(Circle().strokeBorder(isSelected ? Theme.text : Color.clear, lineWidth: 2))
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressFeedbackStyle())
                .accessibilityLabel(Text(color.name))
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .accessibilityElement(children: .contain)
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
