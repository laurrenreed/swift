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

    // Ensure that accessing children via named identifiers is exactly the
    // same as accessing them as their underlying data.
    XCTAssertEqual(structDecl.leftBrace.data, structDecl.child(at: 2)?.data)
    
    XCTAssertEqual("\(structDecl.leftBrace)",
                   """
                   {
                   
                   """)
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

  static var allTests: [(String, (SwiftLanguageTests) -> () -> Void)] = [
    ("testAtomicCachePathological", testAtomicCachePathological),
    ("testAtomicCacheTwoAccesses", testAtomicCacheTwoAccesses),
    ("testGenerated", testGenerated),
    ("testRoundTripSerialize", testRoundTripSerialize),
  ]
}
