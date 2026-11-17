import SwiftUI

/// Compact 44 pt label for header actions such as "Custom" or "Technique".
/// Use it as the label of a `Button` or `NavigationLink`.
struct ChipLabel: View {
    enum Style {
        /// Dashed accent outline (secondary action).
        case dashed
        /// Strong line outline in text color.
        case outline
    }

    @Environment(\.accent) private var accent
    private let title: LocalizedStringKey
    private let systemImage: String?
    private let style: Style

    init(_ title: LocalizedStringKey, systemImage: String? = nil, style: Style = .outline) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(.monoBold)
                .tracking(1)
                .textCase(.uppercase)
                .lineLimit(1)
        }
        .foregroundStyle(style == .dashed ? accent.color : Theme.text)
        .padding(.horizontal, 14)
        .frame(minWidth: Theme.Layout.minTouchTarget, minHeight: Theme.Layout.minTouchTarget)
        .overlay {
            switch style {
            case .dashed:
                Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            case .outline:
                Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1)
            }
        }
        .contentShape(Rectangle())
    }
}

/// "Push · 21 min · Beginner" style metadata line.
struct MetaLine: View {
    private let parts: [Text]
    private let color: Color

    init(_ parts: [Text], color: Color = Theme.textMuted) {
        self.parts = parts
        self.color = color
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                if index > 0 {
                    Text(verbatim: "·").accessibilityHidden(true)
                }
                part
            }
        }
        .font(.mono)
        .tracking(1)
        .textCase(.uppercase)
        .foregroundStyle(color)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityElement(children: .combine)
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        HStack {
            ChipLabel("Custom", systemImage: "plus", style: .dashed)
            ChipLabel("Technique")
            Spacer()
        }
        MetaLine([Text("Push"), Text("\(21) min"), Text("Beginner")])
    }
}
