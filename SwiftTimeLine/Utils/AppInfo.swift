import Foundation

enum AppInfo {
    static let name = "SwiftTimeLine"

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var build: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    static let githubURL = URL(string: "https://github.com/WHYBBE/SwiftTimeLine")!
    static let licenseURL = URL(string: "https://github.com/WHYBBE/SwiftTimeLine/blob/main/LICENSE")!
    static let licenseName = "MIT"
}
