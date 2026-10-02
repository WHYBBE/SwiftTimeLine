import SwiftUI
import AppKit

struct AboutView: View {
    static let windowID = "about"

    @Environment(\.loc) private var loc
    @Environment(\.dismissWindow) private var dismissWindow

    private var versionText: String {
        if let build = AppInfo.build, !build.isEmpty {
            return "\(loc(.version)) \(AppInfo.version) (\(build))"
        }
        return "\(loc(.version)) \(AppInfo.version)"
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            Text(AppInfo.name)
                .font(.title.bold())

            Text(versionText)
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Link(destination: AppInfo.githubURL) {
                    Label("GitHub", systemImage: "link")
                }
                Link(destination: AppInfo.licenseURL) {
                    Label(loc(.mitLicense), systemImage: "doc.text")
                }
            }
            .font(.callout)
            .padding(.top, 4)

            Text(loc(.licenseNotice))
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button(loc(.close)) { dismissWindow(id: AboutView.windowID) }
                .keyboardShortcut(.cancelAction)
                .padding(.top, 6)
        }
        .padding(28)
        .frame(width: 360)
    }
}

struct AppCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    let loc: Localization

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(loc(.about)) {
                openWindow(id: AboutView.windowID)
            }
        }
    }
}
