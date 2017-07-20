//===-------------------- Syntax.swift - Syntax Protocol ------------------===//
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

/// A Syntax node represents a tree of nodes with tokens at the leaves.
/// Each node has accessors for its known children, and allows efficient
/// iteration over the children through its `children` property.
public class Syntax: CustomStringConvertible {
  /// The root of the tree this node is currently in.
  internal let _root: SyntaxData
  
  /// The data backing this node.
  /// - note: This is unowned, because the reference to the root data keeps it
  ///         alive. This means there is an implicit relationship -- the data
  ///         property must be a descendent of the root. This relationship must
  ///         be preserved in all circumstances where Syntax nodes are created.
  internal unowned var data: SyntaxData

  internal class var kind: SyntaxKind {
    return .unknown
  }

#if DEBUG
  func validate() {
    // This is for subclasses to override to perform structural validation.
  }
#endif

  /// Creates a Syntax node from the provided root and data.
  internal init(root: SyntaxData, data: SyntaxData) {
    self._root = root
    self.data = data
#if DEBUG
    validate()
#endif
  }

  /// Access the raw syntax assuming the node is a Syntax.
  var raw: RawSyntax {
    return data.raw
  }

  /// An iterator over children of this node.
  public var children: SyntaxChildren {
    return SyntaxChildren(node: self)
  }

  public var isPresent: Bool {
    return raw.presence == .present
  }

  public var isMissing: Bool {
    return raw.presence == .missing
  }

  public var isExpr: Bool {
    return raw.kind.isExpr
  }
  
  public var isDecl: Bool {
    return raw.kind.isDecl
  }

  public var isStmt: Bool {
    return raw.kind.isStmt
  }

  public var isType: Bool {
    return raw.kind.isType
  }

  public var isPattern: Bool {
    return raw.kind.isPattern
  }

  /// The parent of this syntax node, or `nil` if this node is the root.
  public var parent: Syntax? {
    guard let parentData = data.parent else { return nil }
    return Syntax.make(root: _root, data: parentData)
  }

  /// The root of the tree in which this node resides.
  public var root: Syntax {
    return Syntax.make(root: _root,  data: _root)
  }

  /// Prints the raw value of this node to the provided stream.
  /// - Parameter stream: The stream to which to print the raw tree.
  func print<StreamType: TextOutputStream>(to stream: inout StreamType) {
    data.raw.print(to: &stream)
  }
  
  /// Gets the child at the provided index in this node's children.
  /// - Parameter index: The index of the child node you're looking for.
  /// - Returns: A Syntax node for the provided child, or `nil` if there
  ///            is not a child at that index in the node.
  public func child(at index: Int) -> Syntax? {
    guard raw.layout.indices.contains(index) else { return nil }
    if raw.layout[index].isMissing { return nil }
    return Syntax.make(root: _root, data: data.cachedChild(at: index))
  }

  /// A source-accurate description of this node.
  public var description: String {
    var s = ""
    self.print(to: &s)
    return s
  }
}

/// Determines if two nodes are equal to each other.
public func ==<T: Syntax>(lhs: T, rhs: T) -> Bool {
  return lhs.data === rhs.data
}

/// MARK: - Nodes

/// A Syntax node representing a single token.
public class TokenSyntax: Syntax {
  /// The text of the token as written in the source code.
  public var text: String {
    return tokenKind.text
  }

  override internal class var kind: SyntaxKind {
    return .token
  }

  public func withLeadingTrivia(_ leadingTrivia: Trivia) -> TokenSyntax {
    guard case let .token(kind, _, trailingTrivia, presence) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    let (root, newData) = data.replacingSelf(.token(kind, leadingTrivia,
                                                    trailingTrivia, presence))
    return TokenSyntax(root: root, data: newData)
  }

  public func withTrailingTrivia(_ trailingTrivia: Trivia) -> TokenSyntax {
    guard case let .token(kind, leadingTrivia, _, presence) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    let (root, newData) = data.replacingSelf(.token(kind, leadingTrivia,
                                                    trailingTrivia, presence))
    return TokenSyntax(root: root, data: newData)
  }

  public var leadingTrivia: Trivia {
    guard case .token(_, let leadingTrivia, _, _) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    return leadingTrivia
  }

  public var trailingTrivia: Trivia {
    guard case .token(_, _, let trailingTrivia, _) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    return trailingTrivia
  }

  /// The kind of token this node represents.
  public var tokenKind: TokenKind {
    guard case .token(let kind, _, _, _) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    return kind
  }
}
