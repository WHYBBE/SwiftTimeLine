import SwiftUI

struct SidebarView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
    @Binding var selectedGroupID: UUID?
    @State private var editingGroup: TimelineGroup?

    var body: some View {
        List(selection: $selectedGroupID) {
            ForEach(store.visibleGroups) { group in
                HStack {
                    GroupIconView(
                        emoji: group.emoji,
                        symbol: group.symbol,
                        color: Color(hex: group.color)
                    )
                    Text(group.name)
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
                    contextMenu(for: group)
                }
            }
            .onMove { source, destination in
                store.moveVisibleGroups(fromOffsets: source, toOffset: destination)
            }
        }
        .listStyle(.sidebar)
        .sheet(item: $editingGroup) { group in
            GroupEditorView(mode: .edit(group))
        }
    }

    @ViewBuilder
    private func contextMenu(for group: TimelineGroup) -> some View {
        Button(loc(.editGroup)) {
            editingGroup = group
        }

        Button(loc(.exportGroup)) {
            if let data = store.exportGroupData(id: group.id) {
                FilePanels.save(data: data, suggestedName: "\(group.name).json")
            }
        }

        Divider()

        Button(loc(.exportImage)) {
            if let data = TimelineExporter.pngData(group: group, loc: loc) {
                FilePanels.save(data: data, suggestedName: "\(group.name).png", contentType: .png)
            }
        }

        Button(loc(.exportPDF)) {
            if let data = TimelineExporter.pdfData(group: group, loc: loc) {
                FilePanels.save(data: data, suggestedName: "\(group.name).pdf", contentType: .pdf)
            }
        }

        Divider()

        Button(loc(.deleteGroup), role: .destructive) {
            store.deleteGroup(id: group.id)
        }
    }
}
