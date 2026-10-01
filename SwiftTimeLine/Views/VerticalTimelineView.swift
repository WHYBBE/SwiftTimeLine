import SwiftUI

struct VerticalTimelineView: View {
    @Environment(\.loc) private var loc
    let group: TimelineGroup
    let onSelectEvent: (TimelineEvent) -> Void
    let onAddEvent: () -> Void

    private var groupedByDate: [(key: String, events: [TimelineEvent])] {
        let dict = Dictionary(grouping: group.events) { DateFormat.yearMonth($0.date, language: loc.language) }
        return dict.sorted { a, b in
            guard let da = a.value.first?.date, let db = b.value.first?.date else { return false }
            return da < db
        }.map { (key: $0.key, events: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(group.name)
                    .font(.title2.bold())
                Spacer()
                Button(action: onAddEvent) {
                    Label(loc(.newEvent), systemImage: "plus")
                }
            }
            .padding()

            Divider()

            if group.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text(loc(.noEvents))
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func monthSection(title: String, events: [TimelineEvent]) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .trailing)

            VStack(spacing: 0) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(primaryColor(for: event))
                                .frame(width: 12, height: 12)

                            if index < events.count - 1 {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 2)
                                    .frame(minHeight: 40)
                            }
                        }

                        eventCard(event: event)
                            .onTapGesture {
                                onSelectEvent(event)
                            }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func eventCard(event: TimelineEvent) -> some View {
        let eventColor = Color(hex: event.color)
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.title)
                    .font(.body.bold())
                Spacer()
                Text(DateFormat.eventDate(event.date, language: loc.language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            let eventTags = group.tags.filter { event.tagIDs.contains($0.id) }
            if !eventTags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(eventTags) { tag in
                        TagChip(tag: tag)
                    }
                }
            }
        }
        .padding(10)
        .background(eventColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(eventColor.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: 400)
    }

    private func primaryColor(for event: TimelineEvent) -> Color {
        if let firstTagID = event.tagIDs.first,
           let tag = group.tags.first(where: { $0.id == firstTagID }) {
            return Color(hex: tag.color)
        }
        return Color(hex: event.color)
    }
}
