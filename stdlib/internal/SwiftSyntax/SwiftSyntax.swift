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

func findDylib(dsohandle: UnsafeRawPointer = #dsohandle) -> URL? {
  var info = dl_info()
  if dladdr(dsohandle, &info) == 0 {
    return nil
  }
  let path = String(cString: info.dli_fname)
  return URL(fileURLWithPath: path)
}

func locateSwiftc() -> URL? {
  guard let dylibPath = findDylib() else { return nil }
  let newPath = dylibPath.deletingLastPathComponent()
                         .deletingLastPathComponent()
                         .appendingPathComponent("bin")
                         .appendingPathComponent("swiftc")
  return newPath
}

public enum SyntaxError: Error {
  case couldNotFindSwiftc
  case invalidFile
}

extension Syntax {
  public static func parse(_ url: URL) throws -> Syntax {
    guard let swiftcPath = locateSwiftc() else {
      throw SyntaxError.couldNotFindSwiftc
    }
    throw SyntaxError.invalidFile
  }
}
