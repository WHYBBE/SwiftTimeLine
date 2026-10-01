import SwiftUI

struct EventEditorView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc

    let mode: EditorMode<TimelineEvent>
    let groupID: UUID
    let onDone: () -> Void
    let onDelete: (() -> Void)?

    @State private var title: String = ""
    @State private var eventDescription: String = ""
    @State private var date: Date = Date()
    @State private var includeTime: Bool = false
    @State private var includeEndDate: Bool = false
    @State private var endDate: Date = Date()
    @State private var location: String = ""
    @State private var url: String = ""
    @State private var isPinned: Bool = false
    @State private var selectedColor: String = "#4A90D9"
    @State private var selectedTagIDs: Set<UUID> = []

    private var isEditing: Bool { mode.isEditing }

    private var groupTags: [Tag] {
        store.tagsInGroup(groupID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? loc(.editEvent) : loc(.newEvent))
                    .font(.headline)
                Spacer()
                Button(action: onDone) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.title))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField(loc(.eventTitlePlaceholder), text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.description))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextEditor(text: $eventDescription)
                            .font(.body)
                            .frame(minHeight: 80, maxHeight: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.date))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            DatePicker("", selection: $date,
                                       displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date])
                                .labelsHidden()
                            Toggle(loc(.includeTime), isOn: $includeTime)
                                .toggleStyle(.checkbox)
                                .font(.caption)
                        }

                        Toggle(loc(.endDate), isOn: $includeEndDate)
                            .toggleStyle(.checkbox)
                            .font(.caption)

                        if includeEndDate {
                            DatePicker("", selection: $endDate,
                                       in: date...,
                                       displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date])
                                .labelsHidden()
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.location))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField(loc(.locationPlaceholder), text: $location)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.link))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField(loc(.linkPlaceholder), text: $url)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }

                    Toggle(loc(.pinEvent), isOn: $isPinned)
                        .toggleStyle(.checkbox)
                        .font(.caption)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.color))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        ColorPickerField(selectedColor: $selectedColor)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(loc(.tags))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        tagSelectionView
                    }

                    if let event = mode.editingValue {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.format(.createdAt, DateFormat.mediumDateTime(event.createdAt, language: loc.language)))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(loc.format(.modifiedAt, DateFormat.mediumDateTime(event.modifiedAt, language: loc.language)))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Actions
            HStack {
                if let onDelete = onDelete {
                    Button(loc(.delete), role: .destructive, action: onDelete)
                }
                Spacer()
                Button(isEditing ? loc(.save) : loc(.create)) { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .onAppear { loadFromMode() }
    }

    @ViewBuilder
    private var tagSelectionView: some View {
        if groupTags.isEmpty {
            Text(loc(.noTagsHint))
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            FlowLayout(spacing: 4) {
                ForEach(groupTags) { tag in
                    Button(action: {
                        if selectedTagIDs.contains(tag.id) {
                            selectedTagIDs.remove(tag.id)
                        } else {
                            selectedTagIDs.insert(tag.id)
                        }
                    }) {
                        TagChip(tag: tag, isSelected: selectedTagIDs.contains(tag.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loadFromMode() {
        if let event = mode.editingValue {
            title = event.title
            eventDescription = event.description
            date = event.date
            endDate = event.endDate ?? event.date
            includeEndDate = event.endDate != nil
            location = event.location
            url = event.url
            isPinned = event.isPinned
            selectedColor = event.color
            selectedTagIDs = Set(event.tagIDs)
            // Detect if the event has a non-midnight time
            let cal = Calendar.current
            let comps = cal.dateComponents([.hour, .minute], from: event.date)
            includeTime = (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0
        }
    }

    private var finalDate: Date {
        if includeTime { return date }
        return Calendar.current.startOfDay(for: date)
    }

    private var finalEndDate: Date? {
        guard includeEndDate else { return nil }
        if includeTime { return endDate }
        return Calendar.current.startOfDay(for: endDate)
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if var updated = mode.editingValue {
            updated.title = trimmedTitle
            updated.description = eventDescription
            updated.date = finalDate
            updated.endDate = finalEndDate
            updated.location = location.trimmingCharacters(in: .whitespaces)
            updated.url = url.trimmingCharacters(in: .whitespaces)
            updated.isPinned = isPinned
            updated.color = selectedColor
            updated.tagIDs = Array(selectedTagIDs)
            updated.modifiedAt = Date()
            store.updateEvent(groupID: groupID, event: updated)
        } else {
            let event = TimelineEvent(
                title: trimmedTitle,
                description: eventDescription,
                date: finalDate,
                endDate: finalEndDate,
                location: location.trimmingCharacters(in: .whitespaces),
                url: url.trimmingCharacters(in: .whitespaces),
                isPinned: isPinned,
                tagIDs: Array(selectedTagIDs),
                color: selectedColor
            )
            store.addEvent(groupID: groupID, event: event)
        }
        onDone()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    struct Cache {
        var proposalWidth: CGFloat?
        var size: CGSize = .zero
        var positions: [CGPoint] = []
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        cache.proposalWidth = proposal.width
        cache.size = result.size
        cache.positions = result.positions
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var result = (size: cache.size, positions: cache.positions)
        if cache.proposalWidth != proposal.width || cache.positions.count != subviews.count {
            result = layout(proposal: proposal, subviews: subviews)
            cache.proposalWidth = proposal.width
            cache.size = result.size
            cache.positions = result.positions
        }
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
