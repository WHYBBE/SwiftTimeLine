import SwiftUI

@main
struct SwiftTimeLineApp: App {
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
        .commands {
            AppCommands(loc: settings.localization)
        }

        Settings {
            AppEnvironmentRoot {
                SettingsView()
            }
            .environment(store)
            .environment(settings)
        }

        Window(settings.localization(.about), id: AboutView.windowID) {
            AppEnvironmentRoot {
                AboutView()
            }
            .environment(store)
            .environment(settings)
        }
        .windowResizability(.contentSize)
    }
}
