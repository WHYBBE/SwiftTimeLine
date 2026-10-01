import SwiftUI
import Observation

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var labelKey: LKey {
        switch self {
        case .system: .themeSystem
        case .light: .themeLight
        case .dark: .themeDark
        }
    }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case chinese
    case english

    var id: String { rawValue }

    /// Resolves `.system` to a concrete language based on the system locale.
    var resolved: AppLanguage {
        guard self == .system else { return self }
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return code.hasPrefix("zh") ? .chinese : .english
    }

    var labelKey: LKey {
        switch self {
        case .system: .languageSystem
        case .chinese: .languageChinese
        case .english: .languageEnglish
        }
    }
}

@MainActor
@Observable
final class AppSettings {
    var theme: AppTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }

    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    /// Per-group sort order: `true` = ascending (oldest first).
    private var sortAscendingByGroup: [String: Bool] {
        didSet { defaults.set(sortAscendingByGroup, forKey: Keys.sort) }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let theme = "app.theme"
        static let language = "app.language"
        static let sort = "app.sortAscending"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        theme = AppTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .system
        language = AppLanguage(rawValue: defaults.string(forKey: Keys.language) ?? "") ?? .system
        sortAscendingByGroup = defaults.object(forKey: Keys.sort) as? [String: Bool] ?? [:]
    }

    func sortAscending(for groupID: UUID) -> Bool {
        sortAscendingByGroup[groupID.uuidString] ?? true
    }

    func setSortAscending(_ value: Bool, for groupID: UUID) {
        sortAscendingByGroup[groupID.uuidString] = value
    }

    var localization: Localization {
        Localization(language: language.resolved)
    }
}
