import SwiftUI

struct TagManagerView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    let groupID: UUID

    @State private var newTagName: String = ""
    @State private var newTagColor: String = "#4A90D9"
    @State private var editingTag: Tag?

    private var groupTags: [Tag] {
        store.tagsInGroup(groupID)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("管理标签")
                .font(.headline)
                .padding()

            Divider()

            List {
                ForEach(groupTags) { tag in
                    HStack {
                        Circle()
                            .fill(Color(hex: tag.color))
                            .frame(width: 12, height: 12)
                        Text(tag.name)
                            .font(.body)
                        Spacer()
                        Button(action: { editingTag = tag }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.borderless)
                        Button(action: { store.deleteTag(groupID: groupID, tagID: tag.id) }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }

            Divider()

            VStack(spacing: 10) {
                Text("添加新标签")
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    TextField("标签名称", text: $newTagName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)

                    HStack(spacing: 4) {
                        ForEach(presetColors, id: \.hex) { preset in
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle().strokeBorder(.white, lineWidth: newTagColor == preset.hex ? 2 : 0)
                                )
                                .shadow(color: newTagColor == preset.hex ? Color(hex: preset.hex) : .clear, radius: 2)
                                .onTapGesture { newTagColor = preset.hex }
                        }
                    }

                    Button("添加") {
                        let name = newTagName.trimmingCharacters(in: .whitespaces)
                        guard !name.isEmpty else { return }
                        store.addTag(groupID: groupID, name: name, color: newTagColor)
                        newTagName = ""
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding()

            Divider()

            HStack {
                Spacer()
                Button("完成") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 480, height: 420)
        .sheet(item: $editingTag) { tag in
            TagEditSheet(groupID: groupID, tag: tag)
        }
    }
}

private struct TagEditSheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    let groupID: UUID
    let tag: Tag
    @State private var name: String = ""
    @State private var color: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("编辑标签")
                .font(.headline)

            Form {
                TextField("名称", text: $name)
                LabeledContent("颜色") {
                    HStack(spacing: 4) {
                        ForEach(presetColors, id: \.hex) { preset in
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle().strokeBorder(.white, lineWidth: color == preset.hex ? 2 : 0)
                                )
                                .shadow(color: color == preset.hex ? Color(hex: preset.hex) : .clear, radius: 2)
                                .onTapGesture { color = preset.hex }
                        }
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("取消") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("保存") {
                    var updated = tag
                    updated.name = name.trimmingCharacters(in: .whitespaces)
                    updated.color = color
                    store.updateTag(groupID: groupID, tag: updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 360, height: 240)
        .onAppear {
            name = tag.name
            color = tag.color
        }
    }
}
