import CoreGraphics
import Foundation

/// The looping exercise animations. Each maps a progress value (0...1 over one loop)
/// to a `StickyFigure`. Front lever and pull-up follow `docs/DESIGN.md`; the others
/// are side views built from key poses (`BodyAnimation`).
/// The raw values are used as identifiers in `Catalog.json`.
enum StickyAnimation: String, CaseIterable, Codable, Sendable {
    case frontLever
    case tuckFrontLever
    case pullUp
    case negativePullUp
    case pushUp
    case kneePushUp
    case pikePushUp
    case dip
    case row
    case squat
    case lunge
    case pistolSquat
    case plank
    case kneeRaise
    case lSit
    case handstand
    case muscleUp

    /// Key-pose animation behind the side-view cases.
    var bodyAnimation: BodyAnimation? {
        switch self {
        case .frontLever, .tuckFrontLever, .pullUp, .negativePullUp: nil
        case .pushUp: .pushUp
        case .kneePushUp: .kneePushUp
        case .pikePushUp: .pikePushUp
        case .dip: .dip
        case .row: .row
        case .squat: .squat
        case .lunge: .lunge
        case .pistolSquat: .pistolSquat
        case .plank: .plank
        case .kneeRaise: .kneeRaise
        case .lSit: .lSit
        case .handstand: .handstand
        case .muscleUp: .muscleUp
        }
    }

    /// Length of one loop in seconds.
    var duration: TimeInterval {
        switch self {
        case .frontLever, .tuckFrontLever: FrontLeverAnimation.duration
        case .pullUp: PullUpAnimation.duration
        case .negativePullUp: NegativePullUpAnimation.duration
        default: bodyAnimation?.duration ?? 3
        }
    }

    /// Progress of the pose shown when "Reduce Motion" is on.
    var endPoseProgress: Double {
        switch self {
        case .frontLever, .tuckFrontLever: FrontLeverAnimation.holdProgress
        case .pullUp: PullUpAnimation.topProgress
        case .negativePullUp: NegativePullUpAnimation.topProgress
        default: bodyAnimation?.endPoseProgress ?? 0
        }
    }

    var canvas: CGSize {
        switch self {
        case .frontLever, .tuckFrontLever: FrontLeverAnimation.canvas
        case .pullUp, .negativePullUp: PullUpAnimation.canvas
        default: bodyAnimation?.canvas ?? PullUpAnimation.canvas
        }
    }

    func figure(at progress: Double) -> StickyFigure {
        switch self {
        case .frontLever: FrontLeverAnimation.figure(at: progress)
        case .tuckFrontLever: FrontLeverAnimation.figure(at: progress, tucked: true)
        case .pullUp: PullUpAnimation.figure(at: progress)
        case .negativePullUp: NegativePullUpAnimation.figure(at: progress)
        default: bodyAnimation?.figure(at: progress) ?? PullUpAnimation.figure(at: progress)
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
        case .tuckFrontLever: "Tuck front lever animation"
        case .pullUp: "Pull-up animation"
        case .negativePullUp: "Negative pull-up animation"
        case .pushUp: "Push-up animation"
        case .kneePushUp: "Knee push-up animation"
        case .pikePushUp: "Pike push-up animation"
        case .dip: "Dip animation"
        case .row: "Australian row animation"
        case .squat: "Squat animation"
        case .lunge: "Lunge animation"
        case .pistolSquat: "Pistol squat animation"
        case .plank: "Plank animation"
        case .kneeRaise: "Hanging knee raise animation"
        case .lSit: "L-sit animation"
        case .handstand: "Handstand animation"
        case .muscleUp: "Muscle-up animation"
        }
    }
}

/// Negative pull-up: hold at the top, lower slowly, step back up. Reuses the
/// pull-up figure with a different timeline.
enum NegativePullUpAnimation {
    static let duration: TimeInterval = 5
    static let topProgress = 0.0

    /// Maps the loop to pull-up progress: top (0.55) held, slow descent to the bottom
    /// (0.95), then a quick climb back to the top (0.15 to 0.5, both bottom/top poses).
    private static let mapping = Keyframes([
        (0, 0.55), (0.15, 0.55), (0.85, 0.95), (0.86, 0.15), (1, 0.5),
    ])

    static func figure(at progress: Double) -> StickyFigure {
        PullUpAnimation.figure(at: mapping.value(at: progress))
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

    // Tuck variant: shorter torso, knees pulled to the chest (the chest faces +x while
    // hanging and up while holding), shins folded back towards the hips.
    static let tuckHip = CGPoint(x: 60, y: 102)
    static let tuckKnee = CGPoint(x: 80, y: 88)
    static let tuckFeet = CGPoint(x: 72, y: 108)

    /// - Parameter tucked: Knees at the chest (tuck front lever) instead of straight legs.
    static func figure(at progress: Double, tucked: Bool = false) -> StickyFigure {
        let degrees = angle(at: progress)
        let turn: (CGPoint) -> CGPoint = { $0.rotated(around: shoulder, degrees: degrees) }
        let raised = abs(degrees) / 90
        let w = StickyStyle.bodyWidth
        let arm = StickyStyle.armWidth
        let hipPoint = tucked ? tuckHip : hip
        let legs: [StickySegment] = tucked
            ? [
                StickySegment(from: turn(tuckHip), to: turn(tuckKnee), width: w),
                StickySegment(from: turn(tuckKnee), to: turn(tuckFeet), width: w),
            ]
            : [StickySegment(from: turn(hip), to: turn(feet), width: w)]

        return StickyFigure(
            canvas: canvas,
            head: turn(head),
            headRadius: StickyStyle.headRadius,
            limbs: [
                StickySegment(from: leftHand, to: shoulder, width: arm),
                StickySegment(from: rightHand, to: shoulder, width: arm),
                StickySegment(from: shoulder, to: turn(hipPoint), width: w),
            ] + legs,
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
