import CoreGraphics
import Foundation

/// Side-view skeleton used by most exercise animations. A pose is given by the hip
/// position, segment angles and, for hands or feet that touch the floor or a bar,
/// pinned end points whose middle joint (elbow, knee) is solved from the bone lengths.
///
/// Angles are in degrees in canvas coordinates: 0° points right, 90° down, −90° up.
enum StickyBody {
    static let neck: CGFloat = 14
    static let torso: CGFloat = 42
    static let upperArm: CGFloat = 22
    static let forearm: CGFloat = 21
    static let thigh: CGFloat = 24
    static let shin: CGFloat = 23

    /// Opacity of the far arm and leg, so the side view keeps some depth.
    static let farLimbOpacity = 0.5
}

/// Which way a solved middle joint bends, as the sign of the cross product
/// of (root → end) and (root → joint).
enum StickyBend: Sendable {
    case positive
    case negative
}

/// One arm or leg of a `BodyPose`.
enum LimbPose: Sendable, Equatable {
    /// Upper and lower segment angles in degrees.
    case angles(Double, Double)
    /// End point (hand or foot) fixed at a position; the middle joint is solved.
    case pinned(CGPoint, StickyBend)
}

struct BodyPose: Sendable, Equatable {
    var hip: CGPoint
    /// Direction from hip to shoulder.
    var torso: Double
    /// Direction from shoulder to head center.
    var neck: Double
    /// Near arm first, then far arm.
    var arms: [LimbPose]
    /// Near leg first, then far leg.
    var legs: [LimbPose]
}

/// Solved joint positions of a `BodyPose`.
struct BodyJoints: Equatable {
    struct Limb: Equatable {
        var root: CGPoint
        var middle: CGPoint
        var end: CGPoint
    }

    var hip: CGPoint
    var shoulder: CGPoint
    var head: CGPoint
    var arms: [Limb]
    var legs: [Limb]
}

extension CGPoint {
    /// The point `length` units away in direction `degrees`.
    func moved(degrees: Double, length: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(x: x + length * CGFloat(cos(radians)), y: y + length * CGFloat(sin(radians)))
    }
}

extension StickyGeometry {
    /// Middle joint of a two-bone limb from `root` to `end`. If `end` is out of reach,
    /// the limb is stretched towards it.
    static func joint(
        root: CGPoint,
        end: CGPoint,
        first: CGFloat,
        second: CGFloat,
        bend: StickyBend
    ) -> CGPoint {
        let dx = end.x - root.x
        let dy = end.y - root.y
        let fullDistance = (dx * dx + dy * dy).squareRoot()
        guard fullDistance > 0 else { return root.offsetBy(dy: first) }

        let ux = dx / fullDistance
        let uy = dy / fullDistance
        // Keep the distance inside the range the two bones can form, so the
        // solution stays finite when root and end almost meet.
        let distance = max(min(fullDistance, first + second), abs(first - second), 0.000001)
        let along = (first * first - second * second + distance * distance) / (2 * distance)
        let across = max(first * first - along * along, 0).squareRoot()
        let base = CGPoint(x: root.x + ux * along, y: root.y + uy * along)

        let candidate = CGPoint(x: base.x - uy * across, y: base.y + ux * across)
        let other = CGPoint(x: base.x + uy * across, y: base.y - ux * across)
        let cross = dx * (candidate.y - root.y) - dy * (candidate.x - root.x)
        switch bend {
        case .positive: return cross >= 0 ? candidate : other
        case .negative: return cross >= 0 ? other : candidate
        }
    }
}

extension BodyPose {
    func solved() -> BodyJoints {
        let shoulder = hip.moved(degrees: torso, length: StickyBody.torso)
        let head = shoulder.moved(degrees: neck, length: StickyBody.neck)
        return BodyJoints(
            hip: hip,
            shoulder: shoulder,
            head: head,
            arms: arms.map { Self.solve($0, root: shoulder, first: StickyBody.upperArm, second: StickyBody.forearm) },
            legs: legs.map { Self.solve($0, root: hip, first: StickyBody.thigh, second: StickyBody.shin) }
        )
    }

    private static func solve(_ limb: LimbPose, root: CGPoint, first: CGFloat, second: CGFloat) -> BodyJoints.Limb {
        switch limb {
        case let .angles(upper, lower):
            let middle = root.moved(degrees: upper, length: first)
            return .init(root: root, middle: middle, end: middle.moved(degrees: lower, length: second))
        case let .pinned(end, bend):
            let reach = root.distance(to: end)
            if reach > first + second {
                let degrees = atan2(Double(end.y - root.y), Double(end.x - root.x)) * 180 / .pi
                return .init(
                    root: root,
                    middle: root.moved(degrees: degrees, length: first),
                    end: root.moved(degrees: degrees, length: first + second)
                )
            }
            let middle = StickyGeometry.joint(root: root, end: end, first: first, second: second, bend: bend)
            return .init(root: root, middle: middle, end: end)
        }
    }

    /// Blends two poses; `fraction` 0 gives `self`, 1 gives `other`.
    func interpolated(to other: BodyPose, fraction f: Double) -> BodyPose {
        BodyPose(
            hip: Self.mix(hip, other.hip, f),
            torso: Self.mix(torso, other.torso, f),
            neck: Self.mix(neck, other.neck, f),
            arms: zip(arms, other.arms).map { Self.mix($0, $1, f) },
            legs: zip(legs, other.legs).map { Self.mix($0, $1, f) }
        )
    }

    private static func mix(_ a: Double, _ b: Double, _ f: Double) -> Double { a + (b - a) * f }

    private static func mix(_ a: CGPoint, _ b: CGPoint, _ f: Double) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * CGFloat(f), y: a.y + (b.y - a.y) * CGFloat(f))
    }

    private static func mix(_ a: LimbPose, _ b: LimbPose, _ f: Double) -> LimbPose {
        switch (a, b) {
        case let (.angles(a1, a2), .angles(b1, b2)):
            return .angles(mix(a1, b1, f), mix(a2, b2, f))
        case let (.pinned(p, bend), .pinned(q, _)):
            return .pinned(mix(p, q, f), bend)
        default:
            return f < 0.5 ? a : b
        }
    }
}

/// A looping animation made of key poses. Each step between two keys is eased.
struct BodyAnimation: Sendable {
    struct Key: Sendable {
        let time: Double
        let pose: BodyPose
    }

    let canvas: CGSize
    let duration: TimeInterval
    /// Progress of the pose shown when "Reduce Motion" is on.
    let endPoseProgress: Double
    let apparatus: [StickySegment]
    let keys: [Key]

    func pose(at progress: Double) -> BodyPose {
        guard let first = keys.first, let last = keys.last else {
            preconditionFailure("BodyAnimation needs at least one key")
        }
        let t = min(max(progress, 0), 1)
        if t <= first.time { return first.pose }
        if t >= last.time { return last.pose }
        for index in 1..<keys.count {
            let start = keys[index - 1]
            let end = keys[index]
            guard t <= end.time else { continue }
            let span = end.time - start.time
            guard span > 0 else { return end.pose }
            let f = (t - start.time) / span
            return start.pose.interpolated(to: end.pose, fraction: f * f * (3 - 2 * f))
        }
        return last.pose
    }

    func figure(at progress: Double) -> StickyFigure {
        let joints = pose(at: progress).solved()
        let w = StickyStyle.bodyWidth
        let arm = StickyStyle.armWidth
        let far = StickyBody.farLimbOpacity

        func limb(_ l: BodyJoints.Limb, width: CGFloat, opacity: Double) -> [StickySegment] {
            [
                StickySegment(from: l.root, to: l.middle, width: width, opacity: opacity),
                StickySegment(from: l.middle, to: l.end, width: width, opacity: opacity),
            ]
        }

        // Far limbs first so the near side is drawn on top.
        var limbs: [StickySegment] = []
        for (index, a) in joints.arms.enumerated() where index > 0 { limbs += limb(a, width: arm, opacity: far) }
        for (index, l) in joints.legs.enumerated() where index > 0 { limbs += limb(l, width: w, opacity: far) }
        limbs.append(StickySegment(from: joints.hip, to: joints.shoulder, width: w))
        if let leg = joints.legs.first { limbs += limb(leg, width: w, opacity: 1) }
        if let a = joints.arms.first { limbs += limb(a, width: arm, opacity: 1) }

        return StickyFigure(
            canvas: canvas,
            head: joints.head,
            headRadius: StickyStyle.headRadius,
            limbs: limbs,
            apparatus: apparatus
        )
    }
}
