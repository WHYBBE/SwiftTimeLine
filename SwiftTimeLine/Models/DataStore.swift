import Foundation
import SwiftUI

struct AppError: Equatable {
    var key: LKey
    var detail: String
}

@MainActor
@Observable
final class DataStore {
    var groups: [TimelineGroup] = []
    var lastError: AppError?

    private let fileURL: URL

    /// Location of the persisted data file.
    var dataFileURL: URL { fileURL }

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = base.appendingPathComponent("SwiftTimeLine", isDirectory: true)
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
            lastError = AppError(key: .loadFailed, detail: error.localizedDescription)
        }
    }

    func save() {
        do {
            let data = try Self.makeEncoder().encode(AppData(groups: groups))
            try data.write(to: fileURL, options: .atomic)
            lastError = nil
        } catch {
            lastError = AppError(key: .saveFailed, detail: error.localizedDescription)
        }
    }

    // MARK: - Group Operations

    func addGroup(name: String, color: String = "#4A90D9", symbol: String? = nil, emoji: String? = nil) {
        groups.append(TimelineGroup(name: name, color: color, symbol: symbol, emoji: emoji))
        save()
    }

    func deleteGroup(id: UUID) {
        groups.removeAll { $0.id == id }
        save()
    }

    func updateGroup(_ group: TimelineGroup) {
        if let i = groups.firstIndex(where: { $0.id == group.id }) {
            groups[i] = group
            save()
        }
    }

    func moveGroups(fromOffsets source: IndexSet, toOffset destination: Int) {
        groups.move(fromOffsets: source, toOffset: destination)
        save()
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

    /// Remove all groups, events and tags.
    func clearAll() {
        groups.removeAll()
        save()
    }
}
