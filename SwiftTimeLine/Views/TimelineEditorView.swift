import SwiftUI

enum TimelineEditorMode {
    case add
    case edit(Timeline)
}

struct TimelineEditorView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let mode: TimelineEditorMode
    let groupID: UUID

    @State private var name: String = ""
    @State private var type: String = "默认"
    @State private var selectedColor: String = "#4A90D9"

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "编辑时间线" : "新建时间线")
                .font(.headline)

            Form {
                TextField("名称", text: $name)
                TextField("类型", text: $type)
                    .help("如：工作、学习、生活等自定义类型")

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
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isEditing ? "保存" : "创建") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 380, height: 260)
        .onAppear {
            if case .edit(let timeline) = mode {
                name = timeline.name
                type = timeline.type
                selectedColor = timeline.color
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if case .edit(let existing) = mode {
            store.updateTimeline(groupID: groupID, timelineID: existing.id, name: trimmed, type: type, color: selectedColor)
        } else {
            store.addTimeline(groupID: groupID, name: trimmed, type: type, color: selectedColor)
        }
        dismiss()
    }
}
