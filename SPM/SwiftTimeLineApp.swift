import SwiftUI
import AppKit

@main
struct SwiftTimeLineSPMApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = DataStore()
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            AppEnvironmentRoot {
                ContentView()
                    .frame(minWidth: 800, minHeight: 500)
            }
            .environment(store)
            .environment(settings)
        }

        Settings {
            AppEnvironmentRoot {
                SettingsView()
            }
            .environment(store)
            .environment(settings)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
