import SwiftUI

extension Date {
    var hasTimeComponent: Bool {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0
    }
}

enum DateFormat {
    static let monthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f
    }()

    static let yearMonth: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        return f
    }()

    static let mediumDateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static func eventDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = date.hasTimeComponent ? "M月d日 HH:mm" : "M月d日"
        return f.string(from: date)
    }

    /// Format a date with medium style, including time only when the date has a time component.
    static func tooltip(_ date: Date) -> String {
        date.hasTimeComponent
            ? mediumDateTime.string(from: date)
            : mediumDate.string(from: date)
    }
}
