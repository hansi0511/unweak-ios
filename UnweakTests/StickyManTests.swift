import CoreGraphics
import Foundation
import Testing
@testable import Unweak

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.01) -> Bool {
    abs(a - b) <= tolerance
}

private func isClose(_ a: Double, _ b: Double, tolerance: Double = 0.0001) -> Bool {
    abs(a - b) <= tolerance
}

private func isClose(_ a: CGPoint, _ b: CGPoint, tolerance: CGFloat = 0.01) -> Bool {
    isClose(a.x, b.x, tolerance: tolerance) && isClose(a.y, b.y, tolerance: tolerance)
}

struct GeometryTests {
    @Test func rotatingMinus90DegreesTurnsFeetToTheRight() {
        let feet = CGPoint(x: 60, y: 150).rotated(around: CGPoint(x: 60, y: 62), degrees: -90)
        #expect(isClose(feet, CGPoint(x: 148, y: 62)))
    }

    @Test func rotatingMinus90DegreesTurnsHeadToTheLeft() {
        let head = CGPoint(x: 60, y: 47).rotated(around: CGPoint(x: 60, y: 62), degrees: -90)
        #expect(isClose(head, CGPoint(x: 45, y: 62)))
    }

    @Test func mirroring() {
        #expect(CGPoint(x: 80, y: 20).mirrored(atX: 100) == CGPoint(x: 120, y: 20))
    }

    @Test func elbowKeepsBothBoneLengths() {
        let hand = CGPoint(x: 0, y: 0)
        let shoulder = CGPoint(x: 10, y: 30)
        let elbow = StickyGeometry.elbow(hand: hand, shoulder: shoulder, forearm: 25, upperArm: 25, bending: .left)
        #expect(isClose(elbow.distance(to: hand), 25))
        #expect(isClose(elbow.distance(to: shoulder), 25))
    }

    @Test func elbowBendsToTheRequestedSide() {
        let hand = CGPoint(x: 0, y: 0)
        let shoulder = CGPoint(x: 0, y: 30)
        let left = StickyGeometry.elbow(hand: hand, shoulder: shoulder, forearm: 25, upperArm: 25, bending: .left)
        let right = StickyGeometry.elbow(hand: hand, shoulder: shoulder, forearm: 25, upperArm: 25, bending: .right)
        #expect(left.x < 0)
        #expect(right.x > 0)
    }

    @Test func armStretchesWhenShoulderIsOutOfReach() {
        let elbow = StickyGeometry.elbow(
            hand: .zero,
            shoulder: CGPoint(x: 0, y: 60),
            forearm: 25,
            upperArm: 25,
            bending: .left
        )
        #expect(isClose(elbow, CGPoint(x: 0, y: 25)))
    }
}

struct KeyframesTests {
    @Test func linearInterpolation() {
        let keys = Keyframes([(0, 0), (1, 10)])
        #expect(keys.value(at: 0.25) == 2.5)
    }

    @Test func easeInOutIsSlowAtTheEndsAndExactInTheMiddle() {
        let keys = Keyframes([(0, 0), (1, 10)], curve: .easeInOut)
        #expect(keys.value(at: 0.5) == 5)
        #expect(keys.value(at: 0.25) == 1.5625)
    }

    @Test func clampsOutsideTheTimeline() {
        let keys = Keyframes([(0.2, 3), (0.8, 7)])
        #expect(keys.value(at: -1) == 3)
        #expect(keys.value(at: 0.1) == 3)
        #expect(keys.value(at: 0.9) == 7)
        #expect(keys.value(at: 2) == 7)
    }
}

struct FrontLeverTests {
    @Test func hangsAtTheStart() {
        #expect(FrontLeverAnimation.angle(at: 0) == 0)
        #expect(FrontLeverAnimation.angle(at: 0.1) == 0)
        #expect(FrontLeverAnimation.angle(at: 0.18) == 0)
    }

    @Test func isHorizontalWhileHolding() {
        #expect(isClose(FrontLeverAnimation.angle(at: 0.42), -90))
        #expect(FrontLeverAnimation.angle(at: 0.6) == -90)
        #expect(FrontLeverAnimation.angle(at: 0.8) == -90)
    }

    @Test func pullsUpSmoothly() {
        #expect(isClose(FrontLeverAnimation.angle(at: 0.30), -45))
        var previous = FrontLeverAnimation.angle(at: 0.18)
        for step in 1...24 {
            let angle = FrontLeverAnimation.angle(at: 0.18 + Double(step) * 0.01)
            #expect(angle < previous)
            previous = angle
        }
    }

    @Test func lowersBackToHanging() {
        let lowering = FrontLeverAnimation.angle(at: 0.9)
        #expect(lowering > -90 && lowering < 0)
        #expect(FrontLeverAnimation.angle(at: 1) == 0)
    }

    @Test func feetPointRightWhileHolding() {
        let figure = FrontLeverAnimation.figure(at: 0.6)
        #expect(isClose(figure.limbs[3].to, CGPoint(x: 148, y: 62)))
        #expect(isClose(figure.head, CGPoint(x: 45, y: 62)))
    }

    @Test func targetLineIsPaleWhileHangingAndFullWhileHolding() {
        #expect(FrontLeverAnimation.figure(at: 0.1).guideOpacity == FrontLeverAnimation.guideOpacityHang)
        #expect(FrontLeverAnimation.figure(at: 0.6).guideOpacity == FrontLeverAnimation.guideOpacityHold)
        let guide = FrontLeverAnimation.figure(at: 0).guide
        #expect(guide?.from == CGPoint(x: 60, y: 62))
        #expect(guide?.to == CGPoint(x: 152, y: 62))
    }
}

struct PullUpTests {
    @Test func liftFollowsTheTimeline() {
        #expect(PullUpAnimation.lift(at: 0.1) == 0)
        #expect(isClose(PullUpAnimation.lift(at: 0.325), 14.2))
        #expect(isClose(PullUpAnimation.lift(at: 0.55), 28.35))
        #expect(isClose(PullUpAnimation.lift(at: 0.775), 14.2))
        #expect(PullUpAnimation.lift(at: 0.97) == 0)
    }

    @Test func liftIsEvenBetweenKeyPoints() {
        #expect(isClose(PullUpAnimation.lift(at: 0.2375), 7.1))
    }

    @Test func elbowPositionsMatchTheDesignAngles() {
        // Bottom: from docs/DESIGN.md. Middle and top: from the listed forearm angles.
        #expect(isClose(PullUpAnimation.leftElbow(lift: 0), CGPoint(x: 84, y: 44.7), tolerance: 0.5))
        #expect(isClose(PullUpAnimation.leftElbow(lift: 14.2), CGPoint(x: 67.1, y: 41.45), tolerance: 0.1))
        #expect(isClose(PullUpAnimation.leftElbow(lift: 28.35), CGPoint(x: 63.13, y: 38.45), tolerance: 0.1))
    }

    @Test(arguments: stride(from: 0.0, through: 1.0, by: 0.05).map { $0 })
    func armsKeepTheirLength(_ progress: Double) {
        let limbs = PullUpAnimation.figure(at: progress).limbs
        for arm in limbs[0..<4] {
            #expect(isClose(arm.length, 25, tolerance: 0.05))
        }
    }

    @Test func rightArmMirrorsLeftArm() {
        let limbs = PullUpAnimation.figure(at: 0.4).limbs
        #expect(isClose(limbs[2].to, limbs[0].to.mirrored(atX: 100)))
        #expect(isClose(limbs[3].to, limbs[1].to.mirrored(atX: 100)))
    }

    @Test func handsStayOnTheBar() {
        let limbs = PullUpAnimation.figure(at: 0.55).limbs
        #expect(limbs[0].from == CGPoint(x: 80, y: 20))
        #expect(limbs[2].from == CGPoint(x: 120, y: 20))
    }
}

struct StickyAnimationTests {
    @Test func endPoseIsHoldForFrontLeverAndTopForPullUp() {
        #expect(FrontLeverAnimation.angle(at: StickyAnimation.frontLever.endPoseProgress) == -90)
        #expect(isClose(PullUpAnimation.lift(at: StickyAnimation.pullUp.endPoseProgress), 28.35))
    }

    @Test(arguments: StickyAnimation.allCases)
    func progressLoopsOverTheDuration(_ animation: StickyAnimation) {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        #expect(animation.progress(at: start) == 0)
        #expect(isClose(animation.progress(at: start.addingTimeInterval(animation.duration / 2)), 0.5))
        #expect(isClose(animation.progress(at: start.addingTimeInterval(animation.duration * 3.25)), 0.25))
    }
}

struct StickyPoseTests {
    @Test func everyPoseHasTheExpectedNumberOfLines() {
        let expected: [StickyPose: Int] = [
            .pushUp: 2, .pullUp: 6, .plank: 3, .squat: 4, .handstand: 3,
            .frontLever: 3, .muscleUp: 5, .lSit: 4, .pistolSquat: 5,
        ]
        for pose in StickyPose.allCases {
            #expect(pose.figure.limbs.count == expected[pose], "\(pose)")
        }
    }

    @Test(arguments: StickyPose.allCases)
    func poseStaysInsideItsCanvas(_ pose: StickyPose) {
        for segment in pose.figure.limbs {
            for point in [segment.from, segment.to] {
                let range: ClosedRange<CGFloat> = 0...48
                #expect(range.contains(point.x) && range.contains(point.y))
            }
        }
    }

    @Test func absoluteVerticalLine() {
        let segments = SVGLinePath.segments(from: "M24 33V5", width: 3)
        #expect(segments == [StickySegment(from: CGPoint(x: 24, y: 33), to: CGPoint(x: 24, y: 5), width: 3)])
    }

    @Test func relativeLineWithNegativeNumberWithoutSpace() {
        let segments = SVGLinePath.segments(from: "M17 30l12-4", width: 3)
        #expect(segments.first?.to == CGPoint(x: 29, y: 26))
    }

    @Test func chainedCommandsContinueFromTheLastPoint() {
        let segments = SVGLinePath.segments(from: "M16 30v8h8", width: 3)
        #expect(segments.count == 2)
        #expect(segments[1].from == CGPoint(x: 16, y: 38))
        #expect(segments[1].to == CGPoint(x: 24, y: 38))
    }
}

struct TuckFrontLeverTests {
    @Test func kneesArePulledToTheChestWhileHolding() {
        let figure = StickyAnimation.tuckFrontLever.figure(at: FrontLeverAnimation.holdProgress)
        let shoulder = FrontLeverAnimation.shoulder
        let thigh = figure.limbs[3]
        let shin = figure.limbs[4]
        // Torso horizontal at shoulder height, knees above it (towards the chest), feet near the hips.
        #expect(isClose(figure.limbs[2].to.y, shoulder.y, tolerance: 0.5))
        #expect(thigh.to.y < shoulder.y - 10)
        #expect(shin.to.x > thigh.to.x)
    }

    @Test func movesLikeTheFrontLever() {
        #expect(StickyAnimation.tuckFrontLever.duration == StickyAnimation.frontLever.duration)
        #expect(StickyAnimation.tuckFrontLever.endPoseProgress == StickyAnimation.frontLever.endPoseProgress)
        let tuck = StickyAnimation.tuckFrontLever.figure(at: 0.3)
        let straight = StickyAnimation.frontLever.figure(at: 0.3)
        #expect(tuck.head == straight.head)
    }

    @Test func skillShowsTheFullLeverWhileTheExerciseShowsTheTuck() throws {
        let catalog = Catalog.main
        let skill = try #require(catalog.goals.first { $0.id == "frontLever" })
        #expect(catalog.animation(for: skill) == .frontLever)
        #expect(catalog.exercise("tuckFrontLever")?.animation == .tuckFrontLever)
        let plank = try #require(catalog.goals.first { $0.id == "plank5Min" })
        #expect(catalog.animation(for: plank) == .plank)
    }
}
