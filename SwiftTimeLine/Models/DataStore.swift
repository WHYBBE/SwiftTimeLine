import Foundation
import SwiftUI
import AppKit

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

    // MARK: - Event Operations

    func addEvent(groupID: UUID, event: TimelineEvent) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }) {
            groups[gi].events.append(event)
            groups[gi].events.sort { $0.date < $1.date }
            save()
        }
    }

    func deleteEvent(groupID: UUID, eventID: UUID) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }) {
            groups[gi].events.removeAll { $0.id == eventID }
            save()
        }
    }

    func updateEvent(groupID: UUID, event: TimelineEvent) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ei = groups[gi].events.firstIndex(where: { $0.id == event.id }) {
            groups[gi].events[ei] = event
            groups[gi].events.sort { $0.date < $1.date }
            save()
        }
    }

    // MARK: - Tag Operations (per group)

    func addTag(groupID: UUID, name: String, color: String) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }) {
            groups[gi].tags.append(Tag(name: name, color: color))
            save()
        }
    }

    func deleteTag(groupID: UUID, tagID: UUID) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }) {
            groups[gi].tags.removeAll { $0.id == tagID }
            for ei in groups[gi].events.indices {
                groups[gi].events[ei].tagIDs.removeAll { $0 == tagID }
            }
            save()
        }
    }

    func updateTag(groupID: UUID, tag: Tag) {
        if let gi = groups.firstIndex(where: { $0.id == groupID }),
           let ti = groups[gi].tags.firstIndex(where: { $0.id == tag.id }) {
            groups[gi].tags[ti] = tag
            save()
        }
    }

    // MARK: - Helpers

    func tagsInGroup(_ groupID: UUID) -> [Tag] {
        groups.first { $0.id == groupID }?.tags ?? []
    }

    func tag(inGroup groupID: UUID, for id: UUID) -> Tag? {
        groups.first { $0.id == groupID }?.tags.first { $0.id == id }
    }

    func tags(inGroup groupID: UUID, for ids: [UUID]) -> [Tag] {
        let groupTags = groups.first { $0.id == groupID }?.tags ?? []
        return ids.compactMap { id in groupTags.first { $0.id == id } }
    }

    func filteredEvents(in group: TimelineGroup, byTagIDs tagIDs: Set<UUID>) -> [TimelineEvent] {
        if tagIDs.isEmpty { return group.events }
        return group.events.filter { event in
            !event.tagIDs.filter { tagIDs.contains($0) }.isEmpty
        }
    }

    // MARK: - Export / Import

    func exportGroup(id: UUID) -> Data? {
        guard let group = groups.first(where: { $0.id == id }) else { return nil }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(group)
    }

    func importGroup(from data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let imported = try? decoder.decode(TimelineGroup.self, from: data) else { return false }
        // Assign new ID to avoid conflicts
        var newGroup = imported
        newGroup.id = UUID()
        groups.append(newGroup)
        save()
        return true
    }

    func exportGroupToFile(id: UUID) {
        guard let data = exportGroup(id: id),
              let group = groups.first(where: { $0.id == id }) else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(group.name).json"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url, options: .atomic)
        }
    }

    func importGroupFromFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            if let data = try? Data(contentsOf: url) {
                // Try single group first, then full AppData
                if importGroup(from: data) { return }
                _ = importAllData(from: data)
            }
        }
    }

    // MARK: - Export / Import All Data

    func exportAllDataToFile() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(AppData(groups: groups)) else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "SwiftTimeLine_全部数据.json"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url, options: .atomic)
        }
    }

    func importAllData(from data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let appData = try? decoder.decode(AppData.self, from: data) else { return false }
        for var group in appData.groups {
            group.id = UUID()
            groups.append(group)
        }
        save()
        return true
    }
}
