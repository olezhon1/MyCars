import Foundation
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case ukrainian = "uk"
    case german = "de"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .ukrainian: "Українська"
        case .german: "Deutsch"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

@MainActor
@Observable
final class AppSettings {
    private enum Key {
        static let language = "settings.language"
        static let insuranceReminders = "settings.reminders.insurance.enabled"
        static let maintenanceReminders = "settings.reminders.maintenance.enabled"
        static let insuranceLeadDays = "settings.reminders.insurance.leadDays"
        static let maintenanceThreshold = "settings.reminders.maintenance.threshold"
    }

    private let defaults: UserDefaults

    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Key.language) }
    }

    var insuranceRemindersEnabled: Bool {
        didSet { defaults.set(insuranceRemindersEnabled, forKey: Key.insuranceReminders) }
    }

    var maintenanceRemindersEnabled: Bool {
        didSet { defaults.set(maintenanceRemindersEnabled, forKey: Key.maintenanceReminders) }
    }

    var insuranceLeadDays: Int {
        didSet { defaults.set(insuranceLeadDays, forKey: Key.insuranceLeadDays) }
    }

    var maintenanceThreshold: Int {
        didSet { defaults.set(maintenanceThreshold, forKey: Key.maintenanceThreshold) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        language = AppLanguage(rawValue: defaults.string(forKey: Key.language) ?? "") ?? .english
        insuranceRemindersEnabled = defaults.bool(forKey: Key.insuranceReminders)
        maintenanceRemindersEnabled = defaults.bool(forKey: Key.maintenanceReminders)

        let storedLeadDays = defaults.integer(forKey: Key.insuranceLeadDays)
        insuranceLeadDays = storedLeadDays == 0 ? 30 : storedLeadDays

        let storedThreshold = defaults.integer(forKey: Key.maintenanceThreshold)
        maintenanceThreshold = storedThreshold == 0 ? 1_000 : storedThreshold
    }
}

enum L10n {
    static var locale: Locale { currentLanguage.locale }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        let language = currentLanguage
        let format = localizedFormat(for: key, language: language)
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: language.locale, arguments: arguments)
    }

    static func currency(_ value: Double) -> String {
        value.formatted(.currency(code: "UAH").locale(locale))
    }

    static func integer(_ value: Int) -> String {
        value.formatted(.number.grouping(.automatic).locale(locale))
    }

    private static var currentLanguage: AppLanguage {
        AppLanguage(
            rawValue: UserDefaults.standard.string(forKey: "settings.language") ?? ""
        ) ?? .english
    }

    private static func localizedFormat(for key: String, language: AppLanguage) -> String {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return key }

        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
