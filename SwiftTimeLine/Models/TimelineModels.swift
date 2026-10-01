import Foundation

struct Tag: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var color: String = "#4A90D9"
}

struct TimelineEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String = ""
    var date: Date
    var endDate: Date?
    var location: String = ""
    var url: String = ""
    var isPinned: Bool = false
    var tagIDs: [UUID] = []
    var color: String = "#4A90D9"
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        date: Date,
        endDate: Date? = nil,
        location: String = "",
        url: String = "",
        isPinned: Bool = false,
        tagIDs: [UUID] = [],
        color: String = "#4A90D9",
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.endDate = endDate
        self.location = location
        self.url = url
        self.isPinned = isPinned
        self.tagIDs = tagIDs
        self.color = color
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// A URL safe to open in the browser, if the stored string is valid.
    var linkURL: URL? {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil { return url }
        return URL(string: "https://\(trimmed)")
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try c.decode(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        date = try c.decode(Date.self, forKey: .date)
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
        location = try c.decodeIfPresent(String.self, forKey: .location) ?? ""
        url = try c.decodeIfPresent(String.self, forKey: .url) ?? ""
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        tagIDs = try c.decodeIfPresent([UUID].self, forKey: .tagIDs) ?? []
        color = try c.decodeIfPresent(String.self, forKey: .color) ?? "#4A90D9"
        let now = Date()
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        modifiedAt = try c.decodeIfPresent(Date.self, forKey: .modifiedAt) ?? now
    }
}

struct TimelineGroup: Identifiable, Codable, Hashable {
    static let defaultSymbol = "calendar.day.timeline.left"

    var id = UUID()
    var name: String
    var color: String = "#4A90D9"
    var symbol: String?
    var emoji: String?
    var tags: [Tag] = []
    var events: [TimelineEvent] = []

    init(
        id: UUID = UUID(),
        name: String,
        color: String = "#4A90D9",
        symbol: String? = nil,
        emoji: String? = nil,
        tags: [Tag] = [],
        events: [TimelineEvent] = []
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.symbol = symbol
        self.emoji = emoji
        self.tags = tags
        self.events = events
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        color = try c.decodeIfPresent(String.self, forKey: .color) ?? "#4A90D9"
        symbol = try c.decodeIfPresent(String.self, forKey: .symbol)
        emoji = try c.decodeIfPresent(String.self, forKey: .emoji)
        tags = try c.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        events = try c.decodeIfPresent([TimelineEvent].self, forKey: .events) ?? []
    }

    func filtered(byTagIDs tagIDs: Set<UUID>) -> TimelineGroup {
        guard !tagIDs.isEmpty else { return self }
        var copy = self
        copy.events = events.filter { event in
            event.tagIDs.contains { tagIDs.contains($0) }
        }
        return copy
    }

    func filtered(by filter: DateFilter, now: Date = Date()) -> TimelineGroup {
        guard let lowerBound = filter.lowerBound(now: now) else { return self }
        var copy = self
        copy.events = events.filter { $0.date >= lowerBound }
        return copy
    }

    func sorted(ascending: Bool) -> TimelineGroup {
        var copy = self
        copy.events.sort { ascending ? $0.date < $1.date : $0.date > $1.date }
        return copy
    }
}

struct AppData: Codable {
    var groups: [TimelineGroup] = []
}
