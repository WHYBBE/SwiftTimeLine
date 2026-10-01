// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftTimeLine",
    platforms: [
        .macOS(.v14)
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
                "SwiftTimeLine/SwiftTimeLineApp.swift"
            ],
            sources: [
                "SwiftTimeLine",
                "SPM"
            ]
        )
    ]
)
