import SwiftUI

/// Surface with a 1 pt line. Square corners.
struct Card<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }
}

#Preview {
    Card {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: "Push Basics").font(.textSemibold(17)).foregroundStyle(Theme.text)
            MonoLabel(verbatim: "Push · 25 min · Beginner")
        }
    }
    .padding(Theme.Layout.screenEdge)
    .frame(maxHeight: .infinity)
    .background(Theme.background)
}
