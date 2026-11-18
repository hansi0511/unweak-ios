import SwiftUI

/// Image or video of the share card.
enum ShareMedia: String, CaseIterable, Identifiable {
    /// Short MP4 loop with the moving Sticky Man.
    case video
    /// Still image with Sticky Man in the key pose.
    case image

    var id: Self { self }
}

/// Share (Design V2, `V2-Teilen`): preview of the share card as video or image (Story format),
/// then the iOS share sheet (X, Facebook, Instagram and everything else installed).
struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accent) private var accent
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var media: ShareMedia = .video
    /// Always Story in Design V2; Post stays available in code for a later decision.
    private let format: ShareFormat = .story
    @State private var image: UIImage?
    @State private var videoURL: URL?
    @State private var videoProgress = 0.0
    @State private var renderFailed = false
    private let content: ShareContent

    /// Width of the on-screen preview; image and video are rendered at full size.
    private let previewWidth: CGFloat = 290

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
            HStack(spacing: 14) {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Text("Share")
                    .font(.grotesk(26))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }

            HStack(spacing: 0) {
                SegmentButton("Video", isSelected: media == .video) { media = .video }
                SegmentButton("Image", isSelected: media == .image) { media = .image }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("Kind"))

            preview
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            shareButton
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
            Text("The file could not be created. Try the image instead.")
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
                shareLabel("Share")
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
                shareLabel("Share")
            }
            .buttonStyle(PressFeedbackStyle())
            .glow(accent.color, radius: Theme.Glow.medium)
        } else {
            VStack(spacing: 8) {
                if media == .video {
                    SegmentedProgress(total: 10, filled: Int(videoProgress * 10), label: "Creating video")
                    Text("Creating video …")
                        .font(.text(14))
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
