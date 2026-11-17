import SwiftUI

/// Animated Sticky Man performing an exercise in a loop. Scales to the space it is given.
/// With "Reduce Motion" on, the animation stops and the end pose is shown.
struct StickyManView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let animation: StickyAnimation

    init(_ animation: StickyAnimation) {
        self.animation = animation
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { timeline in
            let progress = reduceMotion ? animation.endPoseProgress : animation.progress(at: timeline.date)
            StickyFigureCanvas(figure: animation.figure(at: progress))
        }
        .aspectRatio(animation.canvas.width / animation.canvas.height, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel(Text(animation.accessibilityName))
        .accessibilityAddTraits(.isImage)
    }
}

/// Small static pose for list rows (48 x 48).
struct StickyPoseView: View {
    private let pose: StickyPose
    private let highlighted: Bool

    /// - Parameter highlighted: Accent color with glow; otherwise text color.
    init(_ pose: StickyPose, highlighted: Bool = true) {
        self.pose = pose
        self.highlighted = highlighted
    }

    var body: some View {
        StickyFigureCanvas(figure: pose.figure, highlighted: highlighted)
            .frame(width: StickyPose.canvas.width, height: StickyPose.canvas.height)
            .accessibilityElement()
            .accessibilityLabel(Text(pose.accessibilityName))
            .accessibilityAddTraits(.isImage)
    }
}

/// Draws a `StickyFigure`, scaled and centered in the available space.
struct StickyFigureCanvas: View {
    @Environment(\.accent) private var accent
    private let figure: StickyFigure
    private let highlighted: Bool

    init(figure: StickyFigure, highlighted: Bool = true) {
        self.figure = figure
        self.highlighted = highlighted
    }

    var body: some View {
        let figure = figure
        let color = highlighted ? accent.color : Theme.text
        let glow = highlighted ? accent.color.opacity(Theme.Glow.opacity) : Color.clear

        Canvas { context, size in
            let scale = min(size.width / figure.canvas.width, size.height / figure.canvas.height)
            let offsetX = (size.width - figure.canvas.width * scale) / 2
            let offsetY = (size.height - figure.canvas.height * scale) / 2
            context.translateBy(x: offsetX, y: offsetY)
            context.scaleBy(x: scale, y: scale)

            for segment in figure.apparatus {
                context.stroke(
                    segment.path,
                    with: .color(Theme.text),
                    style: StrokeStyle(lineWidth: segment.width, lineCap: .round)
                )
            }

            if let guide = figure.guide {
                context.stroke(
                    guide.path,
                    with: .color(color.opacity(figure.guideOpacity)),
                    style: StrokeStyle(lineWidth: guide.width, lineCap: .round, dash: [4, 4])
                )
            }

            context.drawLayer { layer in
                layer.addFilter(.shadow(color: glow, radius: Theme.Glow.small))
                for segment in figure.limbs {
                    layer.stroke(
                        segment.path,
                        with: .color(color),
                        style: StrokeStyle(lineWidth: segment.width, lineCap: .round, lineJoin: .round)
                    )
                }
                let head = Path(ellipseIn: CGRect(
                    x: figure.head.x - figure.headRadius,
                    y: figure.head.y - figure.headRadius,
                    width: figure.headRadius * 2,
                    height: figure.headRadius * 2
                ))
                layer.fill(head, with: .color(Theme.surface))
                layer.stroke(head, with: .color(color), lineWidth: figure.limbs.first?.width ?? 3)
            }
        }
        .accessibilityHidden(true)
    }
}

extension StickySegment {
    var path: Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

#Preview("Animations, all accents") {
    AccentPreview { _ in
        HStack(spacing: 12) {
            HUDPanel(padding: 8) { StickyManView(.frontLever) }
            HUDPanel(padding: 8) { StickyManView(.pullUp) }
        }
        .frame(height: 160)
    }
}

#Preview("Poses") {
    AccentPreview { _ in
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(48), spacing: 12), count: 5), spacing: 12) {
            ForEach(StickyPose.allCases, id: \.self) { pose in
                StickyPoseView(pose)
            }
            StickyPoseView(.plank, highlighted: false)
        }
    }
}

/// The poses shown when "Reduce Motion" is on.
#Preview("End poses") {
    HStack(spacing: 12) {
        ForEach(StickyAnimation.allCases, id: \.self) { animation in
            StickyFigureCanvas(figure: animation.figure(at: animation.endPoseProgress))
        }
    }
    .frame(height: 180)
    .padding(Theme.Layout.screenEdge)
    .background(Theme.background)
}
