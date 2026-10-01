import Foundation
import SwiftUI

@MainActor
@Observable
final class DataStore {
    var groups: [TimelineGroup] = []
    var lastError: String?

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir = docs.appendingPathComponent("SwiftTimeLine", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.fileURL = dir.appendingPathComponent("data.json")
        }
        load()
    }

    // MARK: - Coding

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            groups = try Self.makeDecoder().decode(AppData.self, from: data).groups
        } catch {
            lastError = "加载失败：\(error.localizedDescription)"
        }
    }

    func save() {
        do {
            let data = try Self.makeEncoder().encode(AppData(groups: groups))
            try data.write(to: fileURL, options: .atomic)
            lastError = nil
        } catch {
            lastError = "保存失败：\(error.localizedDescription)"
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

    // MARK: - Export / Import

    func exportGroupData(id: UUID) -> Data? {
        guard let group = groups.first(where: { $0.id == id }) else { return nil }
        return try? Self.makeEncoder().encode(group)
    }

    func exportAllData() -> Data? {
        try? Self.makeEncoder().encode(AppData(groups: groups))
    }

    @discardableResult
    func importGroup(from data: Data) -> Bool {
        guard let imported = try? Self.makeDecoder().decode(TimelineGroup.self, from: data) else {
            return false
        }
        var newGroup = imported
        newGroup.id = UUID()
        groups.append(newGroup)
        save()
        return true
    }

    @discardableResult
    func importAllData(from data: Data) -> Bool {
        guard let appData = try? Self.makeDecoder().decode(AppData.self, from: data) else {
            return false
        }
        for var group in appData.groups {
            group.id = UUID()
            groups.append(group)
        }
        save()
        return true
    }

    /// Import either a single group or a full data file.
    @discardableResult
    func importData(from data: Data) -> Bool {
        if importGroup(from: data) { return true }
        return importAllData(from: data)
    }
}
