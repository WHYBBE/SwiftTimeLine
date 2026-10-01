import SwiftUI

enum LKey: String {
    // App / Settings
    case settings = "Settings"
    case general = "General"
    case appearance = "Appearance"
    case theme = "Theme"
    case themeSystem = "System"
    case themeLight = "Light"
    case themeDark = "Dark"
    case language = "Language"
    case languageSystem = "Follow System"
    case languageChinese = "简体中文"
    case languageEnglish = "English"
    case data = "Data"
    case dataManagement = "Data Management"
    case importData = "Import Data…"
    case exportData = "Export Data…"
    case clearData = "Clear All Data…"
    case clearDataConfirmTitle = "Clear All Data?"
    case clearDataConfirmMessage = "This will permanently delete all groups, events, and tags. This action cannot be undone."
    case clear = "Clear"
    case cancel = "Cancel"
    case done = "Done"
    case ok = "OK"
    case error = "Error"
    case loadFailed = "Failed to load: %@"
    case saveFailed = "Failed to save: %@"

    // Statistics
    case statistics = "Statistics"
    case totalEvents = "Total Events"
    case totalTags = "Total Tags"
    case eventsPerMonth = "Events per Month"
    case eventsPerTag = "Events per Tag"
    case close = "Close"

    // Date range
    case dateRange = "Date Range"
    case dateAll = "All Time"
    case dateLast3Months = "Last 3 Months"
    case dateLastYear = "Last Year"
    case dateThisYear = "This Year"

    // Zoom
    case fitToWidth = "Fit to Width"
    case resetZoom = "Reset Zoom"

    // Sort
    case sortOrder = "Sort Order"
    case sortAscending = "Oldest First"
    case sortDescending = "Newest First"

    // Event extras
    case endDate = "End date"
    case location = "Location"
    case locationPlaceholder = "Add a location"
    case link = "Link"
    case linkPlaceholder = "https://…"
    case pinEvent = "Pin event"

    // Export
    case exportImage = "Export as Image…"
    case exportPDF = "Export as PDF…"

    // View mode / toolbar
    case vertical = "Vertical"
    case horizontal = "Horizontal"
    case viewModeLabel = "View"
    case newGroup = "New Group"
    case newEvent = "New Event"
    case manageTags = "Manage Tags"
    case exportGroup = "Export Group…"

    // Sidebar
    case editGroup = "Edit Group"
    case deleteGroup = "Delete Group"

    // Content
    case selectGroupPrompt = "Select a group to view"
    case editEventPrompt = "Click an event to edit, or create a new event"
    case uncategorized = "Uncategorized"
    case noEvents = "No events"
    case filter = "Filter:"
    case tags = "Tags"

    // Event editor
    case editEvent = "Edit Event"
    case title = "Title"
    case eventTitlePlaceholder = "Event title"
    case description = "Description"
    case date = "Date"
    case includeTime = "Include time"
    case color = "Color"
    case createdAt = "Created at %@"
    case modifiedAt = "Modified at %@"
    case noTagsHint = "No tags yet. Create them in \"Manage Tags\" first."
    case delete = "Delete"
    case save = "Save"
    case create = "Create"

    // Tag manager
    case addNewTag = "Add New Tag"
    case tagNamePlaceholder = "Tag name"
    case add = "Add"
    case editTag = "Edit Tag"
    case name = "Name"

    // Group editor
    case groupNamePlaceholder = "Group name"
    case icon = "Icon"
    case resetToDefault = "Reset to Default"
    case emoji = "Emoji"

    // Color
    case randomColor = "Random color"
}

struct Localization: Equatable {
    var language: AppLanguage

    func callAsFunction(_ key: LKey) -> String {
        switch language {
        case .chinese:
            return Self.chinese[key] ?? key.rawValue
        case .english, .system:
            return key.rawValue
        }
    }

    func format(_ key: LKey, _ args: CVarArg...) -> String {
        String(format: callAsFunction(key), arguments: args)
    }

    private static let chinese: [LKey: String] = [
        .settings: "设置",
        .general: "通用",
        .appearance: "外观",
        .theme: "主题",
        .themeSystem: "跟随系统",
        .themeLight: "浅色",
        .themeDark: "深色",
        .language: "语言",
        .languageSystem: "跟随系统",
        .data: "数据",
        .dataManagement: "数据管理",
        .importData: "导入数据…",
        .exportData: "导出数据…",
        .clearData: "清空全部数据…",
        .clearDataConfirmTitle: "清空全部数据？",
        .clearDataConfirmMessage: "将永久删除所有分组、事件和标签。此操作无法撤销。",
        .clear: "清空",
        .cancel: "取消",
        .done: "完成",
        .ok: "好",
        .error: "出错了",
        .loadFailed: "加载失败：%@",
        .saveFailed: "保存失败：%@",

        .statistics: "统计",
        .totalEvents: "事件总数",
        .totalTags: "标签数",
        .eventsPerMonth: "每月事件数",
        .eventsPerTag: "各标签事件数",
        .close: "关闭",

        .dateRange: "时间范围",
        .dateAll: "全部时间",
        .dateLast3Months: "近三个月",
        .dateLastYear: "近一年",
        .dateThisYear: "今年",

        .fitToWidth: "适配宽度",
        .resetZoom: "重置缩放",

        .sortOrder: "排序方式",
        .sortAscending: "正序（旧→新）",
        .sortDescending: "倒序（新→旧）",

        .endDate: "结束日期",
        .location: "地点",
        .locationPlaceholder: "添加地点",
        .link: "链接",
        .linkPlaceholder: "https://…",
        .pinEvent: "置顶事件",

        .exportImage: "导出为图片…",
        .exportPDF: "导出为 PDF…",

        .vertical: "垂直",
        .horizontal: "水平",
        .viewModeLabel: "视图",
        .newGroup: "新建分组",
        .newEvent: "新建事件",
        .manageTags: "管理标签",
        .exportGroup: "导出分组…",

        .editGroup: "编辑分组",
        .deleteGroup: "删除分组",

        .selectGroupPrompt: "选择一个分组来查看",
        .editEventPrompt: "点击事件编辑，或新建事件",
        .uncategorized: "未分类",
        .noEvents: "暂无事件",
        .filter: "筛选:",
        .tags: "标签",

        .editEvent: "编辑事件",
        .title: "标题",
        .eventTitlePlaceholder: "事件标题",
        .description: "描述",
        .date: "日期",
        .includeTime: "包含时间",
        .color: "颜色",
        .createdAt: "创建于 %@",
        .modifiedAt: "修改于 %@",
        .noTagsHint: "暂无标签，请先在「管理标签」中创建",
        .delete: "删除",
        .save: "保存",
        .create: "创建",

        .addNewTag: "添加新标签",
        .tagNamePlaceholder: "标签名称",
        .add: "添加",
        .editTag: "编辑标签",
        .name: "名称",

        .groupNamePlaceholder: "分组名称",
        .icon: "图标",
        .resetToDefault: "重置为默认",
        .emoji: "Emoji",

        .randomColor: "随机颜色",
    ]
}

private struct LocalizationKey: EnvironmentKey {
    static let defaultValue = Localization(language: .english)
}

extension EnvironmentValues {
    var loc: Localization {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}
