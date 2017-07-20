// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import Foundation
import StdlibUnittest
@testable import SwiftSyntax

var ParseFile = TestSuite("ParseFile")

ParseFile.test("RunSwiftc") {
  var stdout = "", stderr = ""
  expectDoesNotThrow({
    let swiftcRunner = try SwiftcRunner()
    (stdout, stderr) = swiftcRunner.invoke()
  })
  expectEqual(stdout, "")
  expectEqual(stderr, "")
}

ParseFile.test("ParseSingleFile") {
  expectThrows(ParserError.invalidFile, {
    let currentFile = URL(fileURLWithPath: #file)
    let parse = try Syntax.parse(currentFile)
    print(parse)
  })
}

runAllTests()