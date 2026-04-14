import SwiftUI

struct HorizontalTimelineView: View {
    @EnvironmentObject var store: DataStore
    let group: TimelineGroup

    @State private var scale: CGFloat = 1.0
    @State private var selectedEvent: (groupID: UUID, timelineID: UUID, event: TimelineEvent)?

    private var dateRange: (min: Date, max: Date) {
        let allDates = group.timelines.flatMap { $0.events.map(\.date) }
        guard let minDate = allDates.min(), let maxDate = allDates.max() else {
            let now = Date()
            return (now.addingTimeInterval(-86400 * 30), now)
        }
        let padding = max(maxDate.timeIntervalSince(minDate) * 0.1, 86400 * 3)
        return (minDate.addingTimeInterval(-padding), maxDate.addingTimeInterval(padding))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(group.name)
                    .font(.title2.bold())
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { withAnimation { scale = max(0.3, scale - 0.2) } }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    Text("\(Int(scale * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                        .frame(width: 40)
                    Button(action: { withAnimation { scale = min(5.0, scale + 0.2) } }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                }
                .buttonStyle(.borderless)
            }
            .padding()

            Divider()

            // Timeline area
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    // Time axis
                    timeAxis
                        .padding(.leading, 140)

                    // Timeline rows
                    ForEach(group.timelines) { timeline in
                        timelineRow(timeline: timeline)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .popover(item: Binding(
            get: { selectedEvent.map { SelectedEventItem(groupID: $0.groupID, timelineID: $0.timelineID, event: $0.event) } },
            set: { selectedEvent = $0.map { ($0.groupID, $0.timelineID, $0.event) } }
        )) { item in
            EventEditorView(mode: .edit(item.event), groupID: item.groupID, timelineID: item.timelineID)
                .frame(width: 320)
        }
    }

    private var totalWidth: CGFloat { 800 * scale }

    private func xPosition(for date: Date) -> CGFloat {
        let range = dateRange
        let total = range.max.timeIntervalSince(range.min)
        guard total > 0 else { return totalWidth / 2 }
        let offset = date.timeIntervalSince(range.min)
        return (offset / total) * totalWidth
    }

    @ViewBuilder
    private var timeAxis: some View {
        let range = dateRange
        let totalSeconds = range.max.timeIntervalSince(range.min)
        let tickCount = max(4, Int(scale * 8))
        let interval = totalSeconds / Double(tickCount)

        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: totalWidth, height: 30)

            ForEach(0...tickCount, id: \.self) { i in
                let date = range.min.addingTimeInterval(Double(i) * interval)
                let x = xPosition(for: date)
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 8)
                    Text(formatAxisDate(date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .position(x: x, y: 15)
            }
        }
        .frame(width: totalWidth, height: 30)
    }

    @ViewBuilder
    private func timelineRow(timeline: Timeline) -> some View {
        HStack(alignment: .center, spacing: 0) {
            // Label
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: timeline.color))
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 1) {
                    Text(timeline.name)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Text(timeline.type)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 130, alignment: .leading)
            .padding(.leading, 10)

            // Events on the axis
            ZStack(alignment: .leading) {
                // Row background line
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: totalWidth, height: 1)
                    .offset(y: 0)

                ForEach(timeline.events) { event in
                    let x = xPosition(for: event.date)
                    eventDot(event: event, timeline: timeline, x: x)
                }
            }
            .frame(width: totalWidth, height: 40)
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private func eventDot(event: TimelineEvent, timeline: Timeline, x: CGFloat) -> some View {
        let color = Color(hex: event.color)
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .shadow(color: color.opacity(0.4), radius: 3)
            Text(event.title)
                .font(.system(size: 9))
                .lineLimit(1)
                .frame(maxWidth: 60)
        }
        .position(x: x, y: 20)
        .onTapGesture {
            let gid = store.findGroupID(forTimeline: timeline.id) ?? group.id
            selectedEvent = (gid, timeline.id, event)
        }
        .help("\(event.title)\n\(formatTooltipDate(event.date))")
    }

    private func formatAxisDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd"
        return fmt.string(from: date)
    }

    private func formatTooltipDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}

private struct SelectedEventItem: Identifiable {
    let groupID: UUID
    let timelineID: UUID
    let event: TimelineEvent
    var id: UUID { event.id }
}
