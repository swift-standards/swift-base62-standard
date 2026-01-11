// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-base62-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "Base62 Standard", targets: ["Base62 Standard"])
    ],
    dependencies: [
        .package(path: "../swift-incits-4-1986"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
    ],
    targets: [
        .target(
            name: "Base62 Standard",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
            ]
        ),
        .testTarget(
            name: "Base62 Standard Tests",
            dependencies: ["Base62 Standard"]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
