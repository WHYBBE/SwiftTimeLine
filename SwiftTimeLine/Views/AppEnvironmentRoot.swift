import SwiftUI

struct AppEnvironmentRoot<Content: View>: View {
    @Environment(AppSettings.self) private var settings
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environment(\.loc, settings.localization)
            .preferredColorScheme(settings.theme.colorScheme)
    }
}
