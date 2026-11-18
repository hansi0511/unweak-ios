import SwiftUI

/// One field of a segmented choice: 44 pt high, Inter 15, accent surface when selected.
struct SegmentButton: View {
    @Environment(\.accent) private var accent
    private let title: LocalizedStringKey
    private let isSelected: Bool
    private let action: () -> Void

    init(_ title: LocalizedStringKey, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.text(15))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isSelected ? Theme.onAccent : Theme.textSoft)
                .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                .background(isSelected ? accent.color : Theme.surface)
                .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.line, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    AccentPreview { _ in
        HStack(spacing: 6) {
            SegmentButton("Body", isSelected: true) {}
            SegmentButton("Colors", isSelected: false) {}
            SegmentButton("Extras", isSelected: false) {}
        }
    }
}
