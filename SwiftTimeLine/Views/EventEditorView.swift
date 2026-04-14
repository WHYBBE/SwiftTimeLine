import SwiftUI

enum EventEditorMode {
    case add
    case edit(TimelineEvent)
}

struct EventEditorView: View {
    @EnvironmentObject var store: DataStore

    let mode: EventEditorMode
    let groupID: UUID
    let onDone: () -> Void
    let onDelete: (() -> Void)?

    @State private var title: String = ""
    @State private var eventDescription: String = ""
    @State private var date: Date = Date()
    @State private var includeTime: Bool = false
    @State private var selectedColor: String = "#4A90D9"
    @State private var selectedTagIDs: Set<UUID> = []

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var groupTags: [Tag] {
        store.tagsInGroup(groupID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "编辑事件" : "新建事件")
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
                        Text("标题")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("事件标题", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("描述")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        TextField("事件描述", text: $eventDescription, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("日期")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            DatePicker("", selection: $date,
                                       displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date])
                                .labelsHidden()
                            Toggle("包含时间", isOn: $includeTime)
                                .toggleStyle(.checkbox)
                                .font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("颜色")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            ForEach(presetColors, id: \.hex) { preset in
                                Circle()
                                    .fill(Color(hex: preset.hex))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle().strokeBorder(.white, lineWidth: selectedColor == preset.hex ? 2 : 0)
                                    )
                                    .shadow(color: selectedColor == preset.hex ? Color(hex: preset.hex) : .clear, radius: 3)
                                    .onTapGesture { selectedColor = preset.hex }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("标签")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        tagSelectionView
                    }
                }
                .padding()
            }

            Divider()

            // Actions
            HStack {
                if let onDelete = onDelete {
                    Button("删除", role: .destructive, action: onDelete)
                }
                Spacer()
                Button(isEditing ? "保存" : "创建") { save() }
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
            Text("暂无标签，请先在「管理标签」中创建")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            FlowLayout(spacing: 4) {
                ForEach(groupTags) { tag in
                    let isSelected = selectedTagIDs.contains(tag.id)
                    Button(action: {
                        if isSelected {
                            selectedTagIDs.remove(tag.id)
                        } else {
                            selectedTagIDs.insert(tag.id)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: tag.color))
                                .frame(width: 8, height: 8)
                            Text(tag.name)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? Color(hex: tag.color).opacity(0.25) : Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected ? Color(hex: tag.color) : Color.clear,
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func loadFromMode() {
        if case .edit(let event) = mode {
            title = event.title
            eventDescription = event.description
            date = event.date
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

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if case .edit(let existing) = mode {
            var updated = existing
            updated.title = trimmedTitle
            updated.description = eventDescription
            updated.date = finalDate
            updated.color = selectedColor
            updated.tagIDs = Array(selectedTagIDs)
            store.updateEvent(groupID: groupID, event: updated)
        } else {
            let event = TimelineEvent(
                title: trimmedTitle,
                description: eventDescription,
                date: finalDate,
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

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
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
