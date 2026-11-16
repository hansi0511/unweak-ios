import SwiftUI

/// Progress shown as separate segments instead of a continuous bar.
struct SegmentedProgress: View {
    @Environment(\.accent) private var accent

    private let total: Int
    private let filled: Int
    private let height: CGFloat
    private let label: LocalizedStringKey

    /// - Parameter height: Segment height, clamped to 4...8 pt.
    init(total: Int, filled: Int, height: CGFloat = 6, label: LocalizedStringKey) {
        self.total = total
        self.filled = filled
        self.height = height
        self.label = label
    }

    private var clampedFilled: Int { min(max(filled, 0), max(total, 0)) }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                Rectangle()
                    .fill(index < clampedFilled ? accent.color : Theme.line)
                    .frame(height: min(max(height, 4), 8))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(Text("\(clampedFilled) of \(total)"))
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        VStack(spacing: 12) {
            SegmentedProgress(total: 5, filled: 2, label: "Stage")
            SegmentedProgress(total: 4, filled: 3, height: 8, label: "Sets")
        }
    }
}
