import SwiftUI

struct GroupEditorView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
    @Environment(\.dismiss) private var dismiss

    let mode: EditorMode<TimelineGroup>

    @State private var name: String = ""

    private var isEditing: Bool { mode.isEditing }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? loc(.editGroup) : loc(.newGroup))
                .font(.headline)

            Form {
                TextField(loc(.groupNamePlaceholder), text: $name)
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button(loc(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isEditing ? loc(.save) : loc(.create)) { save() }
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
