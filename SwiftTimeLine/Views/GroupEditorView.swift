import SwiftUI

enum GroupEditorMode {
    case add
    case edit(TimelineGroup)
}

struct GroupEditorView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let mode: GroupEditorMode

    @State private var name: String = ""

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

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
            if case .edit(let group) = mode {
                name = group.name
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if case .edit(let group) = mode {
            store.updateGroup(id: group.id, name: trimmed)
        } else {
            store.addGroup(name: trimmed)
        }
        dismiss()
    }
}
