import SwiftUI

enum EventEditorMode {
    case add
    case edit(TimelineEvent)
}

struct EventEditorView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let mode: EventEditorMode
    let groupID: UUID
    let timelineID: UUID

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var selectedColor: String = "#4A90D9"
    @State private var tags: [String] = []
    @State private var newTag: String = ""

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "编辑事件" : "新建事件")
                .font(.headline)

            Form {
                TextField("标题", text: $title)
                TextField("描述", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                DatePicker("日期", selection: $date)

                // Color picker
                LabeledContent("颜色") {
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

                // Tags
                LabeledContent("标签") {
                    VStack(alignment: .leading, spacing: 6) {
                        FlowLayout(spacing: 4) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 2) {
                                    Text(tag)
                                        .font(.caption)
                                    Button(action: { tags.removeAll { $0 == tag } }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.secondary.opacity(0.15))
                                .clipShape(Capsule())
                            }
                        }

                        HStack {
                            TextField("添加标签", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addTag() }
                            Button("添加") { addTag() }
                                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                if isEditing {
                    Button("删除", role: .destructive) {
                        if case .edit(let event) = mode {
                            store.deleteEvent(groupID: groupID, timelineID: timelineID, eventID: event.id)
                        }
                        dismiss()
                    }
                }
                Spacer()
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isEditing ? "保存" : "创建") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 420, height: 480)
        .onAppear {
            if case .edit(let event) = mode {
                title = event.title
                description = event.description
                date = event.date
                selectedColor = event.color
                tags = event.tags
            }
        }
    }

    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        newTag = ""
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if case .edit(let existing) = mode {
            var updated = existing
            updated.title = trimmedTitle
            updated.description = description
            updated.date = date
            updated.color = selectedColor
            updated.tags = tags
            store.updateEvent(groupID: groupID, timelineID: timelineID, event: updated)
        } else {
            let event = TimelineEvent(
                title: trimmedTitle,
                description: description,
                date: date,
                tags: tags,
                color: selectedColor
            )
            store.addEvent(groupID: groupID, timelineID: timelineID, event: event)
        }
        dismiss()
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
