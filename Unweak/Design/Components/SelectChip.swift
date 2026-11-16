import SwiftUI

/// Selectable field for filters, weekdays and language: 44 pt high,
/// accent surface when selected, strong line otherwise.
struct SelectChip: View {
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
                .font(.monoBold)
                .tracking(1)
                .textCase(.uppercase)
                .lineLimit(1)
                .foregroundStyle(isSelected ? Theme.onAccent : Theme.textSoft)
                .padding(.horizontal, 14)
                .frame(minWidth: Theme.Layout.minTouchTarget, minHeight: Theme.Layout.selectHeight)
                .background(isSelected ? accent.color : Color.clear)
                .overlay(Rectangle().strokeBorder(isSelected ? accent.color : Theme.lineStrong, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        HStack(spacing: 8) {
            SelectChip("All", isSelected: true) {}
            SelectChip("Push", isSelected: false) {}
            SelectChip("Pull", isSelected: false) {}
        }
    }
}
