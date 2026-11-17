import SwiftUI

/// Renders its content once per accent color. Used by Xcode Previews to check
/// every component against all six accents at a glance.
struct AccentPreview<Content: View>: View {
    private let content: (Accent) -> Content

    init(@ViewBuilder content: @escaping (Accent) -> Content) {
        self.content = content
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Layout.blockSpacing) {
                ForEach(Accent.allCases) { accent in
                    VStack(alignment: .leading, spacing: 8) {
                        MonoLabel(verbatim: accent.rawValue)
                        content(accent)
                    }
                    .environment(\.accent, accent)
                }
            }
            .padding(Theme.Layout.screenEdge)
        }
        .background(Theme.background)
    }
}
