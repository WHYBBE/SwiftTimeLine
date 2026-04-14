import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: DataStore
    @Binding var selection: SidebarSelection?
    @State private var editingGroup: TimelineGroup?
    @State private var editingTimelineItem: EditableTimeline?

    var body: some View {
        List(selection: $selection) {
            ForEach(store.groups) { group in
                Section {
                    ForEach(group.timelines) { timeline in
                        timelineRow(group: group, timeline: timeline)
                    }
                } header: {
                    groupHeader(group: group)
                }
            }
        }
        .listStyle(.sidebar)
        .sheet(item: $editingGroup) { group in
            GroupEditorView(mode: .edit(group))
        }
        .sheet(item: $editingTimelineItem) { item in
            TimelineEditorView(mode: .edit(item.timeline), groupID: item.groupID)
        }
    }

    @ViewBuilder
    private func timelineRow(group: TimelineGroup, timeline: Timeline) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: timeline.color))
                .frame(width: 10, height: 10)
            Text(timeline.name)
            Text(timeline.type)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color(hex: timeline.color).opacity(0.2))
                .clipShape(Capsule())
        }
        .tag(SidebarSelection.timeline(groupID: group.id, timelineID: timeline.id))
        .contextMenu {
            Button("编辑时间线") {
                editingTimelineItem = EditableTimeline(groupID: group.id, timeline: timeline)
            }
            Divider()
            Button("删除时间线", role: .destructive) {
                store.deleteTimeline(groupID: group.id, timelineID: timeline.id)
            }
        }
    }

    @ViewBuilder
    private func groupHeader(group: TimelineGroup) -> some View {
        HStack {
            Label(group.name, systemImage: "folder")
                .font(.headline)
        }
        .tag(SidebarSelection.group(group.id))
        .contentShape(Rectangle())
        .onTapGesture {
            selection = .group(group.id)
        }
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

struct EditableTimeline: Identifiable {
    let groupID: UUID
    let timeline: Timeline
    var id: UUID { timeline.id }
}
