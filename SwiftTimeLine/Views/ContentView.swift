import SwiftUI

enum ViewMode: String, CaseIterable {
    case vertical = "垂直"
    case horizontal = "水平"
}

struct ContentView: View {
    @Environment(DataStore.self) private var store
    @State private var selectedGroupID: UUID?
    @State private var viewMode: ViewMode = .vertical
    @State private var showAddGroup = false
    @State private var showTagManager = false
    @State private var activeTagIDs: Set<UUID> = []
    @State private var editingEvent: TimelineEvent?
    @State private var isAddingEvent = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedGroupID: $selectedGroupID)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            mainArea
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("视图", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)

                Button(action: { showAddGroup = true }) {
                    Label("新建分组", systemImage: "folder.badge.plus")
                }

                if selectedGroupID != nil {
                    Button(action: {
                        editingEvent = nil
                        isAddingEvent = true
                    }) {
                        Label("新建事件", systemImage: "star.circle")
                    }

                    Button(action: { showTagManager = true }) {
                        Label("管理标签", systemImage: "tag")
                    }

                    Button(action: {
                        store.exportGroupToFile(id: selectedGroupID!)
                    }) {
                        Label("导出分组", systemImage: "square.and.arrow.up")
                    }
                }

                Button(action: {
                    store.importGroupFromFile()
                }) {
                    Label("导入", systemImage: "square.and.arrow.down")
                }

                Button(action: {
                    store.exportAllDataToFile()
                }) {
                    Label("导出全部", systemImage: "arrow.up.doc")
                }
            }
        }
        .sheet(isPresented: $showAddGroup) {
            GroupEditorView(mode: .add)
        }
        .sheet(isPresented: $showTagManager) {
            if let gid = selectedGroupID {
                TagManagerView(groupID: gid)
            }
        }
        .onChange(of: selectedGroupID) {
            editingEvent = nil
            isAddingEvent = false
            activeTagIDs.removeAll()
        }
    }

    @ViewBuilder
    private var mainArea: some View {
        if let gid = selectedGroupID,
           let group = store.groups.first(where: { $0.id == gid }) {
            HStack(spacing: 0) {
                // Left: timeline view
                VStack(spacing: 0) {
                    tagFilterBar(group: group)
                    Divider()

                    let filtered = store.filteredEvents(in: group, byTagIDs: activeTagIDs)
                    let filteredGroup = TimelineGroup(id: group.id, name: group.name, tags: group.tags, events: filtered)

                    switch viewMode {
                    case .horizontal:
                        HorizontalTimelineView(group: filteredGroup) { event in
                            isAddingEvent = false
                            editingEvent = event
                        }
                    case .vertical:
                        VerticalTimelineView(group: filteredGroup) { event in
                            isAddingEvent = false
                            editingEvent = event
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Divider()

                // Right: event editor panel
                eventEditorPanel(groupID: gid)
                    .frame(width: 320)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "timeline.selection")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("选择一个分组来查看")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func eventEditorPanel(groupID: UUID) -> some View {
        if isAddingEvent {
            EventEditorView(
                mode: .add,
                groupID: groupID,
                onDone: {
                    isAddingEvent = false
                },
                onDelete: nil
            )
        } else if let event = editingEvent {
            EventEditorView(
                mode: .edit(event),
                groupID: groupID,
                onDone: {
                    editingEvent = nil
                },
                onDelete: {
                    store.deleteEvent(groupID: groupID, eventID: event.id)
                    editingEvent = nil
                }
            )
            .id(event.id)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("点击事件编辑，或新建事件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func tagFilterBar(group: TimelineGroup) -> some View {
        if !group.tags.isEmpty {
            HStack(spacing: 6) {
                Text("筛选:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(group.tags) { tag in
                    tagChip(tag: tag)
                }

                if !activeTagIDs.isEmpty {
                    Button(action: { activeTagIDs.removeAll() }) {
                        Text("清除")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func tagChip(tag: Tag) -> some View {
        let isActive = activeTagIDs.contains(tag.id)
        Button(action: {
            if activeTagIDs.contains(tag.id) {
                activeTagIDs.remove(tag.id)
            } else {
                activeTagIDs.insert(tag.id)
            }
        }) {
            Text(tag.name)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isActive ? Color(hex: tag.color).opacity(0.3) : Color.secondary.opacity(0.1))
                .foregroundStyle(isActive ? Color(hex: tag.color) : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(
                        isActive ? Color(hex: tag.color) : Color.clear,
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.borderless)
    }
}
