import CoreGraphics

/// A straight line of the figure or of an apparatus, in canvas units.
struct StickySegment: Equatable, Sendable {
    var from: CGPoint
    var to: CGPoint
    var width: CGFloat

    var length: CGFloat { from.distance(to: to) }
}

/// One frame of Sticky Man: everything needed to draw it, as plain data.
/// Coordinates use the canvas units from `docs/DESIGN.md` (y grows downward).
struct StickyFigure: Equatable, Sendable {
    /// Size of the drawing area in canvas units. Views scale it to fit.
    var canvas: CGSize
    var head: CGPoint
    var headRadius: CGFloat
    /// Body lines, drawn in the accent color with glow.
    var limbs: [StickySegment]
    /// Apparatus such as the bar, drawn in the text color without glow.
    var apparatus: [StickySegment] = []
    /// Optional dashed target line (front lever) and its opacity (0...1).
    var guide: StickySegment?
    var guideOpacity: Double = 0
}

/// Stroke widths and head radii from `docs/DESIGN.md`.
enum StickyStyle {
    // Large figure (canvas about 160 to 200 units)
    static let bodyWidth: CGFloat = 5
    static let armWidth: CGFloat = 4.5
    static let headRadius: CGFloat = 8.5
    static let apparatusWidth: CGFloat = 3
    static let guideWidth: CGFloat = 1.5

    // Small list pose (48 x 48)
    static let poseWidth: CGFloat = 3
    static let poseHeadRadius: CGFloat = 4
}
