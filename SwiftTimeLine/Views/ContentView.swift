import SwiftUI

enum ViewMode: String, CaseIterable {
    case vertical
    case horizontal

    var labelKey: LKey {
        switch self {
        case .vertical: .vertical
        case .horizontal: .horizontal
        }
    }

    var symbol: String {
        switch self {
        case .vertical: "arrow.up.and.down"
        case .horizontal: "arrow.left.and.right"
        }
    }
}

struct ContentView: View {
    @Environment(DataStore.self) private var store
    @Environment(AppSettings.self) private var settings
    @Environment(\.loc) private var loc
    @State private var selectedGroupID: UUID?
    @State private var viewMode: ViewMode = .vertical
    @State private var showAddGroup = false
    @State private var showTagManager = false
    @State private var activeTagIDs: Set<UUID> = []
    @State private var dateFilter: DateFilter = .all
    @State private var editingEvent: TimelineEvent?
    @State private var isAddingEvent = false
    @State private var showStatistics = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedGroupID: $selectedGroupID)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            mainArea
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker(loc(.viewModeLabel), selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.symbol)
                            .help(loc(mode.labelKey))
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 88)

                Button(action: { showAddGroup = true }) {
                    Label(loc(.newGroup), systemImage: "folder.badge.plus")
                }

                if selectedGroupID != nil {
                    Button(action: { showStatistics = true }) {
                        Label(loc(.statistics), systemImage: "chart.bar")
                    }
                }

                SettingsLink {
                    Label(loc(.settings), systemImage: "gearshape")
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
        .sheet(isPresented: $showStatistics) {
            if let gid = selectedGroupID,
               let group = store.groups.first(where: { $0.id == gid }) {
                StatisticsView(group: group)
            }
        }
        .onChange(of: selectedGroupID) {
            editingEvent = nil
            isAddingEvent = false
            activeTagIDs.removeAll()
            showStatistics = false
        }
        .alert(loc(.error), isPresented: Binding(
            get: { store.lastError != nil },
            set: { if !$0 { store.lastError = nil } }
        )) {
            Button(loc(.ok)) { store.lastError = nil }
        } message: {
            if let error = store.lastError {
                Text(loc.format(error.key, error.detail))
            }
        }
    }

    @ViewBuilder
    private var mainArea: some View {
        if let gid = selectedGroupID,
           let group = store.groups.first(where: { $0.id == gid }) {
            HStack(spacing: 0) {
                // Left: timeline view
                VStack(spacing: 0) {
                    timelineHeaderBar(group: group)
                    Divider()

                    filterSection(group: group)
                    Divider()

                    let filteredGroup = group
                        .filtered(by: dateFilter)
                        .filtered(byTagIDs: activeTagIDs)
                        .sorted(ascending: settings.sortAscending(for: group.id))

                    switch viewMode {
                    case .horizontal:
                        HorizontalTimelineView(group: filteredGroup) { event in
                            isAddingEvent = false
                            editingEvent = event
                        }
                    case .vertical:
                        VerticalTimelineView(
                            group: filteredGroup,
                            ascending: settings.sortAscending(for: group.id)
                        ) { event in
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
                Text(loc(.selectGroupPrompt))
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
                Text(loc(.editEventPrompt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func timelineHeaderBar(group: TimelineGroup) -> some View {
        HStack(spacing: 8) {
            GroupIconView(
                emoji: group.emoji,
                symbol: group.symbol,
                color: Color(hex: group.color),
                size: 20
            )
            Text(group.name)
                .font(.title2.bold())
            Spacer()
            Button(action: {
                editingEvent = nil
                isAddingEvent = true
            }) {
                Label(loc(.newEvent), systemImage: "plus")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func filterSection(group: TimelineGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                sortPicker(groupID: group.id)
                dateFilterMenu
                Spacer()
                manageTagsButton
            }

            if !group.tags.isEmpty {
                HStack(spacing: 6) {
                    Text(loc(.filter))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(group.tags) { tag in
                        tagChip(tag: tag)
                    }

                    if !activeTagIDs.isEmpty {
                        Button(action: { activeTagIDs.removeAll() }) {
                            Text(loc(.clear))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func sortPicker(groupID: UUID) -> some View {
        Picker(loc(.sortOrder), selection: sortBinding(groupID: groupID)) {
            Image(systemName: "arrow.up")
                .help(loc(.sortAscending))
                .tag(true)
            Image(systemName: "arrow.down")
                .help(loc(.sortDescending))
                .tag(false)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 72)
        .help(loc(.sortOrder))
    }

    private var dateFilterMenu: some View {
        Menu {
            Picker(loc(.dateRange), selection: $dateFilter) {
                ForEach(DateFilter.allCases) { filter in
                    Label(loc(filter.labelKey), systemImage: filter.symbol).tag(filter)
                }
            }
        } label: {
            Label(loc(dateFilter.labelKey), systemImage: "line.3.horizontal.decrease.circle")
                .font(.caption)
        }
        .fixedSize()
        .help(loc(.dateRange))
    }

    private var manageTagsButton: some View {
        Button(action: { showTagManager = true }) {
            Label(loc(.manageTags), systemImage: "tag")
                .font(.caption)
        }
        .buttonStyle(.borderless)
        .help(loc(.manageTags))
    }

    private func sortBinding(groupID: UUID) -> Binding<Bool> {
        Binding(
            get: { settings.sortAscending(for: groupID) },
            set: { settings.setSortAscending($0, for: groupID) }
        )
    }

    @ViewBuilder
    private func tagChip(tag: Tag) -> some View {
        Button(action: {
            if activeTagIDs.contains(tag.id) {
                activeTagIDs.remove(tag.id)
            } else {
                activeTagIDs.insert(tag.id)
            }
        }) {
            TagChip(tag: tag, isActive: activeTagIDs.contains(tag.id))
        }
        .buttonStyle(.borderless)
    }
}
