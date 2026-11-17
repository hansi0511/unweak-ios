import CoreGraphics
import Foundation

/// Static 48 x 48 poses for lists, from the table in `docs/DESIGN.md`.
enum StickyPose: String, CaseIterable, Codable, Sendable {
    case pushUp
    case pullUp
    case plank
    case squat
    case handstand
    case frontLever
    case muscleUp
    case lSit
    case pistolSquat

    static let canvas = CGSize(width: 48, height: 48)

    var head: CGPoint {
        switch self {
        case .pushUp: CGPoint(x: 9, y: 24)
        case .pullUp: CGPoint(x: 24, y: 14)
        case .plank: CGPoint(x: 9, y: 26)
        case .squat: CGPoint(x: 20, y: 9)
        case .handstand: CGPoint(x: 24, y: 38)
        case .frontLever: CGPoint(x: 9, y: 22)
        case .muscleUp: CGPoint(x: 24, y: 9)
        case .lSit: CGPoint(x: 16, y: 11)
        case .pistolSquat: CGPoint(x: 17, y: 11)
        }
    }

    /// Lines as an SVG path (commands M, L, l, H, h, V, v).
    var path: String {
        switch self {
        case .pushUp: "M13 27L40 37M16 28v10"
        case .pullUp: "M8 7h32M17 7l5 12M31 7l-5 12M24 19v13M24 32l-4 11M24 32l4 11"
        case .plank: "M13 29L41 37M16 30v8h8"
        case .squat: "M20 13l-2 14M18 27l13 2M31 29l-5 13M19 17l13 3"
        case .handstand: "M24 33V5M24 33l-6 10M24 33l6 10"
        case .frontLever: "M6 7h36M15 7v14M14 22h28"
        case .muscleUp: "M8 30h32M24 13v20M24 15l-6 15M24 15l6 15M24 33v10"
        case .lSit: "M16 15v15M16 30h26M16 19v18M9 38h14"
        case .pistolSquat: "M17 15v15M17 30l12-4M29 26l-5 17M17 30l25 4M17 19l14 2"
        }
    }

    var figure: StickyFigure {
        StickyFigure(
            canvas: Self.canvas,
            head: head,
            headRadius: StickyStyle.poseHeadRadius,
            limbs: SVGLinePath.segments(from: path, width: StickyStyle.poseWidth)
        )
    }

    var accessibilityName: LocalizedStringResource {
        switch self {
        case .pushUp: "Push-up"
        case .pullUp: "Pull-up"
        case .plank: "Plank"
        case .squat: "Squat"
        case .handstand: "Handstand"
        case .frontLever: "Front lever"
        case .muscleUp: "Muscle-up"
        case .lSit: "L-sit"
        case .pistolSquat: "Pistol squat"
        }
    }
}

/// Minimal reader for SVG paths made of straight lines.
/// Supports M, L, l, H, h, V, v; parameters may repeat after a command.
enum SVGLinePath {
    static func segments(from path: String, width: CGFloat) -> [StickySegment] {
        let tokens = tokenize(path)
        var segments: [StickySegment] = []
        var current = CGPoint.zero
        var command: Character = "M"
        var index = 0

        func number() -> CGFloat? {
            guard index < tokens.count, case .number(let value) = tokens[index] else { return nil }
            index += 1
            return value
        }

        while index < tokens.count {
            if case .command(let c) = tokens[index] {
                command = c
                index += 1
            }
            let next: CGPoint
            switch command {
            case "M":
                guard let x = number(), let y = number() else { return segments }
                current = CGPoint(x: x, y: y)
                command = "L" // further pairs after M are lines
                continue
            case "L":
                guard let x = number(), let y = number() else { return segments }
                next = CGPoint(x: x, y: y)
            case "l":
                guard let dx = number(), let dy = number() else { return segments }
                next = current.offsetBy(dx: dx, dy: dy)
            case "H":
                guard let x = number() else { return segments }
                next = CGPoint(x: x, y: current.y)
            case "h":
                guard let dx = number() else { return segments }
                next = current.offsetBy(dx: dx)
            case "V":
                guard let y = number() else { return segments }
                next = CGPoint(x: current.x, y: y)
            case "v":
                guard let dy = number() else { return segments }
                next = current.offsetBy(dy: dy)
            default:
                return segments
            }
            segments.append(StickySegment(from: current, to: next, width: width))
            current = next
        }
        return segments
    }

    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    private static func tokenize(_ path: String) -> [Token] {
        var tokens: [Token] = []
        var buffer = ""

        func flush() {
            if let value = Double(buffer) {
                tokens.append(.number(CGFloat(value)))
            }
            buffer = ""
        }

        for character in path {
            if character.isLetter {
                flush()
                tokens.append(.command(character))
            } else if character == "-" {
                flush()
                buffer = "-"
            } else if character.isNumber || character == "." {
                buffer.append(character)
            } else {
                flush()
            }
        }
        flush()
        return tokens
    }
}
