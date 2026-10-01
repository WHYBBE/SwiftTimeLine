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
    var tagIDs: [UUID] = []
    var color: String = "#4A90D9"
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    init(id: UUID = UUID(), title: String, description: String = "", date: Date, tagIDs: [UUID] = [], color: String = "#4A90D9", createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.tagIDs = tagIDs
        self.color = color
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try c.decode(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        date = try c.decode(Date.self, forKey: .date)
        tagIDs = try c.decodeIfPresent([UUID].self, forKey: .tagIDs) ?? []
        color = try c.decodeIfPresent(String.self, forKey: .color) ?? "#4A90D9"
        let now = Date()
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        modifiedAt = try c.decodeIfPresent(Date.self, forKey: .modifiedAt) ?? now
    }
}

struct TimelineGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var tags: [Tag] = []
    var events: [TimelineEvent] = []

    func filtered(byTagIDs tagIDs: Set<UUID>) -> TimelineGroup {
        guard !tagIDs.isEmpty else { return self }
        var copy = self
        copy.events = events.filter { event in
            event.tagIDs.contains { tagIDs.contains($0) }
        }
        return copy
    }
}

struct AppData: Codable {
    var groups: [TimelineGroup] = []
}
