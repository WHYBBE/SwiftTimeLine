// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftTimeLine",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "SwiftTimeLine", targets: ["SwiftTimeLine"])
    ],
    targets: [
        .executableTarget(
            name: "SwiftTimeLine",
            path: ".",
            exclude: [
                "SwiftTimeLine.xcodeproj",
                "SwiftTimeLine/SwiftTimeLineApp.swift",
                "SwiftTimeLine/Assets.xcassets"
            ],
            sources: [
                "SwiftTimeLine",
                "SPM"
            ]
        )
    ]
)
