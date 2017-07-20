//===--------------- SwiftLanguage.swift - Swift Syntax Library -----------===//
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
// This file provides the logic for invoking swiftc to parse Swift files.
//===----------------------------------------------------------------------===//

import Foundation

#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// Finds the dylib or executable which the provided address falls in.
/// - Parameter dsohandle: A pointer to a symbol in the object file you're
///                        looking for. If not provided, defaults to the
///                        caller's `#dsohandle`, which will give you the
///                        object file the caller resides in.
/// - Returns: A File URL pointing to the object where the provided address
///            resides. This may be a dylib, shared object, static library,
///            or executable. If unable to find the appropriate object, returns
///            `nil`.
func findFirstObjectFile(for dsohandle: UnsafeRawPointer = #dsohandle) -> URL? {
  var info = dl_info()
  if dladdr(dsohandle, &info) == 0 {
    return nil
  }
  let path = String(cString: info.dli_fname)
  return URL(fileURLWithPath: path)
}

enum InvocationError: Error {
  case couldNotFindSwiftc
  case abort(code: Int)
}

extension Pipe {
  var stringValue: String {
    let data = fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)!
  }
}

struct SwiftcRunner {
  /// Gets the `swiftc` binary packaged alongside this library.
  /// - Returns: The path to `swiftc` relative to the path of this library
  ///            file, or `nil` if it could not be found.
  /// - Note: This makes assumptions about your Swift installation directory
  ///         structure. Importantly, it assumes that the directory tree is
  ///         shaped like this:
  ///         ```
  ///         install_root/
  ///           - bin/
  ///             - swiftc
  ///           - lib/
  ///             - swift/
  ///               - ${target}/
  ///                 - libswiftSwiftSyntax.[dylib|so]
  ///         ```
  static func locateSwiftc() -> URL? {
    guard let libraryPath = findFirstObjectFile() else { return nil }
    let swiftcURL = libraryPath.deletingLastPathComponent()
                               .deletingLastPathComponent()
                               .deletingLastPathComponent()
                               .deletingLastPathComponent()
                               .appendingPathComponent("bin")
                               .appendingPathComponent("swiftc")
    guard FileManager.default.fileExists(atPath: swiftcURL.path) else {
      return nil
    }
    return swiftcURL
  }

  let swiftcURL: URL

  init() throws {
    guard let url = SwiftcRunner.locateSwiftc() else {
      throw InvocationError.couldNotFindSwiftc
    }
    self.swiftcURL = url
  }

  /// Invokes swiftc with the provided arguments.
  func invoke() -> (stdout: String, stderr: String) {
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    let process = Process()
    process.launchPath = swiftcURL.path
    process.arguments = [
      "-dump-serialized-syntax-tree"
    ]
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe
    process.launch()
    process.waitUntilExit()
    return (stdout: stdoutPipe.stringValue,
            stderr: stderrPipe.stringValue)
  }
}

/// A list of possible errors that could be encountered while parsing a
/// Syntax tree.
public enum ParserError: Error, Equatable {
  case invalidFile
}

extension Syntax {
  /// Parses the Swift file at the provided URL into a full-fidelity `Syntax`
  /// tree.
  /// - Parameter url: The URL you wish to parse.
  /// - Returns: A top-level Syntax node representing the contents of the tree,
  ///            if the parse was successful.
  /// - Throws: `ParseError.couldNotFindSwiftc` if `swiftc` could not be
  ///           located, `ParseError.invalidFile` if the file is invalid.
  ///           FIXME: Fill this out with all error cases.
  public static func parse(_ url: URL) throws -> Syntax {
    let swiftcRunner = try SwiftcRunner()
    let (stdout, stderr) = swiftcRunner.invoke()
    throw ParserError.invalidFile
  }
}
