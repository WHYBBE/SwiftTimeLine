import SwiftUI

@main
struct SwiftTimeLineApp: App {
    @State private var store = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .frame(minWidth: 800, minHeight: 500)
        }
    }
}
