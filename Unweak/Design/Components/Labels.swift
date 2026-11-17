import SwiftUI

/// Uppercase monospaced label for metadata, section labels and counters.
struct MonoLabel: View {
    private let text: Text
    private let color: Color
    private let bold: Bool

    init(_ key: LocalizedStringKey, color: Color = Theme.textMuted, bold: Bool = false) {
        self.text = Text(key)
        self.color = color
        self.bold = bold
    }

    /// For values that are already formatted or localized, such as dates or plan metadata.
    init(verbatim string: String, color: Color = Theme.textMuted, bold: Bool = false) {
        self.text = Text(verbatim: string)
        self.color = color
        self.bold = bold
    }

    var body: some View {
        text
            .font(bold ? .monoBold : .mono)
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

/// Small outlined badge, e.g. "Free" in the accent color or "Pro" in orange.
struct Badge: View {
    enum Kind {
        case free
        case subscription
        case selected
        case custom
    }

    @Environment(\.accent) private var accent
    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    private var title: LocalizedStringKey {
        switch kind {
        case .free: "Free"
        case .subscription: "Pro"
        case .selected: "Selected"
        case .custom: "Custom"
        }
    }

    private var color: Color {
        kind == .subscription ? Theme.subscription : accent.color
    }

    var body: some View {
        Text(title)
            .font(.monoBold)
            .tracking(1)
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(Rectangle().strokeBorder(color, lineWidth: 1))
    }
}

/// Header block used at the top of every tab: small label, large title, optional trailing control.
struct ScreenHeader<Trailing: View>: View {
    private let label: MonoLabel
    private let title: LocalizedStringKey
    private let trailing: Trailing

    init(label: MonoLabel, title: LocalizedStringKey, @ViewBuilder trailing: () -> Trailing) {
        self.label = label
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                label
                Text(title)
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 0)
            trailing
        }
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(label: MonoLabel, title: LocalizedStringKey) {
        self.init(label: label, title: title) { EmptyView() }
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        VStack(alignment: .leading, spacing: 12) {
            ScreenHeader(label: MonoLabel("This week"), title: "Me")
            HStack {
                Badge(kind: .free)
                Badge(kind: .subscription)
                Badge(kind: .selected)
            }
        }
    }
}

#Preview("German") {
    VStack(alignment: .leading, spacing: 12) {
        ScreenHeader(label: MonoLabel("This week"), title: "Me")
        HStack {
            Badge(kind: .free)
            Badge(kind: .subscription)
            Badge(kind: .selected)
        }
    }
    .padding(Theme.Layout.screenEdge)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Theme.background)
    .environment(\.locale, Locale(identifier: "de"))
}
