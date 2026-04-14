import Foundation
import SwiftUI

@MainActor
class DataStore: ObservableObject {
    @Published var groups: [TimelineGroup] = []

    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("SwiftTimeLine", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("data.json")
        load()
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let appData = try decoder.decode(AppData.self, from: data)
            groups = appData.groups
        } catch {
            print("Failed to load: \(error)")
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(AppData(groups: groups))
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save: \(error)")
        }
    }

    // MARK: - Group Operations

    func addGroup(name: String) {
        groups.append(TimelineGroup(name: name))
        save()
    }

    func deleteGroup(id: UUID) {
        groups.removeAll { $0.id == id }
        save()
    }

    func updateGroup(id: UUID, name: String) {
        if let i = groups.firstIndex(where: { $0.id == id }) {
            groups[i].name = name
            save()
        }
    }

    // MARK: - Timeline Operations

    func addTimeline(groupID: UUID, name: String, type: String, color: String) {
        if let i = groups.firstIndex(where: { $0.id == groupID }) {
            groups[i].timelines.append(Timeline(name: name, type: type, color: color))
            save()
        }
    }

    func deleteTimeline(groupID: UUID, timelineID: UUID) {
        if let i = groups.firstIndex(where: { $0.id == groupID }) {
            groups[i].timelines.removeAll { $0.id == timelineID }
            save()
        }
    }

    func updateTimeline(groupID: UUID, timelineID: UUID, name: String, type: String, color: String) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ti = groups[gi].timelines.firstIndex(where: { $0.id == timelineID }) {
            groups[gi].timelines[ti].name = name
            groups[gi].timelines[ti].type = type
            groups[gi].timelines[ti].color = color
            save()
        }
    }

    // MARK: - Event Operations

    func addEvent(groupID: UUID, timelineID: UUID, event: TimelineEvent) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ti = groups[gi].timelines.firstIndex(where: { $0.id == timelineID }) {
            groups[gi].timelines[ti].events.append(event)
            groups[gi].timelines[ti].events.sort { $0.date < $1.date }
            save()
        }
    }

    func deleteEvent(groupID: UUID, timelineID: UUID, eventID: UUID) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ti = groups[gi].timelines.firstIndex(where: { $0.id == timelineID }) {
            groups[gi].timelines[ti].events.removeAll { $0.id == eventID }
            save()
        }
    }

    func updateEvent(groupID: UUID, timelineID: UUID, event: TimelineEvent) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ti = groups[gi].timelines.firstIndex(where: { $0.id == timelineID }),
           let ei = groups[gi].timelines[ti].events.firstIndex(where: { $0.id == event.id }) {
            groups[gi].timelines[ti].events[ei] = event
            groups[gi].timelines[ti].events.sort { $0.date < $1.date }
            save()
        }
    }

    // MARK: - Helpers

    func allEvents(in group: TimelineGroup) -> [(timeline: Timeline, event: TimelineEvent)] {
        group.timelines.flatMap { tl in
            tl.events.map { (timeline: tl, event: $0) }
        }.sorted { $0.event.date < $1.event.date }
    }

    func findGroupID(forTimeline timelineID: UUID) -> UUID? {
        groups.first { $0.timelines.contains { $0.id == timelineID } }?.id
    }
}
