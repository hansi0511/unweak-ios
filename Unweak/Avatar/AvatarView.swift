import SwiftUI

private func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

/// One drawing element of the avatar on its 100 x 100 grid.
enum AvatarShape: Equatable, Sendable {
    case line(CGPoint, CGPoint, width: CGFloat)
    /// Quadratic curve from `from` through `control` to `to`.
    case curve(CGPoint, control: CGPoint, CGPoint, width: CGFloat)
    /// Filled dot, e.g. a fist.
    case dot(CGPoint, radius: CGFloat)
    /// Closed outline; `fillOpacity` > 0 also fills it in the line color.
    case polygon([CGPoint], width: CGFloat, fillOpacity: Double)
    /// Upper half of a circle, filled (cap).
    case dome(center: CGPoint, radius: CGFloat)
    /// Arc over the top of a circle (headphone band).
    case band(center: CGPoint, radius: CGFloat, width: CGFloat)
    case rect(CGRect)

    /// Every point the shape touches, for bounds checks.
    var points: [CGPoint] {
        switch self {
        case .line(let a, let b, _): [a, b]
        case .curve(let a, let c, let b, _): [a, c, b]
        case .dot(let c, let r): [CGPoint(x: c.x - r, y: c.y - r), CGPoint(x: c.x + r, y: c.y + r)]
        case .polygon(let points, _, _): points
        case .dome(let c, let r), .band(let c, let r, _): [CGPoint(x: c.x - r, y: c.y - r), CGPoint(x: c.x + r, y: c.y)]
        case .rect(let rect): [CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)]
        }
    }
}

/// The avatar's geometry for a body and an optional extra, on a 100 x 100 grid.
struct AvatarFigure: Equatable, Sendable {
    static let size: CGFloat = 100

    let head: CGPoint
    let headRadius: CGFloat
    let lineWidth: CGFloat
    let body: [AvatarShape]
    let extra: [AvatarShape]
    let glows: Bool

    init(body kind: AvatarBody, extra: AvatarExtra?) {
        switch kind {
        case .start:
            head = p(50, 24); headRadius = 6.5; lineWidth = 3
            body = [
                .line(p(50, 30.5), p(50, 63), width: 3),
                .line(p(50, 38), p(40, 55), width: 3),
                .line(p(50, 38), p(60, 55), width: 3),
                .line(p(50, 63), p(42, 88), width: 3),
                .line(p(50, 63), p(58, 88), width: 3),
            ]
        case .athlete:
            head = p(50, 22); headRadius = 7; lineWidth = 3.6
            body = [
                .line(p(50, 29), p(50, 63), width: 3.6),
                .line(p(42, 38), p(58, 38), width: 3.6),
                .line(p(42, 38), p(33, 22), width: 3.6),
                .line(p(58, 38), p(67, 22), width: 3.6),
                .line(p(50, 63), p(41, 88), width: 3.6),
                .line(p(50, 63), p(59, 88), width: 3.6),
            ]
        case .trained, .legend:
            head = p(50, 21); headRadius = 8; lineWidth = 4.6
            body = [
                .line(p(50, 29), p(50, 38), width: 4.6),
                .polygon([p(36, 38), p(64, 38), p(50, 64)], width: 4.6, fillOpacity: 0.3),
                .curve(p(36, 38), control: p(24, 36), p(25, 24), width: 4.6),
                .curve(p(64, 38), control: p(76, 36), p(75, 24), width: 4.6),
                .dot(p(25, 22), radius: 3.2),
                .dot(p(75, 22), radius: 3.2),
                .curve(p(50, 64), control: p(38, 70), p(40, 89), width: 4.6),
                .curve(p(50, 64), control: p(62, 70), p(60, 89), width: 4.6),
            ]
        }
        glows = kind == .legend
        let (center, radius) = (head, headRadius)
        self.extra = extra.map { Self.shapes(for: $0, head: center, radius: radius) } ?? []
    }

    /// Extras sit relative to the head, so they fit every body.
    private static func shapes(for extra: AvatarExtra, head h: CGPoint, radius r: CGFloat) -> [AvatarShape] {
        switch extra {
        case .headband:
            return [
                .line(p(h.x - r, h.y - r * 0.35), p(h.x + r, h.y - r * 0.55), width: 2.6),
                .line(p(h.x + r, h.y - r * 0.55), p(h.x + r + 6, h.y - r * 0.1), width: 2),
            ]
        case .cap:
            return [
                .dome(center: h, radius: r + 1.2),
                .line(p(h.x, h.y - r * 0.15), p(h.x + r + 6, h.y - r * 0.15), width: 2.6),
            ]
        case .visor:
            return [.line(p(h.x - r - 0.5, h.y - 0.5), p(h.x + r + 0.5, h.y - 0.5), width: 3.2)]
        case .headphones:
            return [
                .band(center: h, radius: r + 2.5, width: 2.2),
                .rect(CGRect(x: h.x - r - 4, y: h.y - 2.5, width: 5, height: 6)),
                .rect(CGRect(x: h.x + r - 1, y: h.y - 2.5, width: 5, height: 6)),
            ]
        case .medal:
            return [
                .line(p(h.x - 5, h.y + r + 2), p(h.x, h.y + r + 10), width: 1.8),
                .line(p(h.x + 5, h.y + r + 2), p(h.x, h.y + r + 10), width: 1.8),
                .dot(p(h.x, h.y + r + 12), radius: 2.8),
            ]
        case .crown:
            let top = h.y - r
            return [.polygon([
                p(h.x - r, top - 1.5), p(h.x - r, top - 8), p(h.x - r / 2, top - 4.5), p(h.x, top - 10),
                p(h.x + r / 2, top - 4.5), p(h.x + r, top - 8), p(h.x + r, top - 1.5),
            ], width: 1, fillOpacity: 1)]
        }
    }
}

/// The user's avatar: figure, extra and background with corner marks. Static, so it
/// needs no special handling for "Reduce Motion".
struct AvatarView: View {
    private let style: AvatarStyle
    private let avatarBody: AvatarBody
    private let extra: AvatarExtra?

    /// - Parameters:
    ///   - body: The body to draw (already resolved against the unlocks).
    ///   - extra: The extra to draw (already resolved against the unlocks).
    init(style: AvatarStyle, body: AvatarBody, extra: AvatarExtra?) {
        self.style = style
        self.avatarBody = body
        self.extra = extra
    }

    private static let night = Color(hex: 0x1E1733)

    var body: some View {
        let figure = AvatarFigure(body: avatarBody, extra: extra)
        let inverted = style.background == .inverted
        let figureColor = inverted ? Theme.onAccent : style.color.color
        let background: Color = switch style.background {
        case .dark: Theme.surface
        case .night: Self.night
        case .inverted: style.color.color
        }

        Canvas { context, size in
            let scale = min(size.width, size.height) / AvatarFigure.size
            context.translateBy(
                x: (size.width - AvatarFigure.size * scale) / 2,
                y: (size.height - AvatarFigure.size * scale) / 2
            )
            context.scaleBy(x: scale, y: scale)

            context.drawLayer { layer in
                if figure.glows {
                    layer.addFilter(.shadow(color: figureColor.opacity(0.6), radius: 4))
                }
                for shape in figure.body {
                    Self.draw(shape, color: figureColor, in: &layer)
                }
                let head = Path(ellipseIn: CGRect(
                    x: figure.head.x - figure.headRadius,
                    y: figure.head.y - figure.headRadius,
                    width: figure.headRadius * 2,
                    height: figure.headRadius * 2
                ))
                layer.fill(head, with: .color(background))
                layer.stroke(head, with: .color(figureColor), lineWidth: figure.lineWidth)
            }
            for shape in figure.extra {
                Self.draw(shape, color: style.extraColor.color, in: &context)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(background)
        .overlay {
            if !inverted {
                AvatarCornerMarks()
                    .stroke(style.color.color, lineWidth: Theme.Layout.cornerMarkWidth)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Avatar"))
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isImage)
    }

    private var accessibilityValue: Text {
        let base = Text("\(Text(avatarBody.name)), \(Text(style.color.name))")
        guard let extra else { return base }
        return Text("\(base), \(Text(extra.name))")
    }

    private static func draw(_ shape: AvatarShape, color: Color, in context: inout GraphicsContext) {
        let round = { (width: CGFloat) in StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round) }
        switch shape {
        case .line(let a, let b, let width):
            var path = Path()
            path.move(to: a)
            path.addLine(to: b)
            context.stroke(path, with: .color(color), style: round(width))
        case .curve(let a, let control, let b, let width):
            var path = Path()
            path.move(to: a)
            path.addQuadCurve(to: b, control: control)
            context.stroke(path, with: .color(color), style: round(width))
        case .dot(let center, let radius):
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(color)
            )
        case .polygon(let points, let width, let fillOpacity):
            var path = Path()
            path.addLines(points)
            path.closeSubpath()
            if fillOpacity > 0 {
                context.fill(path, with: .color(color.opacity(fillOpacity)))
            }
            context.stroke(path, with: .color(color), style: round(width))
        case .dome(let center, let radius):
            var path = Path()
            path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            path.closeSubpath()
            context.fill(path, with: .color(color))
        case .band(let center, let radius, let width):
            var path = Path()
            path.addArc(center: center, radius: radius, startAngle: .degrees(185), endAngle: .degrees(355), clockwise: false)
            context.stroke(path, with: .color(color), style: round(width))
        case .rect(let rect):
            context.fill(Path(rect), with: .color(color))
        }
    }
}

/// Corner marks top left and bottom right, as in the avatar mockup.
private struct AvatarCornerMarks: Shape {
    func path(in rect: CGRect) -> Path {
        let length = Theme.Layout.cornerMarkLength * min(1, rect.width / 140)
        let r = rect.insetBy(dx: Theme.Layout.cornerMarkWidth / 2, dy: Theme.Layout.cornerMarkWidth / 2)
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

#Preview("Bodies and extras") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(AvatarBody.allCases) { body in
                AvatarView(style: AvatarStyle(), body: body, extra: nil)
            }
            ForEach(AvatarExtra.allCases) { extra in
                AvatarView(style: AvatarStyle(color: .violet, extraColor: .lime), body: .trained, extra: extra)
            }
            AvatarView(style: AvatarStyle(background: .inverted), body: .athlete, extra: nil)
            AvatarView(style: AvatarStyle(color: .pink, extraColor: .violet, background: .night), body: .athlete, extra: .headband)
            AvatarView(style: AvatarStyle(color: .mono, extraColor: .lime), body: .athlete, extra: .medal)
        }
        .padding(Theme.Layout.screenEdge)
    }
    .background(Theme.background)
}
