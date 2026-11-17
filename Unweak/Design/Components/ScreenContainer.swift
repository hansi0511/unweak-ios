import SwiftUI

/// Scrollable screen frame: dark background, 20 pt side margin, block spacing,
/// system navigation bar hidden (screens draw their own header and back button).
struct ScreenContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Layout.blockSpacing) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Layout.screenEdge)
            .padding(.top, 12)
            .padding(.bottom, Theme.Layout.blockSpacing)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
