// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import Foundation
import StdlibUnittest
@testable import SwiftSyntax

func cannedStructDecl() -> StructDeclSyntax {
  let fooID = SyntaxFactory.makeIdentifier("Foo", trailingTrivia: .spaces(1))
  let structKW = SyntaxFactory.makeStructKeyword(trailingTrivia: .spaces(1))
  let builder = StructDeclSyntaxBuilder()
  builder.useStructKeyword(structKW)
         .useName(fooID)
         .useLeftBrace(SyntaxFactory.makeLeftBraceToken())
         .useRightBrace(
           SyntaxFactory.makeRightBraceToken(leadingTrivia: .newlines(1)))
  return builder.build()
}

var SyntaxFactoryAPI = TestSuite("SyntaxFactoryAPI")

SyntaxFactoryAPI.test("Generated") {

  let structDecl = cannedStructDecl()

  expectEqual("\(structDecl)",
              """
              struct Foo {
              }
              """)

  let forType = SyntaxFactory.makeIdentifier("for", 
                                             leadingTrivia: .backticks(1),
                                             trailingTrivia: [
                                               .backticks(1), .spaces(1)
                                             ])
  let newBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: .newlines(2))

  let renamed = structDecl.withName(forType)
                          .withRightBrace(newBrace)

  expectEqual("\(renamed)",
              """
              struct `for` {

              }
              """)

  expectNotEqual(structDecl.leftBrace.data, renamed.leftBrace.data)
  expectEqual(structDecl.data, structDecl.root.data)
  expectNil(structDecl.parent)
  expectNotNil(structDecl.leftBrace.parent)
  expectEqual(structDecl.leftBrace.parent?.data, structDecl.data)

  // Ensure that accessing children via named identifiers is exactly the
  // same as accessing them as their underlying data.
  expectEqual(structDecl.leftBrace.data, structDecl.child(at: 7)?.data)
  
  expectEqual("\(structDecl.rightBrace)",
              """

              }
              """)
}

SyntaxFactoryAPI.test("TokenSyntax") {
  let tok = SyntaxFactory.makeStructKeyword()
  expectEqual("\(tok)", "struct")
  expectTrue(tok.isPresent)

  let preSpacedTok = tok.withLeadingTrivia(.spaces(3))
  expectEqual("\(preSpacedTok)", "   struct")

  let postSpacedTok = tok.withTrailingTrivia(.spaces(6))
  expectEqual("\(postSpacedTok)", "struct      ")

  let prePostSpacedTok = preSpacedTok.withTrailingTrivia(.spaces(4))
  expectEqual("\(prePostSpacedTok)", "   struct    ")
}

SyntaxFactoryAPI.test("RoundTripSerialize") {
  let structDecl = cannedStructDecl()
  expectDoesNotThrow({
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(structDecl.raw)
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(RawSyntax.self, from: data)
    expectEqual("\(structDecl.raw)", "\(decoded)")
    expectEqual("\(structDecl)", "\(Syntax.fromRaw(decoded))")
  })
}

runAllTests()