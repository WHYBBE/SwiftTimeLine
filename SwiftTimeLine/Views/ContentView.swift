import SwiftUI

enum ViewMode: String, CaseIterable {
    case horizontal = "水平"
    case vertical = "垂直"
}

enum SidebarSelection: Hashable {
    case group(UUID)
    case timeline(groupID: UUID, timelineID: UUID)
}

struct ContentView: View {
    @EnvironmentObject var store: DataStore
    @State private var selection: SidebarSelection?
    @State private var viewMode: ViewMode = .horizontal
    @State private var showAddGroup = false
    @State private var showAddTimeline = false
    @State private var showAddEvent = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    Button(action: { showAddTimeline = true }) {
                        Label("新建时间线", systemImage: "plus.circle")
                    }
                }

                if selectedTimelineInfo != nil {
                    Button(action: { showAddEvent = true }) {
                        Label("新建事件", systemImage: "star.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddGroup) {
            GroupEditorView(mode: .add)
        }
        .sheet(isPresented: $showAddTimeline) {
            if let gid = selectedGroupID {
                TimelineEditorView(mode: .add, groupID: gid)
            }
        }
        .sheet(isPresented: $showAddEvent) {
            if let info = selectedTimelineInfo {
                EventEditorView(mode: .add, groupID: info.groupID, timelineID: info.timelineID)
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        if let sel = selection {
            switch sel {
            case .group(let gid):
                if let group = store.groups.first(where: { $0.id == gid }) {
                    switch viewMode {
                    case .horizontal:
                        HorizontalTimelineView(group: group)
                    case .vertical:
                        VerticalTimelineView(group: group)
                    }
                } else {
                    Text("选择一个分组或时间线")
                        .foregroundStyle(.secondary)
                }
            case .timeline(let gid, let tid):
                if let group = store.groups.first(where: { $0.id == gid }),
                   let timeline = group.timelines.first(where: { $0.id == tid }) {
                    let singleGroup = TimelineGroup(id: group.id, name: group.name, timelines: [timeline])
                    switch viewMode {
                    case .horizontal:
                        HorizontalTimelineView(group: singleGroup)
                    case .vertical:
                        VerticalTimelineView(group: singleGroup)
                    }
                } else {
                    Text("选择一个分组或时间线")
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "timeline.selection")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("选择一个分组或时间线来查看")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var selectedGroupID: UUID? {
        switch selection {
        case .group(let id): return id
        case .timeline(let gid, _): return gid
        case nil: return nil
        }
    }

    private var selectedTimelineInfo: (groupID: UUID, timelineID: UUID)? {
        if case .timeline(let gid, let tid) = selection {
            return (gid, tid)
        }
        return nil
    }
}
