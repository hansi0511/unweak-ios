import CoreGraphics
import Foundation

/// The looping exercise animations. Each maps a progress value (0...1 over one loop)
/// to a `StickyFigure`, using the values in `docs/DESIGN.md`.
enum StickyAnimation: CaseIterable, Sendable {
    case frontLever
    case pullUp

    /// Length of one loop in seconds.
    var duration: TimeInterval {
        switch self {
        case .frontLever: FrontLeverAnimation.duration
        case .pullUp: PullUpAnimation.duration
        }
    }

    /// Progress of the pose shown when "Reduce Motion" is on.
    var endPoseProgress: Double {
        switch self {
        case .frontLever: FrontLeverAnimation.holdProgress
        case .pullUp: PullUpAnimation.topProgress
        }
    }

    var canvas: CGSize {
        switch self {
        case .frontLever: FrontLeverAnimation.canvas
        case .pullUp: PullUpAnimation.canvas
        }
    }

    func figure(at progress: Double) -> StickyFigure {
        switch self {
        case .frontLever: FrontLeverAnimation.figure(at: progress)
        case .pullUp: PullUpAnimation.figure(at: progress)
        }
    }

    /// Progress within the loop for a point in time.
    func progress(at date: Date) -> Double {
        let elapsed = date.timeIntervalSinceReferenceDate
        return elapsed.truncatingRemainder(dividingBy: duration) / duration
    }

    var accessibilityName: LocalizedStringResource {
        switch self {
        case .frontLever: "Front lever animation"
        case .pullUp: "Pull-up animation"
        }
    }
}

/// Front lever: head, torso and legs rotate around the shoulder from hanging (0°)
/// to horizontal (−90°, feet to the right). Canvas 160 x 160, bar at y = 24.
enum FrontLeverAnimation {
    static let canvas = CGSize(width: 160, height: 160)
    static let duration: TimeInterval = 6
    static let holdProgress = 0.6

    static let barY: CGFloat = 24
    static let leftHand = CGPoint(x: 55, y: 24)
    static let rightHand = CGPoint(x: 65, y: 24)
    static let shoulder = CGPoint(x: 60, y: 62)
    static let head = CGPoint(x: 60, y: 47)
    static let hip = CGPoint(x: 60, y: 106)
    static let feet = CGPoint(x: 60, y: 150)

    /// Opacity of the target line while hanging and while holding.
    static let guideOpacityHang = 0.25
    static let guideOpacityHold = 1.0

    /// 0–18 % hang, 18–42 % pull up, 42–80 % hold, 80–100 % lower.
    private static let angleKeys = Keyframes(
        [(0, 0), (0.18, 0), (0.42, -90), (0.80, -90), (1, 0)],
        curve: .easeInOut
    )

    /// Body angle in degrees: 0 (hang) to −90 (horizontal).
    static func angle(at progress: Double) -> Double {
        angleKeys.value(at: progress)
    }

    static func figure(at progress: Double) -> StickyFigure {
        let degrees = angle(at: progress)
        let turn: (CGPoint) -> CGPoint = { $0.rotated(around: shoulder, degrees: degrees) }
        let raised = abs(degrees) / 90
        let w = StickyStyle.bodyWidth
        let arm = StickyStyle.armWidth

        return StickyFigure(
            canvas: canvas,
            head: turn(head),
            headRadius: StickyStyle.headRadius,
            limbs: [
                StickySegment(from: leftHand, to: shoulder, width: arm),
                StickySegment(from: rightHand, to: shoulder, width: arm),
                StickySegment(from: shoulder, to: turn(hip), width: w),
                StickySegment(from: turn(hip), to: turn(feet), width: w),
            ],
            apparatus: [
                StickySegment(
                    from: CGPoint(x: 20, y: barY),
                    to: CGPoint(x: 100, y: barY),
                    width: StickyStyle.apparatusWidth
                ),
            ],
            guide: StickySegment(from: shoulder, to: CGPoint(x: 152, y: 62), width: StickyStyle.guideWidth),
            guideOpacity: guideOpacityHang + (guideOpacityHold - guideOpacityHang) * raised
        )
    }
}

/// Pull-up: hands fixed on the bar, the body rises by 28.35 units and the elbows
/// follow from the fixed arm lengths. Canvas 200 x 170, bar at y = 20.
enum PullUpAnimation {
    static let canvas = CGSize(width: 200, height: 170)
    static let duration: TimeInterval = 3
    static let topProgress = 0.55

    static let barY: CGFloat = 20
    static let centerX: CGFloat = 100
    static let leftHand = CGPoint(x: 80, y: 20)
    static let forearm: CGFloat = 25
    static let upperArm: CGFloat = 25

    // Positions at the bottom of the movement.
    static let leftShoulder = CGPoint(x: 88, y: 69.35)
    static let head = CGPoint(x: 100, y: 55)
    static let hip = CGPoint(x: 100, y: 112)
    static let leftFoot = CGPoint(x: 94, y: 150)

    static let maxLift: CGFloat = 28.35

    /// 0–15 % bottom, 32.5 % middle, 50–60 % top, 77.5 % middle, from 95 % bottom.
    private static let liftKeys = Keyframes([
        (0, 0), (0.15, 0), (0.325, 14.2), (0.5, 28.35),
        (0.6, 28.35), (0.775, 14.2), (0.95, 0), (1, 0),
    ])

    /// How far the body is raised, 0 (bottom) to 28.35 (top).
    static func lift(at progress: Double) -> CGFloat {
        CGFloat(liftKeys.value(at: progress))
    }

    /// Left elbow for a given lift; the right elbow is its mirror image.
    static func leftElbow(lift: CGFloat) -> CGPoint {
        StickyGeometry.elbow(
            hand: leftHand,
            shoulder: leftShoulder.offsetBy(dy: -lift),
            forearm: forearm,
            upperArm: upperArm,
            bending: .left
        )
    }

    static func figure(at progress: Double) -> StickyFigure {
        let up = lift(at: progress)
        let raise: (CGPoint) -> CGPoint = { $0.offsetBy(dy: -up) }
        let mirror: (CGPoint) -> CGPoint = { $0.mirrored(atX: centerX) }

        let shoulderL = raise(leftShoulder)
        let shoulderR = mirror(shoulderL)
        let elbowL = leftElbow(lift: up)
        let elbowR = mirror(elbowL)
        let handR = mirror(leftHand)
        let neck = raise(head).offsetBy(dy: StickyStyle.headRadius)
        let w = StickyStyle.bodyWidth
        let arm = StickyStyle.armWidth

        return StickyFigure(
            canvas: canvas,
            head: raise(head),
            headRadius: StickyStyle.headRadius,
            limbs: [
                StickySegment(from: leftHand, to: elbowL, width: arm),
                StickySegment(from: elbowL, to: shoulderL, width: arm),
                StickySegment(from: handR, to: elbowR, width: arm),
                StickySegment(from: elbowR, to: shoulderR, width: arm),
                StickySegment(from: shoulderL, to: shoulderR, width: w),
                StickySegment(from: neck, to: raise(hip), width: w),
                StickySegment(from: raise(hip), to: raise(leftFoot), width: w),
                StickySegment(from: raise(hip), to: mirror(raise(leftFoot)), width: w),
            ],
            apparatus: [
                StickySegment(
                    from: CGPoint(x: 50, y: barY),
                    to: CGPoint(x: 150, y: barY),
                    width: StickyStyle.apparatusWidth
                ),
            ]
        )
    }
}
