import Foundation

enum DateFilter: String, CaseIterable, Identifiable {
    case all
    case last3Months
    case lastYear
    case thisYear

    var id: String { rawValue }

    var labelKey: LKey {
        switch self {
        case .all: .dateAll
        case .last3Months: .dateLast3Months
        case .lastYear: .dateLastYear
        case .thisYear: .dateThisYear
        }
    }

    var symbol: String {
        switch self {
        case .all: "infinity"
        case .last3Months: "calendar"
        case .lastYear: "calendar.badge.clock"
        case .thisYear: "calendar.badge.checkmark"
        }
    }

    func lowerBound(now: Date = Date()) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .all:
            return nil
        case .last3Months:
            return calendar.date(byAdding: .month, value: -3, to: now)
        case .lastYear:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .thisYear:
            let comps = calendar.dateComponents([.year], from: now)
            return calendar.date(from: comps)
        }
    }
}
