//===------------------- SyntaxWalker.swift - Syntax Walker ---------------===//
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

import Foundation

/// A base class that provides a concrete "walker" that recursively visits
/// syntax nodes. Each visitor will return a new node that will take the place
/// of the original node in the syntax tree. Subclasses can override however
/// many visitors they want, though they should take care to ensure their
/// visitors visit all children.
class SyntaxWalker {
  func visitStructDeclSyntax(_ syntax: StructDeclSyntax) -> StructDeclSyntax {
    return visitChildren(syntax)
  }

  func visitStructDeclMembersSyntax(_ syntax: StructDeclMembersSyntax) -> StructDeclMembersSyntax {
    return visitChildren(syntax)
  }

  func visitTokenSyntax(_ syntax: TokenSyntax) -> TokenSyntax {
    return visitChildren(syntax)
  }

  func visitUnknownSyntax(_ syntax: UnknownSyntax) -> UnknownSyntax {
    return visitChildren(syntax)
  }

  /// Visits each of the children in this node and constructs a new node with
  /// the children replaced.
  func visitChildren<T: _SyntaxBase>(_ syntax: T) -> T {
    let children = syntax.children.map { visitSyntax($0) }
    let raw = syntax.raw.replacingLayout(children.map { $0.raw })
    let (root, data) = syntax.data.replacingSelf(raw)
    return T.init(root: root, data: data)
  }

  func visitSyntax(_ syntax: Syntax) -> Syntax {
    switch syntax {
    case let syntax as StructDeclSyntax:
      return visitStructDeclSyntax(syntax)
    case let syntax as StructDeclMembersSyntax:
      return visitStructDeclMembersSyntax(syntax)
    case let syntax as TokenSyntax:
      return visitTokenSyntax(syntax)
    case let syntax as UnknownSyntax:
      return visitUnknownSyntax(syntax)
    default:
      fatalError("unhandled syntax: \(syntax)")
    }
  }
}
