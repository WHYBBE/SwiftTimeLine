import SwiftUI

struct HorizontalTimelineView: View {
    @EnvironmentObject var store: DataStore
    let group: TimelineGroup
    let onSelectEvent: (TimelineEvent) -> Void

    @State private var scale: CGFloat = 1.0

    private var dateRange: (min: Date, max: Date) {
        let allDates = group.events.map(\.date)
        guard let minDate = allDates.min(), let maxDate = allDates.max() else {
            let now = Date()
            return (now.addingTimeInterval(-86400 * 30), now)
        }
        let padding = max(maxDate.timeIntervalSince(minDate) * 0.1, 86400 * 3)
        return (minDate.addingTimeInterval(-padding), maxDate.addingTimeInterval(padding))
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
                    VStack(alignment: .leading, spacing: 0) {
                        timeAxis
                        eventRow
                    }
                    .padding(.bottom, 20)
                }
            }
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
        .padding(.leading, 20)
    }

    @ViewBuilder
    private var eventRow: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary.opacity(0.15))
                .frame(width: totalWidth, height: 1)

            ForEach(group.events) { event in
                let x = xPosition(for: event.date)
                let eventColor = primaryColor(for: event)
                VStack(spacing: 2) {
                    Circle()
                        .fill(eventColor)
                        .frame(width: 12, height: 12)
                        .shadow(color: eventColor.opacity(0.4), radius: 3)
                    Text(event.title)
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .frame(maxWidth: 60)
                    tagsPreview(for: event)
                }
                .position(x: x, y: 24)
                .onTapGesture {
                    onSelectEvent(event)
                }
                .help("\(event.title)\n\(formatTooltipDate(event.date))")
            }
        }
        .frame(width: totalWidth, height: 60)
        .padding(.leading, 20)
    }

    @ViewBuilder
    private func tagsPreview(for event: TimelineEvent) -> some View {
        let eventTags = group.tags.filter { event.tagIDs.contains($0.id) }
        if !eventTags.isEmpty {
            HStack(spacing: 2) {
                ForEach(eventTags.prefix(3)) { tag in
                    Circle()
                        .fill(Color(hex: tag.color))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }

    private func primaryColor(for event: TimelineEvent) -> Color {
        if let firstTagID = event.tagIDs.first,
           let tag = group.tags.first(where: { $0.id == firstTagID }) {
            return Color(hex: tag.color)
        }
        return Color(hex: event.color)
    }

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
