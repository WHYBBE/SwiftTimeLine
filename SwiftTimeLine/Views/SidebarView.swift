import SwiftUI

struct SidebarView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
    @Binding var selectedGroupID: UUID?
    @State private var editingGroup: TimelineGroup?

    var body: some View {
        List(selection: $selectedGroupID) {
            ForEach(store.groups) { group in
                HStack {
                    Label(group.name, systemImage: "calendar.day.timeline.left")
                        .symbolRenderingMode(.hierarchical)
                        .labelStyle(.titleAndIcon)
                    Spacer()
                    Text("\(group.events.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
                .tag(group.id)
                .contextMenu {
                    Button(loc(.editGroup)) {
                        editingGroup = group
                    }

                    Button(loc(.exportGroup)) {
                        if let data = store.exportGroupData(id: group.id) {
                            FilePanels.save(data: data, suggestedName: "\(group.name).json")
                        }
                    }

                    Divider()

                    Button(loc(.deleteGroup), role: .destructive) {
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
