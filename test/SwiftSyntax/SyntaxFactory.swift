// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import SwiftSyntax
import StdlibUnittest

func cannedStructDecl() -> StructDeclSyntax {
  let keyword = SyntaxFactory.makeToken(kind: .kw_struct,
                                        trailingTrivia: .spaces(1))

  let name = SyntaxFactory.makeToken(kind: .identifier("Foo"),
                                      trailingTrivia: .spaces(1))

  let lBrace = SyntaxFactory.makeToken(kind: .l_brace)

  let members = SyntaxFactory.makeStructDeclMembers(members: [],
                                                    presence: .missing)

  let rBrace = SyntaxFactory.makeToken(kind: .r_brace,
                                       leadingTrivia: .newlines(1))

  return SyntaxFactory.makeStructDecl(structKeyword: keyword,
                                      identifier: name,
                                      leftBrace: lBrace,
                                      members: members,
                                      rightBrace: rBrace)
}

var SyntaxFactoryAPI = TestCase("SyntaxFactoryAPI")

SyntaxFactoryAPI.test("Generated") {

  let structDecl = cannedStructDecl()

  expectEqual("\(structDecl)",
              """
              struct Foo {
              }
              """)

  let bar = SyntaxFactory.makeToken(kind: .identifier("Self"),
                                    leadingTrivia: .backticks(1),
                                    trailingTrivia: [.backticks(1), .spaces(1)])
  let newBrace = SyntaxFactory.makeToken(kind: .r_brace,
                                          leadingTrivia: .newlines(2))

  let renamed = structDecl.withIdentifier(bar)
                          .withRightBrace(newBrace)

  expectEqual("\(renamed)",
              """
              struct `Self` {


              }
              """)

  expectNotEqual(structDecl.leftBrace.data, renamed.leftBrace.data)
  expectEqual(structDecl.data, structDecl.root.data)
  expectNil(structDecl.parent)
  expextNotNil(structDecl.leftBrace.parent)
  expectEqual(structDecl.leftBrace.parent?.data, structDecl.data)

  // Ensure that accessing children via named identifiers is exactly the
  // same as accessing them as their underlying data.
  expectEqual(structDecl.leftBrace.data, structDecl.child(at: 2)?.data)
  
  expectEqual("\(structDecl.rightBrace)",
              """
              

              }
              """)
}


SyntaxFactoryAPI.test("TokenSyntax") {
  let tok = SyntaxFactory.makeToken(kind: .kw_struct)
  expectEqual("\(tok)", "struct")
  expect(tok.isPresent)

  let preSpacedTok = tok.withLeadingTrivia(.spaces(3))
  expectEqual("\(preSpacedTok)", "   struct")

  let postSpacedTok = tok.withTrailingTrivia(.spaces(6))
  expectEqual("\(postSpacedTok)", "struct      ")

  let prePostSpacedTok = preSpacedTok.withTrailingTrivia(.spaces(4))
  expectEqual("\(prePostSpacedTok)", "   struct    ")
}

SyntaxFactoryAPI.test("RoundTripSerialize") {
  let structDecl = cannedStructDecl()
  do {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(structDecl.raw)
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(RawSyntax.self, from: data)
    expectEqual("\(structDecl.raw)", "\(decoded)")
    expectEqual("\(structDecl)", "\(decoded.makeRootSyntax())")
  } catch {
    expectationFailure("failed round-trip encoding struct: \(error)")
  }
}