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
}

struct TimelineGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var tags: [Tag] = []
    var events: [TimelineEvent] = []
}

struct AppData: Codable {
    var groups: [TimelineGroup] = []
}
