import SwiftUI

/// Preview of the share image with a choice of format, then the iOS share sheet
/// (X, Facebook, Instagram and everything else installed).
struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @State private var format: ShareFormat = .story
    @State private var image: UIImage?
    private let content: ShareContent

    /// Width of the on-screen preview; the image itself is rendered at full size.
    private let previewWidth: CGFloat = 250

    init(content: ShareContent) {
        self.content = content
    }

    var body: some View {
        let scale = previewWidth / format.size.width

        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
            }
            Text("Share")
                .font(.screenTitle)
                .foregroundStyle(Theme.text)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 8) {
                SelectChip("Story", isSelected: format == .story, expands: true) {
                    format = .story
                }
                SelectChip("Post", isSelected: format == .post, expands: true) {
                    format = .post
                }
            }

            ShareCardView(content: content, format: format)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: previewWidth, height: format.size.height * scale, alignment: .topLeading)
                .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                if let image {
                    let picture = Image(uiImage: image)
                    ShareLink(
                        item: picture,
                        subject: Text(verbatim: "Unweak"),
                        message: Text("My progress with Unweak. #unweak #calisthenics"),
                        preview: SharePreview(Text(verbatim: "Unweak"), image: picture)
                    ) {
                        HStack(spacing: 10) {
                            Text("Share image")
                                .font(.buttonTitle)
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(Theme.onAccent)
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
                        .background(accent.color)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressFeedbackStyle())
                    .glow(accent.color, radius: Theme.Glow.medium)
                } else {
                    ProgressView()
                        .tint(Theme.text)
                        .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
                }
                Text("Choose X, Facebook or Instagram in the next step. Story fits Instagram and Facebook stories, Post fits the feed.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .presentationBackground(Theme.background)
        .task(id: format) {
            render()
        }
    }

    /// Renders the card at full size (1080 px wide) with the current accent and language.
    private func render() {
        let card = ShareCardView(content: content, format: format)
            .environment(\.accent, accent)
            .environment(\.locale, locale)
        let renderer = ImageRenderer(content: card)
        renderer.scale = ShareFormat.renderScale
        image = renderer.uiImage
    }
}

#Preview {
    ShareSheet(content: .achievement(Catalog.main.achievements[0]))
}

#Preview("German") {
    ShareSheet(content: .streak(ShareContent.Streak(weeks: 3, workoutsThisWeek: 2, target: 3, days: [true, true, false, false, false, false, false])))
        .environment(\.locale, Locale(identifier: "de"))
}
