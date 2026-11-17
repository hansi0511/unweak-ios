import Foundation

/// Language of the app texts. By default the app follows the phone's language
/// (German if it is German, otherwise English); Settings can override it.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case de
    case en

    /// `UserDefaults` key; empty or missing means "follow the phone".
    static let storageKey = "appLanguage"

    var id: Self { self }

    var locale: Locale { Locale(identifier: rawValue) }

    /// Short label for the switch ("DE", "EN"); the same in every language.
    var code: String { rawValue.uppercased() }

    /// The first of the phone's preferred languages that the app supports, else English.
    static func system(preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        for identifier in preferredLanguages {
            let code = Locale(identifier: identifier).language.languageCode?.identifier ?? identifier
            if let language = AppLanguage(rawValue: code) { return language }
        }
        return .en
    }

    /// Language in effect for a stored choice.
    static func resolve(stored: String?, preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        stored.flatMap(AppLanguage.init(rawValue:)) ?? system(preferredLanguages: preferredLanguages)
    }

    /// Value to store when the user picks a language: choosing the phone's language
    /// goes back to following the phone.
    static func storedValue(for choice: AppLanguage, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        choice == system(preferredLanguages: preferredLanguages) ? "" : choice.rawValue
    }
}

/// Looks up a localized string for a given language, for places outside SwiftUI `Text`
/// (search, notifications).
enum LocalizedLookup {
    static func string(_ key: String, table: String? = nil, language: AppLanguage, bundle: Bundle = .main) -> String {
        if let path = bundle.path(forResource: language.rawValue, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            return languageBundle.localizedString(forKey: key, value: key, table: table)
        }
        return bundle.localizedString(forKey: key, value: key, table: table)
    }
}
