import Foundation

extension Date {
    var hasTimeComponent: Bool {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0
    }
}

enum DateFormat {
    static func monthDay(_ date: Date, language: AppLanguage) -> String {
        (language == .chinese ? zhMonthDay : enMonthDay).string(from: date)
    }

    static func yearMonth(_ date: Date, language: AppLanguage) -> String {
        (language == .chinese ? zhYearMonth : enYearMonth).string(from: date)
    }

    static func eventDate(_ date: Date, language: AppLanguage) -> String {
        let hasTime = date.hasTimeComponent
        let formatter: DateFormatter
        switch (language, hasTime) {
        case (.chinese, true): formatter = zhEventDateTime
        case (.chinese, false): formatter = zhEventDate
        case (_, true): formatter = enEventDateTime
        case (_, false): formatter = enEventDate
        }
        return formatter.string(from: date)
    }

    static func mediumDateTime(_ date: Date, language: AppLanguage) -> String {
        (language == .chinese ? zhMediumDateTime : enMediumDateTime).string(from: date)
    }

    /// Format a date with medium style, including time only when the date has a time component.
    static func tooltip(_ date: Date, language: AppLanguage) -> String {
        date.hasTimeComponent
            ? mediumDateTime(date, language: language)
            : (language == .chinese ? zhMediumDate : enMediumDate).string(from: date)
    }

    // MARK: - Cached formatters

    private static let zhLocale = Locale(identifier: "zh_CN")
    private static let enLocale = Locale(identifier: "en_US")

    private static func fixed(_ format: String, _ locale: Locale) -> DateFormatter {
        let f = DateFormatter()
        f.locale = locale
        f.dateFormat = format
        return f
    }

    private static func styled(_ dateStyle: DateFormatter.Style, _ timeStyle: DateFormatter.Style, _ locale: Locale) -> DateFormatter {
        let f = DateFormatter()
        f.locale = locale
        f.dateStyle = dateStyle
        f.timeStyle = timeStyle
        return f
    }

    private static let zhMonthDay = fixed("MM/dd", zhLocale)
    private static let enMonthDay = fixed("MM/dd", enLocale)
    private static let zhYearMonth = fixed("yyyy年M月", zhLocale)
    private static let enYearMonth = fixed("MMMM yyyy", enLocale)
    private static let zhEventDate = fixed("M月d日", zhLocale)
    private static let zhEventDateTime = fixed("M月d日 HH:mm", zhLocale)
    private static let enEventDate = fixed("MMM d", enLocale)
    private static let enEventDateTime = fixed("MMM d, HH:mm", enLocale)
    private static let zhMediumDateTime = styled(.medium, .short, zhLocale)
    private static let enMediumDateTime = styled(.medium, .short, enLocale)
    private static let zhMediumDate = styled(.medium, .none, zhLocale)
    private static let enMediumDate = styled(.medium, .none, enLocale)
}
