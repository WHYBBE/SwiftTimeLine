import SwiftUI

struct TagManagerView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
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
            Text(loc(.manageTags))
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
                Text(loc(.addNewTag))
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    TextField(loc(.tagNamePlaceholder), text: $newTagName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)

                    ColorPickerField(selectedColor: $newTagColor, dotSize: 18)

                    Button(loc(.add)) {
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
                Button(loc(.done)) { dismiss() }
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
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
    @Environment(\.dismiss) private var dismiss
    let groupID: UUID
    let tag: Tag
    @State private var name: String = ""
    @State private var color: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text(loc(.editTag))
                .font(.headline)

            Form {
                TextField(loc(.name), text: $name)
                LabeledContent(loc(.color)) {
                    ColorPickerField(selectedColor: $color, dotSize: 18)
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button(loc(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(loc(.save)) {
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
