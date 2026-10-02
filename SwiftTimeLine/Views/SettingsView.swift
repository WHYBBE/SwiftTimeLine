import SwiftUI
import AppKit

struct SettingsView: View {
    @Environment(DataStore.self) private var store
    @Environment(AppSettings.self) private var settings
    @Environment(\.loc) private var loc
    @Environment(\.openWindow) private var openWindow

    @State private var showClearConfirm = false

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label(loc(.general), systemImage: "gearshape") }

            dataTab
                .tabItem { Label(loc(.data), systemImage: "externaldrive") }
        }
        .frame(width: 480, height: 300)
        .alert(loc(.clearDataConfirmTitle), isPresented: $showClearConfirm) {
            Button(loc(.cancel), role: .cancel) {}
            Button(loc(.clear), role: .destructive) { store.clearAll() }
        } message: {
            Text(loc(.clearDataConfirmMessage))
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

    private var generalTab: some View {
        @Bindable var settings = settings
        return Form {
            Section(loc(.appearance)) {
                Picker(loc(.theme), selection: $settings.theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Label(loc(theme.labelKey), systemImage: theme.symbol).tag(theme)
                    }
                }
                .pickerStyle(.segmented)

                Picker(loc(.language), selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(loc(language.labelKey)).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button {
                    openWindow(id: AboutView.windowID)
                } label: {
                    Label(loc(.about), systemImage: "info.circle")
                }
            }
        }
        .formStyle(.grouped)
    }

    private var dataTab: some View {
        Form {
            Section(loc(.dataManagement)) {
                Button {
                    if let data = FilePanels.openJSON() {
                        _ = store.importData(from: data)
                    }
                } label: {
                    Label(loc(.importData), systemImage: "square.and.arrow.down")
                }

                Button {
                    if let data = store.exportAllData() {
                        FilePanels.save(data: data, suggestedName: "SwiftTimeLine.json")
                    }
                } label: {
                    Label(loc(.exportData), systemImage: "square.and.arrow.up")
                }

                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([store.dataFileURL])
                } label: {
                    Label(loc(.revealInFinder), systemImage: "folder")
                }

                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label(loc(.clearData), systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .disabled(store.groups.isEmpty)
            }
        }
        .formStyle(.grouped)
    }
}
