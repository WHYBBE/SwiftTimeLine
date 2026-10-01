import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.loc) private var loc
    @Environment(\.dismiss) private var dismiss
    let group: TimelineGroup

    private var eventsPerMonth: [MonthlyCount] {
        guard !group.events.isEmpty else { return [] }
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: group.events) { event -> Date in
            let comps = calendar.dateComponents([.year, .month], from: event.date)
            return calendar.date(from: comps) ?? event.date
        }
        return grouped
            .map { MonthlyCount(month: $0.key, count: $0.value.count) }
            .sorted { $0.month < $1.month }
    }

    private var eventsPerTag: [TagCount] {
        var counts: [TagCount] = []
        var claimed = Set<UUID>()
        for tag in group.tags {
            let matching = group.events.filter { $0.tagIDs.contains(tag.id) }
            matching.forEach { claimed.insert($0.id) }
            if !matching.isEmpty {
                counts.append(TagCount(name: tag.name, count: matching.count, color: Color(hex: tag.color)))
            }
        }
        let untagged = group.events.filter { !claimed.contains($0.id) }.count
        if untagged > 0 {
            counts.append(TagCount(name: loc(.uncategorized), count: untagged, color: .secondary))
        }
        return counts.sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(group.name) · \(loc(.statistics))")
                    .font(.headline)
                Spacer()
                Button(loc(.close)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 24) {
                        summaryCard(title: loc(.totalEvents), value: group.events.count, symbol: "calendar")
                        summaryCard(title: loc(.totalTags), value: group.tags.count, symbol: "tag")
                    }

                    if !eventsPerMonth.isEmpty {
                        chartSection(title: loc(.eventsPerMonth)) {
                            Chart(eventsPerMonth) { item in
                                BarMark(
                                    x: .value(loc(.eventsPerMonth), item.month, unit: .month),
                                    y: .value(loc(.totalEvents), item.count)
                                )
                                .foregroundStyle(Color(hex: group.color))
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic(desiredCount: 6)) { value in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.year().month(.abbreviated))
                                }
                            }
                            .frame(height: 200)
                        }
                    }

                    if !eventsPerTag.isEmpty {
                        chartSection(title: loc(.eventsPerTag)) {
                            Chart(eventsPerTag) { item in
                                BarMark(
                                    x: .value(loc(.totalEvents), item.count),
                                    y: .value(loc(.eventsPerTag), item.name)
                                )
                                .foregroundStyle(item.color)
                            }
                            .frame(height: CGFloat(eventsPerTag.count) * 32 + 40)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 560, height: 560)
    }

    @ViewBuilder
    private func summaryCard(title: String, value: Int, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title.bold())
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func chartSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
            content()
        }
    }
}

private struct MonthlyCount: Identifiable {
    let month: Date
    let count: Int
    var id: Date { month }
}

private struct TagCount: Identifiable {
    let name: String
    let count: Int
    let color: Color
    var id: String { name }
}
