// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import Foundation
import StdlibUnittest
@testable import SwiftSyntax

var ParseFile = TestSuite("ParseFile")

ParseFile.test("ParseSingleFile") {
  let currentFile = URL(fileURLWithPath: #file)
  do {
    let parsed = try Syntax.parse(currentFile)
    expectNil(parsed)
  } catch {
    expectEqual("", "\(error)")
  }
}

runAllTests()