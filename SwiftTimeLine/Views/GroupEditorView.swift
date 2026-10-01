import SwiftUI

struct GroupEditorView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let mode: EditorMode<TimelineGroup>

    @State private var name: String = ""

    private var isEditing: Bool { mode.isEditing }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "编辑分组" : "新建分组")
                .font(.headline)

            Form {
                TextField("分组名称", text: $name)
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
        .frame(width: 320, height: 160)
        .onAppear {
            name = mode.editingValue?.name ?? ""
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let group = mode.editingValue {
            store.updateGroup(id: group.id, name: trimmed)
        } else {
            store.addGroup(name: trimmed)
        }
        dismiss()
    }
}
