import SwiftUI

struct HorizontalTimelineView: View {
    @EnvironmentObject var store: DataStore
    let group: TimelineGroup
    let onSelectEvent: (TimelineEvent) -> Void

    @State private var scale: CGFloat = 1.0
    @State private var hoveredEventID: UUID?

    private var dateRange: (min: Date, max: Date) {
        let allDates = group.events.map(\.date)
        guard let minDate = allDates.min(), let maxDate = allDates.max() else {
            let now = Date()
            return (now.addingTimeInterval(-86400 * 30), now)
        }
        let padding = max(maxDate.timeIntervalSince(minDate) * 0.1, 86400 * 3)
        return (minDate.addingTimeInterval(-padding), maxDate.addingTimeInterval(padding))
    }

    private var lanes: [(label: String, color: Color, events: [TimelineEvent])] {
        var result: [(label: String, color: Color, events: [TimelineEvent])] = []
        var claimed = Set<UUID>()

        for tag in group.tags {
            let matching = group.events.filter { $0.tagIDs.contains(tag.id) }
            if !matching.isEmpty {
                result.append((label: tag.name, color: Color(hex: tag.color), events: matching))
                matching.forEach { claimed.insert($0.id) }
            }
        }

        let untagged = group.events.filter { !claimed.contains($0.id) }
        if !untagged.isEmpty {
            result.append((label: "未分类", color: .secondary, events: untagged))
        }

        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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

            if group.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("暂无事件")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading, spacing: 8) {
                        timeAxis
                        ForEach(Array(lanes.enumerated()), id: \.offset) { _, lane in
                            laneRow(label: lane.label, color: lane.color, events: lane.events)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Layout

    private let labelWidth: CGFloat = 72
    private var totalWidth: CGFloat { 800 * scale }
    private let rowHeight: CGFloat = 40

    private func xPosition(for date: Date) -> CGFloat {
        let range = dateRange
        let total = range.max.timeIntervalSince(range.min)
        guard total > 0 else { return totalWidth / 2 }
        let offset = date.timeIntervalSince(range.min)
        return (offset / total) * totalWidth
    }

    // MARK: - Time Axis

    @ViewBuilder
    private var timeAxis: some View {
        let range = dateRange
        let totalSeconds = range.max.timeIntervalSince(range.min)
        let tickCount = max(4, Int(scale * 8))
        let interval = totalSeconds / Double(tickCount)

        HStack(spacing: 0) {
            Color.clear.frame(width: labelWidth, height: 30)

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
    }

    // MARK: - Lane Row

    @ViewBuilder
    private func laneRow(label: String, color: Color, events: [TimelineEvent]) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: labelWidth, alignment: .trailing)
                .padding(.trailing, 8)

            ZStack(alignment: .topLeading) {
                // Horizontal line centered vertically
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.1))
                    .frame(width: totalWidth, height: rowHeight)

                ForEach(events) { event in
                    let x = xPosition(for: event.date)
                    let isHovered = hoveredEventID == event.id
                    let dotSize: CGFloat = 10

                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .shadow(color: color.opacity(0.4), radius: isHovered ? 5 : 3)
                        .scaleEffect(isHovered ? 1.4 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: isHovered)
                        .offset(x: x - dotSize / 2, y: rowHeight / 2 - dotSize / 2)
                        .onHover { hovering in
                            if hovering {
                                hoveredEventID = event.id
                            } else if hoveredEventID == event.id {
                                hoveredEventID = nil
                            }
                        }
                        .onTapGesture { onSelectEvent(event) }
                }
            }
            .frame(width: totalWidth, height: rowHeight)
        }
        .overlay(alignment: .topLeading) {
            // Tooltip layer — outside clipped area
            ForEach(events) { event in
                if hoveredEventID == event.id {
                    let x = xPosition(for: event.date) + labelWidth + 8
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.caption.bold())
                        Text(formatTooltipDate(event.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if !event.description.isEmpty {
                            Text(event.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: 4)
                    .fixedSize()
                    .offset(x: x - 30, y: -36)
                    .allowsHitTesting(false)
                }
            }
        }
        .zIndex(hoveredEventID != nil && events.contains(where: { $0.id == hoveredEventID }) ? 1 : 0)
    }

    // MARK: - Formatting

    private func formatAxisDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd"
        return fmt.string(from: date)
    }

    private func formatTooltipDate(_ date: Date) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: date)
        let hasTime = (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = hasTime ? .short : .none
        return fmt.string(from: date)
    }
}
