import CoreGraphics
import Testing
@testable import Unweak

private let bodyCases = StickyAnimation.allCases.filter { $0.bodyAnimation != nil }
private let samples = stride(from: 0.0, through: 1.0, by: 0.01).map { $0 }

private func isClose(_ a: CGFloat, _ b: CGFloat, tolerance: CGFloat = 0.01) -> Bool {
    abs(a - b) <= tolerance
}

struct StickyBodyTests {
    @Test func thirteenKeyPoseAnimationsExist() {
        #expect(bodyCases.count == 13)
    }

    @Test(arguments: bodyCases)
    func bonesKeepTheirLength(_ animation: StickyAnimation) throws {
        let body = try #require(animation.bodyAnimation)
        for t in samples {
            let joints = body.pose(at: t).solved()
            #expect(isClose(joints.hip.distance(to: joints.shoulder), StickyBody.torso))
            #expect(isClose(joints.shoulder.distance(to: joints.head), StickyBody.neck))
            for arm in joints.arms {
                #expect(isClose(arm.root.distance(to: arm.middle), StickyBody.upperArm))
                #expect(isClose(arm.middle.distance(to: arm.end), StickyBody.forearm))
            }
            for leg in joints.legs {
                #expect(isClose(leg.root.distance(to: leg.middle), StickyBody.thigh))
                #expect(isClose(leg.middle.distance(to: leg.end), StickyBody.shin))
            }
        }
    }

    @Test(arguments: bodyCases)
    func handsAndFeetStayWhereTheyArePinned(_ animation: StickyAnimation) throws {
        let body = try #require(animation.bodyAnimation)
        for t in samples {
            let pose = body.pose(at: t)
            let joints = pose.solved()
            let limbs = zip(pose.arms + pose.legs, joints.arms + joints.legs)
            for (limb, solved) in limbs {
                if case let .pinned(point, _) = limb {
                    #expect(solved.end.distance(to: point) < 2, "\(animation) at \(t)")
                }
            }
        }
    }

    @Test(arguments: bodyCases)
    func loopsWithoutAJump(_ animation: StickyAnimation) throws {
        let body = try #require(animation.bodyAnimation)
        #expect(body.pose(at: 0) == body.pose(at: 1))
    }

    @Test(arguments: StickyAnimation.allCases)
    func staysOnItsCanvas(_ animation: StickyAnimation) {
        let canvas = animation.canvas
        for t in samples {
            let figure = animation.figure(at: t)
            #expect(!figure.limbs.isEmpty)
            let points = figure.limbs.flatMap { [$0.from, $0.to] } + [figure.head]
            for point in points {
                #expect(
                    (0...canvas.width).contains(point.x) && (0...canvas.height).contains(point.y),
                    "\(animation) at \(t): \(point)"
                )
            }
        }
    }

    @Test(arguments: StickyAnimation.allCases)
    func endPoseIsInsideTheLoop(_ animation: StickyAnimation) {
        #expect((0...1).contains(animation.endPoseProgress))
        #expect(animation.duration > 0)
    }

    @Test func sideViewDrawsFarLimbsFainter() {
        let figure = StickyAnimation.squat.figure(at: 0)
        #expect(figure.limbs.contains { $0.opacity == StickyBody.farLimbOpacity })
        #expect(figure.limbs.contains { $0.opacity == 1 })
    }

    @Test func jointSolverKeepsLengthsAndBendsToTheRequestedSide() {
        let root = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: 30, y: 0)
        let up = StickyGeometry.joint(root: root, end: end, first: 22, second: 21, bend: .negative)
        let down = StickyGeometry.joint(root: root, end: end, first: 22, second: 21, bend: .positive)
        #expect(isClose(up.distance(to: root), 22) && isClose(up.distance(to: end), 21))
        #expect(up.y < 0)
        #expect(down.y > 0)
    }

    @Test func jointSolverStaysFiniteWhenRootAndEndAlmostMeet() {
        let joint = StickyGeometry.joint(
            root: .zero,
            end: CGPoint(x: 0.0001, y: 0),
            first: 22,
            second: 21,
            bend: .positive
        )
        #expect(joint.x.isFinite && joint.y.isFinite)
        #expect(isClose(joint.distance(to: .zero), 22))
    }

    @Test func negativePullUpStartsAtTheTopAndLoops() {
        let top = PullUpAnimation.figure(at: PullUpAnimation.topProgress)
        #expect(StickyAnimation.negativePullUp.figure(at: 0) == top)
        #expect(isClose(StickyAnimation.negativePullUp.figure(at: 1).head.y, top.head.y))
    }
}
