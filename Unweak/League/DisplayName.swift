import SwiftUI

/// Why a display name cannot be used.
enum DisplayNameProblem: Equatable, Sendable {
    case tooShort
    case tooLong
    /// Only letters, digits, the dot and the underscore are allowed.
    case invalidCharacters
    /// Contains a word from the filter.
    case notAllowed

    var message: LocalizedStringKey {
        switch self {
        case .tooShort: "At least 3 characters"
        case .tooLong: "At most 20 characters"
        case .invalidCharacters: "Only letters, digits, dot and underscore"
        case .notAllowed: "Please choose another name"
        }
    }
}

/// Rules for the public display name in the league (docs/SOCIAL.md). Whether a name is
/// already taken only the server can tell.
enum DisplayName {
    static let minimumLength = 3
    static let maximumLength = 20
    /// A name can be changed at most once in this time.
    static let changeInterval: TimeInterval = 30 * 86_400

    /// Words that are not allowed anywhere in a name, in German and English. The server
    /// checks reported names again; this list only catches the obvious.
    static let blockedWords = [
        "arsch", "fotze", "hure", "wichser", "schlampe", "ficken", "fick", "missgeburt", "spast",
        "schwuchtel", "neger", "kanake", "nazi", "hitler",
        "fuck", "shit", "bitch", "cunt", "nigger", "nigga", "faggot", "whore", "slut",
        "asshole", "retard", "pussy",
    ]

    /// The name as it is saved: without spaces at the ends.
    static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The first problem of a name, `nil` if it can be used.
    static func problem(with name: String) -> DisplayNameProblem? {
        let name = normalized(name)
        if name.count < minimumLength { return .tooShort }
        if name.count > maximumLength { return .tooLong }
        let allowed = name.allSatisfy { $0.isLetter || ($0.isASCII && $0.isNumber) || $0 == "." || $0 == "_" }
        if !allowed { return .invalidCharacters }
        if containsBlockedWord(name) { return .notAllowed }
        return nil
    }

    /// Checks the name in lower case, without dots and underscores and with digits read
    /// as the letters they often stand for ("sh1t").
    static func containsBlockedWord(_ name: String) -> Bool {
        let lookalikes: [Character: Character] = ["0": "o", "1": "i", "3": "e", "4": "a", "5": "s", "7": "t", "8": "b"]
        let plain = String(
            name.lowercased()
                .filter { $0 != "." && $0 != "_" }
                .map { lookalikes[$0] ?? $0 }
        )
        return blockedWords.contains { plain.contains($0) }
    }

    /// Whether the name may be changed now; the first name can always be chosen.
    static func canChange(lastChange: Date?, now: Date) -> Bool {
        guard let lastChange else { return true }
        return now.timeIntervalSince(lastChange) >= changeInterval
    }

    /// When the name may be changed again, `nil` if now.
    static func nextChange(lastChange: Date?, now: Date) -> Date? {
        guard let lastChange, !canChange(lastChange: lastChange, now: now) else { return nil }
        return lastChange.addingTimeInterval(changeInterval)
    }

    /// Shown instead of a name that was reported three times, until it is checked.
    static func replacement(number: Int) -> String {
        "Sportler\(number)"
    }
}
