import SwiftUI

struct TimelineExportView: View {
    @Environment(\.loc) private var loc
    let group: TimelineGroup

    private var sortedEvents: [TimelineEvent] {
        group.events.sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: group.color))
                    .frame(width: 14, height: 14)
                Text(group.name)
                    .font(.system(size: 28, weight: .bold))
            }

            if sortedEvents.isEmpty {
                Text(loc(.noEvents))
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedEvents) { event in
                        row(for: event)
                    }
                }
            }
        }
        .padding(32)
        .frame(width: 760, alignment: .leading)
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }

    @ViewBuilder
    private func row(for event: TimelineEvent) -> some View {
        let eventColor = Color(hex: event.color)
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(eventColor)
                .frame(width: 10, height: 10)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if event.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(eventColor)
                    }
                    Text(event.title)
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(dateRangeText(for: event))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                if !event.location.isEmpty {
                    Text("📍 \(event.location)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                if !event.url.isEmpty {
                    Text(event.url)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.accentColor)
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
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(eventColor.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func dateRangeText(for event: TimelineEvent) -> String {
        let start = DateFormat.eventDate(event.date, language: loc.language)
        guard let endDate = event.endDate else { return start }
        let end = DateFormat.eventDate(endDate, language: loc.language)
        return "\(start) – \(end)"
    }
}
