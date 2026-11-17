import SwiftUI

/// Image or video of the share card.
enum ShareMedia: String, CaseIterable, Identifiable {
    /// Short MP4 loop with the moving Sticky Man.
    case video
    /// Still image with Sticky Man in the key pose.
    case image

    var id: Self { self }
}

/// Preview of the share card with a choice of video or image and of format, then the
/// iOS share sheet (X, Facebook, Instagram and everything else installed).
struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var media: ShareMedia = .video
    @State private var format: ShareFormat = .story
    @State private var image: UIImage?
    @State private var videoURL: URL?
    @State private var videoProgress = 0.0
    @State private var renderFailed = false
    private let content: ShareContent

    /// Width of the on-screen preview; image and video are rendered at full size.
    private let previewWidth: CGFloat = 250

    init(content: ShareContent) {
        self.content = content
    }

    /// What has to be rendered again when it changes.
    private struct RenderKey: Equatable {
        let media: ShareMedia
        let format: ShareFormat
    }

    var body: some View {
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

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    SelectChip("Video", isSelected: media == .video, expands: true) { media = .video }
                    SelectChip("Image", isSelected: media == .image, expands: true) { media = .image }
                }
                HStack(spacing: 8) {
                    SelectChip("Story", isSelected: format == .story, expands: true) { format = .story }
                    SelectChip("Post", isSelected: format == .post, expands: true) { format = .post }
                }
            }

            preview
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                shareButton
                Text("Choose X, Facebook or Instagram in the next step. Story fits Instagram and Facebook stories, Post fits the feed.")
                    .font(.text(13))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .presentationBackground(Theme.background)
        .task(id: RenderKey(media: media, format: format)) {
            await render()
        }
    }

    // MARK: Preview

    private var preview: some View {
        let scale = previewWidth / format.size.width
        return Group {
            if media == .video && !reduceMotion {
                TimelineView(.animation) { timeline in
                    card(progress: content.animation.progress(at: timeline.date))
                }
            } else {
                card(progress: nil)
            }
        }
        .scaleEffect(scale, anchor: .topLeading)
        .frame(width: previewWidth, height: format.size.height * scale, alignment: .topLeading)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }

    private func card(progress: Double?) -> some View {
        ShareCardView(content: content, format: format, progress: progress)
    }

    // MARK: Sharing

    @ViewBuilder
    private var shareButton: some View {
        if renderFailed {
            Text("The file could not be created. Try the other format or the image.")
                .font(.text(13))
                .foregroundStyle(Theme.danger)
        } else if media == .video, let videoURL, let image {
            let still = Image(uiImage: image)
            ShareLink(
                item: videoURL,
                subject: Text(verbatim: "Unweak"),
                message: Text("My progress with Unweak. #unweak #calisthenics"),
                preview: SharePreview(Text(verbatim: "Unweak"), image: still)
            ) {
                shareLabel("Share video")
            }
            .buttonStyle(PressFeedbackStyle())
            .glow(accent.color, radius: Theme.Glow.medium)
        } else if media == .image, let image {
            let picture = Image(uiImage: image)
            ShareLink(
                item: picture,
                subject: Text(verbatim: "Unweak"),
                message: Text("My progress with Unweak. #unweak #calisthenics"),
                preview: SharePreview(Text(verbatim: "Unweak"), image: picture)
            ) {
                shareLabel("Share image")
            }
            .buttonStyle(PressFeedbackStyle())
            .glow(accent.color, radius: Theme.Glow.medium)
        } else {
            VStack(spacing: 8) {
                if media == .video {
                    SegmentedProgress(total: 10, filled: Int(videoProgress * 10), label: "Creating video")
                    Text("Creating video …")
                        .font(.mono)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.textMuted)
                } else {
                    ProgressView()
                        .tint(Theme.text)
                }
            }
            .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
        }
    }

    private func shareLabel(_ title: LocalizedStringKey) -> some View {
        HStack(spacing: 10) {
            Text(title)
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

    // MARK: Rendering

    /// Renders the still image (also the preview picture of the video) and, for video,
    /// the MP4 file, with the current accent and language.
    private func render() async {
        renderFailed = false
        image = nil
        videoURL = nil
        videoProgress = 0

        let still = ShareCardView(content: content, format: format)
            .environment(\.accent, accent)
            .environment(\.locale, locale)
        let renderer = ImageRenderer(content: still)
        renderer.scale = ShareFormat.renderScale
        image = renderer.uiImage

        guard media == .video else { return }
        do {
            let url = try await ShareVideoRenderer.render(
                content: content,
                format: format,
                accent: accent,
                locale: locale
            ) { value in
                videoProgress = value
            }
            if Task.isCancelled { return }
            videoURL = url
        } catch is CancellationError {
            return
        } catch {
            renderFailed = true
        }
    }
}

#Preview {
    ShareSheet(content: .achievement(Catalog.main.achievements[0]))
}

#Preview("German") {
    ShareSheet(content: .streak(ShareContent.Streak(weeks: 3, workoutsThisWeek: 2, target: 3, days: [true, true, false, false, false, false, false])))
        .environment(\.locale, Locale(identifier: "de"))
}
