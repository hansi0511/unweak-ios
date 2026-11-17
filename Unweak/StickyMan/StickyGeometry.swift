import CoreGraphics
import Foundation

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return (dx * dx + dy * dy).squareRoot()
    }

    /// Rotates the point around `center` by `degrees`. With y pointing down,
    /// −90° turns a point below the center to its right (feet of the front lever).
    func rotated(around center: CGPoint, degrees: Double) -> CGPoint {
        let radians = degrees * .pi / 180
        let c = CGFloat(cos(radians))
        let s = CGFloat(sin(radians))
        let dx = x - center.x
        let dy = y - center.y
        return CGPoint(x: center.x + dx * c - dy * s, y: center.y + dx * s + dy * c)
    }

    func offsetBy(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }

    /// Mirrors the point at the vertical line `x = axis`.
    func mirrored(atX axis: CGFloat) -> CGPoint {
        CGPoint(x: 2 * axis - x, y: y)
    }
}

enum StickyGeometry {
    enum Side {
        /// Elbow towards smaller x (left arm bending outward).
        case left
        /// Elbow towards larger x (right arm bending outward).
        case right
    }

    /// Elbow position for an arm fixed at `hand` and `shoulder` with two bones of the
    /// given lengths. If the shoulder is out of reach, the arm is fully stretched.
    static func elbow(
        hand: CGPoint,
        shoulder: CGPoint,
        forearm: CGFloat,
        upperArm: CGFloat,
        bending side: Side
    ) -> CGPoint {
        let dx = shoulder.x - hand.x
        let dy = shoulder.y - hand.y
        let fullDistance = (dx * dx + dy * dy).squareRoot()
        guard fullDistance > 0 else { return hand.offsetBy(dy: forearm) }

        let ux = dx / fullDistance
        let uy = dy / fullDistance
        let reach = forearm + upperArm
        let distance = min(fullDistance, reach)

        // Distance from the hand to the foot of the elbow on the hand-shoulder line.
        let along = (forearm * forearm - upperArm * upperArm + distance * distance) / (2 * distance)
        let across = max(forearm * forearm - along * along, 0).squareRoot()
        let base = CGPoint(x: hand.x + ux * along, y: hand.y + uy * along)

        let first = CGPoint(x: base.x - uy * across, y: base.y + ux * across)
        let second = CGPoint(x: base.x + uy * across, y: base.y - ux * across)
        switch side {
        case .left: return first.x <= second.x ? first : second
        case .right: return first.x >= second.x ? first : second
        }
    }
}

/// Values over a normalized timeline (0...1), interpolated between key points.
struct Keyframes: Sendable {
    enum Curve: Sendable {
        case linear
        /// Slow start and end (smoothstep).
        case easeInOut
    }

    struct Key: Sendable {
        let time: Double
        let value: Double
    }

    private let keys: [Key]
    private let curve: Curve

    /// - Parameter keys: `(time, value)` pairs with ascending times in 0...1.
    init(_ keys: [(Double, Double)], curve: Curve = .linear) {
        self.keys = keys.map { Key(time: $0.0, value: $0.1) }.sorted { $0.time < $1.time }
        self.curve = curve
    }

    func value(at progress: Double) -> Double {
        guard let first = keys.first, let last = keys.last else { return 0 }
        let t = min(max(progress, 0), 1)
        if t <= first.time { return first.value }
        if t >= last.time { return last.value }

        for index in 1..<keys.count {
            let start = keys[index - 1]
            let end = keys[index]
            guard t <= end.time else { continue }
            let span = end.time - start.time
            guard span > 0 else { return end.value }
            let fraction = shaped((t - start.time) / span)
            return start.value + (end.value - start.value) * fraction
        }
        return last.value
    }

    private func shaped(_ fraction: Double) -> Double {
        switch curve {
        case .linear: fraction
        case .easeInOut: fraction * fraction * (3 - 2 * fraction)
        }
    }
}
