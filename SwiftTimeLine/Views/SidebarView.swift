import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: DataStore
    @Binding var selectedGroupID: UUID?
    @State private var editingGroup: TimelineGroup?

    var body: some View {
        List(selection: $selectedGroupID) {
            ForEach(store.groups) { group in
                HStack {
                    Label(group.name, systemImage: "folder")
                    Spacer()
                    Text("\(group.events.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                .tag(group.id)
                .contextMenu {
                    Button("编辑分组") {
                        editingGroup = group
                    }
                    Divider()
                    Button("删除分组", role: .destructive) {
                        store.deleteGroup(id: group.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .sheet(item: $editingGroup) { group in
            GroupEditorView(mode: .edit(group))
        }
    }
}
