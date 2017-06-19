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
public protocol Syntax: CustomStringConvertible {
  /// Retrieves the child of this Syntax node at the provied index.
  ///
  /// - Parameter index: The index of the child you're looking for.
  /// - Returns: The child at that provided index, or `nil` if there is no child
  ///            at that index in the node.
  func child(at index: Int) -> Syntax?
  var children: SyntaxChildren { get }
}

/// The underlying data representation of syntax nodes inside this library.
internal protocol _SyntaxBase: Syntax {
  /// The root of the tree this node is currently in.
  var root: SyntaxData { get }
  
  /// The data backing this node.
  /// - note: This is unowned, because the reference to the root data keeps it
  ///         alive. This means there is an implicit relationship -- the data
  ///         property must be a descendent of the root. This relationship must
  ///         be preserved in all circumstances where Syntax nodes are created.
  unowned var data: SyntaxData { get }

  /// Creates a _SyntaxBase node from the provided root and data.
  init(root: SyntaxData, data: SyntaxData)
}

extension Syntax {
  /// Access the data, assuming the node is a _SyntaxBase.
  var data: SyntaxData {
    guard let base = self as? _SyntaxBase else {
      fatalError("Consumers of libSyntax must not conform to the Syntax protocol")
    }
    return base.data
  }

  /// Access the root, assuming the node is a _SyntaxBase.
  var rootData: SyntaxData {
    guard let base = self as? _SyntaxBase else {
      fatalError("Consumers of libSyntax must not conform to the Syntax protocol")
    }
    return base.root
  }

  /// Access the raw syntax assuming the node is a _SyntaxBase.
  var raw: RawSyntax {
    return data.raw
  }

  public var children: SyntaxChildren {
    return SyntaxChildren(node: self)
  }

  /// The parent of this syntax node, or `nil` if this node is the root.
  public var parent: Syntax? {
    guard let parentData = data.parent else { return nil }
    return parentData.raw.kind.syntaxType.init(root: rootData, data: parentData)
  }

  /// The root of the tree in which this node resides.
  public var root: Syntax {
    let rootData = self.rootData
    return rootData.raw.kind.syntaxType.init(root: rootData, data: rootData)
  }
}

extension _SyntaxBase {
  /// Accesses the raw syntax underlying this node.
  var raw: RawSyntax {
    return data.raw
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
    return raw.layout[index].makeSyntax(root: root, indexInParent: index,
                                        parent: data)
  }

  /// A source-accurate description of this node.
  public var description: String {
    var s = ""
    self.print(to: &s)
    return s
  }
}

/// Determines if two nodes are equal to each other.
func ==(lhs: _SyntaxBase, rhs: _SyntaxBase) -> Bool {
  return lhs.data === rhs.data
}

/// A Syntax node that knows nothing about its underlying structure. Its
/// children will be dynamically created on request, so it can be iterated over
/// and queried as an opaque node.
public struct UnknownSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned let data: SyntaxData
}

/// MARK: - Nodes

/// A Syntax node representing a Swift `struct` declaration.
public struct StructDeclSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned let data: SyntaxData

  /// The token for the `struct` keyword.
  public var structKeyword: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.structKeyword))
  }

  /// The name of this `struct`.
  public var identifier: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.identifierToken))
  }

  /// The token for the left brace that opens this `struct`.
  public var leftBrace: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.leftBraceToken))
  }

  /// The declaration members for this `struct`.
  public var members: StructDeclMembersSyntax {
    return StructDeclMembersSyntax(root: root,
                                   data: data.cachedChild(at: Cursor.members))
  }

  /// The token for the right brace that closes this `struct`.
  public var rightBrace: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.rightBraceToken))
  }

  /// Constructs a new `StructDeclSyntax` with the `structKeyword` replaced
  /// with the provided `TokenSyntax`.
  /// - Parameter keyword: The new `structKeyword` token.
  public func withStructKeyword(_ keyword: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(keyword.raw,
                                              at: Cursor.structKeyword)
    return StructDeclSyntax(root: root, data: newData)
  }

  /// Constructs a new `StructDeclSyntax` with the `identifier` replaced
  /// with the provided `TokenSyntax`.
  /// - Parameter keyword: The new `identifier` token.
  public func withIdentifier(_ identifier: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(identifier.raw,
                                              at: Cursor.identifierToken)
    return StructDeclSyntax(root: root, data: newData)
  }

  /// Constructs a new `StructDeclSyntax` with the `leftBrace` replaced
  /// with the provided `TokenSyntax`.
  /// - Parameter keyword: The new `leftBrace` token.
  public func withLeftBrace(_ token: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(token.raw,
                                              at: Cursor.leftBraceToken)
    return StructDeclSyntax(root: root, data: newData)
  }

  public func withMembers(_ members: StructDeclMembersSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(members.raw,
                                              at: Cursor.members)
    return StructDeclSyntax(root: root, data: newData)
  }


  /// Constructs a new `StructDeclSyntax` with the `rightBrace` replaced
  /// with the provided `TokenSyntax`.
  /// - Parameter keyword: The new `rightBrace` token.
  public func withRightBrace(_ token: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(token.raw,
                                              at: Cursor.rightBraceToken)
    return StructDeclSyntax(root: root, data: newData)
  }

  /// A cursor into the different children of this node, in order.
  enum Cursor: Int {
    case structKeyword
    case identifierToken
    case leftBraceToken
    case members
    case rightBraceToken
  }
}

/// A Syntax node representing the members of a Swift `struct` declaration.
public struct StructDeclMembersSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned var data: SyntaxData
}

/// A Syntax node representing a single token.
public struct TokenSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned var data: SyntaxData

  /// The text of the token as written in the source code.
  public var text: String {
    guard case .token(let kind, _, _, _) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    return kind.text
  }
}
