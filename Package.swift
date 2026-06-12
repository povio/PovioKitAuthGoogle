// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PovioKitAuthGoogle",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "PovioKitAuthGoogle", targets: ["PovioKitAuthGoogle"])
  ],
  dependencies: [
    .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "9.0.0")),
    .package(url: "https://github.com/povio/PovioKitAuth", .upToNextMajor(from: "3.0.0"))
  ],
  targets: [
    .target(
      name: "PovioKitAuthGoogle",
      dependencies: [
        .product(name: "PovioKitAuthCore", package: "PovioKitAuth"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
      ],
      path: "Sources",
      resources: [.copy("../Resources/PrivacyInfo.xcprivacy")]
    ),
    .testTarget(
      name: "PovioKitAuthGoogleTests",
      dependencies: ["PovioKitAuthGoogle"],
      path: "Tests"
    )
  ]
)
