// swift-tools-version: 6.0
// Builds the platform-independent core (model values, domain logic, catalog loader)
// so the domain tests also run with `swift test`, including on Linux.
// The iOS app itself is built from Opzegwekker.xcodeproj.
import PackageDescription

let package = Package(
    name: "OpzegwekkerCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "OpzegwekkerCore", targets: ["OpzegwekkerCore"])
    ],
    targets: [
        .target(
            name: "OpzegwekkerCore",
            path: ".",
            exclude: [
                "AppStore",
                "Opzegwekker",
                "OpzegwekkerWidget",
                "OpzegwekkerTests",
                "Config",
                "Design",
                "CATALOG_TODO.md",
                "DECISIONS.md",
                "README.md",
                "project.yml",
                "Shared/UI",
                "Shared/Model/Item.swift",
                "Shared/Model/Store.swift",
                "Catalog/CategoryColor.swift",
            ],
            sources: [
                "Shared/Model",
                "Shared/Domain",
                "Catalog/Catalog.swift",
            ],
            resources: [
                .copy("Catalog/services.json")
            ]
        ),
        .testTarget(
            name: "OpzegwekkerTests",
            dependencies: ["OpzegwekkerCore"],
            path: "OpzegwekkerTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
