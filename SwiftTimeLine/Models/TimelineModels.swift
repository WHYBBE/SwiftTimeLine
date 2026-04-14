import Foundation

struct TimelineEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String = ""
    var date: Date
    var tags: [String] = []
    var color: String = "#4A90D9"
}

struct Timeline: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var type: String = "默认"
    var color: String = "#4A90D9"
    var events: [TimelineEvent] = []
}

struct TimelineGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var timelines: [Timeline] = []
}

struct AppData: Codable {
    var groups: [TimelineGroup] = []
}
