import SwiftUI

struct VerticalTimelineView: View {
    @EnvironmentObject var store: DataStore
    let group: TimelineGroup

    @State private var selectedEvent: (groupID: UUID, timelineID: UUID, event: TimelineEvent)?

    private var allEvents: [(timeline: Timeline, event: TimelineEvent)] {
        store.allEvents(in: group)
    }

    private var groupedByDate: [(key: String, events: [(timeline: Timeline, event: TimelineEvent)])] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy年M月"
        let dict = Dictionary(grouping: allEvents) { fmt.string(from: $0.event.date) }
        return dict.sorted { a, b in
            guard let da = a.value.first?.event.date, let db = b.value.first?.event.date else { return false }
            return da < db
        }.map { (key: $0.key, events: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(group.name)
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            if allEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("暂无事件")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedByDate, id: \.key) { section in
                            monthSection(title: section.key, events: section.events)
                        }
                    }
                    .padding()
                }
            }
        }
        .popover(item: Binding(
            get: { selectedEvent.map { SelectedVerticalEventItem(groupID: $0.groupID, timelineID: $0.timelineID, event: $0.event) } },
            set: { selectedEvent = $0.map { ($0.groupID, $0.timelineID, $0.event) } }
        )) { item in
            EventEditorView(mode: .edit(item.event), groupID: item.groupID, timelineID: item.timelineID)
                .frame(width: 320)
        }
    }

    @ViewBuilder
    private func monthSection(title: String, events: [(timeline: Timeline, event: TimelineEvent)]) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Month label
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .trailing)

            // Vertical line + events
            VStack(spacing: 0) {
                ForEach(Array(events.enumerated()), id: \.element.event.id) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        // Dot + line
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Color(hex: item.timeline.color))
                                .frame(width: 12, height: 12)

                            if index < events.count - 1 {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 2)
                                    .frame(minHeight: 40)
                            }
                        }

                        // Card
                        eventCard(item: item)
                            .onTapGesture {
                                let gid = store.findGroupID(forTimeline: item.timeline.id) ?? group.id
                                selectedEvent = (gid, item.timeline.id, item.event)
                            }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func eventCard(item: (timeline: Timeline, event: TimelineEvent)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.event.title)
                    .font(.body.bold())
                Spacer()
                Text(formatDate(item.event.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !item.event.description.isEmpty {
                Text(item.event.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack(spacing: 4) {
                Text(item.timeline.name)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: item.timeline.color).opacity(0.15))
                    .clipShape(Capsule())

                ForEach(item.event.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(10)
        .background(Color(hex: item.timeline.color).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(hex: item.timeline.color).opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: 400)
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "M月d日 HH:mm"
        return fmt.string(from: date)
    }
}

private struct SelectedVerticalEventItem: Identifiable {
    let groupID: UUID
    let timelineID: UUID
    let event: TimelineEvent
    var id: UUID { event.id }
}
