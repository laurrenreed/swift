// swift-tools-version:4.0
//===---------------- Package.swift - Swift Package Manifest --------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLanguage",
    products: [
        .library(
            name: "SwiftLanguage",
            targets: ["SwiftLanguage"]),
    ],
    targets: [
        .target(
            name: "SwiftLanguage",
            dependencies: []),
        .testTarget(
            name: "SwiftLanguageTests",
            dependencies: ["SwiftLanguage"]),
    ]
)
