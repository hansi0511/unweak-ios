import SwiftUI

/// Card with a grid background and four accent corner marks.
struct HUDPanel<Content: View>: View {
    @Environment(\.accent) private var accent
    private let padding: CGFloat
    private let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    Theme.surface
                    GridBackground()
                }
                .accessibilityHidden(true)
            }
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
            .overlay {
                CornerMarks()
                    .stroke(accent.color, lineWidth: Theme.Layout.cornerMarkWidth)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .contain)
    }
}

/// Thin grid lines every 24 pt.
struct GridBackground: View {
    var spacing: CGFloat = Theme.Layout.gridSpacing

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var x = spacing
            while x < size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y = spacing
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.stroke(path, with: .color(Theme.surfaceSelected), lineWidth: 1)
        }
    }
}

/// Two L-shaped marks, top left and bottom right (Design V2: only on the most important
/// card of a screen), drawn inside the rect's bounds.
struct DiagonalCornerMarks: Shape {
    var length: CGFloat = 16
    var lineWidth: CGFloat = Theme.Layout.cornerMarkWidth

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        var path = Path()
        path.move(to: CGPoint(x: r.minX, y: r.minY + length))
        path.addLine(to: CGPoint(x: r.minX, y: r.minY))
        path.addLine(to: CGPoint(x: r.minX + length, y: r.minY))
        path.move(to: CGPoint(x: r.maxX, y: r.maxY - length))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX - length, y: r.maxY))
        return path
    }
}

/// Four L-shaped marks in the corners of the rect, drawn inside its bounds.
struct CornerMarks: Shape {
    var length: CGFloat = Theme.Layout.cornerMarkLength
    var lineWidth: CGFloat = Theme.Layout.cornerMarkWidth

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        var path = Path()
        // Top left
        path.move(to: CGPoint(x: r.minX, y: r.minY + length))
        path.addLine(to: CGPoint(x: r.minX, y: r.minY))
        path.addLine(to: CGPoint(x: r.minX + length, y: r.minY))
        // Top right
        path.move(to: CGPoint(x: r.maxX - length, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY + length))
        // Bottom right
        path.move(to: CGPoint(x: r.maxX, y: r.maxY - length))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX - length, y: r.maxY))
        // Bottom left
        path.move(to: CGPoint(x: r.minX + length, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.maxY - length))
        return path
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        HUDPanel {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel("Next goal")
                Text(verbatim: "Front Lever").font(.screenTitle).foregroundStyle(Theme.text)
                SegmentedProgress(total: 5, filled: 2, label: "Stage")
            }
        }
    }
}
