//===----------- SwiftLanguageTests.swift - Tests for libSyntax -----------===//
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

import XCTest
@testable import SwiftLanguage

class Foo: CustomStringConvertible, Equatable {
  static func ==(lhs: Foo, rhs: Foo) -> Bool {
    return lhs === rhs
  }

  var description: String {
    return ObjectIdentifier(self).debugDescription
  }
}

class SwiftLanguageTests: XCTestCase {
  
  func testAtomicCachePathological() {
    let cache = AtomicCache<Foo>()

    DispatchQueue.concurrentPerform(iterations: 10000) { _ in
      XCTAssertEqual(cache.value(Foo.init), cache.value(Foo.init))
    }
  }

  func testAtomicCacheTwoAccesses() {
    let cache = AtomicCache<Foo>()

    let queue1 = DispatchQueue(label: "queue1")
    let queue2 = DispatchQueue(label: "queue2")

    var d1: Foo?
    var d2: Foo?

    let group = DispatchGroup()
    queue1.async(group: group) {
      d1 = cache.value(Foo.init)
    }
    queue2.async(group: group) {
      d2 = cache.value(Foo.init)
    }
    group.wait()

    let final = cache.value(Foo.init)

    XCTAssertNotNil(d1)
    XCTAssertNotNil(d2)
    XCTAssertEqual(d1, d2)
    XCTAssertEqual(d1, final)
  }

  func makeStructDecl() -> StructDeclSyntax {
    let keyword = SyntaxFactory.makeToken(kind: .kw_struct,
                                          trailingTrivia: .spaces(1))

    let name = SyntaxFactory.makeToken(kind: .identifier("Foo"),
                                       trailingTrivia: .spaces(1))

    let lBrace = SyntaxFactory.makeToken(kind: .l_brace,
                                         trailingTrivia: .newlines(1))

    let members = SyntaxFactory.makeStructDeclMembers(members: [],
                                                      presence: .missing)

    let rBrace = SyntaxFactory.makeToken(kind: .r_brace)

    return SyntaxFactory.makeStructDecl(structKeyword: keyword,
                                        identifier: name,
                                        leftBrace: lBrace,
                                        members: members,
                                        rightBrace: rBrace)
  }

  func testGenerated() {

    let structDecl = makeStructDecl()

    XCTAssertEqual("\(structDecl)",
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

    XCTAssertEqual("\(renamed)",
                   """
                   struct `Self` {


                   }
                   """)

    XCTAssertNotEqual(structDecl.leftBrace.data, renamed.leftBrace.data)

    XCTAssertEqual(structDecl.data, structDecl.root.data)

    XCTAssertNil(structDecl.parent)

    XCTAssertNotNil(structDecl.leftBrace.parent)

    XCTAssertEqual(structDecl.leftBrace.parent?.data, structDecl.data)

    // Ensure that accessing children via named identifiers is exactly the
    // same as accessing them as their underlying data.
    XCTAssertEqual(structDecl.leftBrace.data, structDecl.child(at: 2)?.data)
    
    XCTAssertEqual("\(structDecl.leftBrace)",
                   """
                   {
                   
                   """)
  }

  func testWalker() {
    class TestWalker: SyntaxWalker {
      override func visitTokenSyntax(_ syntax: TokenSyntax) -> TokenSyntax {
        if case .identifier(let name) = syntax.tokenKind {
          return SyntaxFactory.makeToken(kind: .identifier("New\(name)"))
        }
        return syntax
      }
    }

    let struct1 = makeStructDecl()
    let struct2 = makeStructDecl()
      .withIdentifier(SyntaxFactory.makeToken(kind: .identifier("Bar")))

    let walker = TestWalker()
    let visited1 = walker.visitStructDeclSyntax(struct1)
    let visited2 = walker.visitStructDeclSyntax(struct2)

    XCTAssertEqual(visited1.identifier.text, "NewFoo")
    XCTAssertEqual(visited2.identifier.text, "NewBar")
  }

  func testRoundTripSerialize() {
    let structDecl = makeStructDecl()
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let data = try encoder.encode(structDecl.raw)
      let decoder = JSONDecoder()
      let decoded = try decoder.decode(RawSyntax.self, from: data)
      XCTAssertEqual("\(structDecl.raw)", "\(decoded)")
      XCTAssertEqual("\(structDecl)", "\(decoded.makeRootSyntax())")
    } catch {
      XCTFail("\(error)")
    }
  }

  func testTokenSyntax() {
    let tok = SyntaxFactory.makeToken(kind: .kw_struct)
    XCTAssertEqual("\(tok)", "struct")
    XCTAssert(tok.isPresent)

    let preSpacedTok = tok.withLeadingTrivia(.spaces(3))
    XCTAssertEqual("\(preSpacedTok)", "   struct")

    let postSpacedTok = tok.withTrailingTrivia(.spaces(6))
    XCTAssertEqual("\(postSpacedTok)", "struct      ")

    let prePostSpacedTok = preSpacedTok.withTrailingTrivia(.spaces(4))
    XCTAssertEqual("\(prePostSpacedTok)", "   struct    ")
  }

  static var allTests: [(String, (SwiftLanguageTests) -> () -> Void)] = [
    ("testAtomicCachePathological", testAtomicCachePathological),
    ("testAtomicCacheTwoAccesses", testAtomicCacheTwoAccesses),
    ("testGenerated", testGenerated),
    ("testWalker", testWalker),
    ("testTokenSyntax", testTokenSyntax),
    ("testRoundTripSerialize", testRoundTripSerialize),
  ]
}
