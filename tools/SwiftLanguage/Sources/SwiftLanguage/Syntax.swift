import Foundation

public protocol Syntax: CustomStringConvertible {
 func child(at index: Int) -> Syntax?
}

/// A Syntax node represents a tree-like 
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

  /// Access the raw syntax assuming the node is a _SyntaxBase.
  var raw: RawSyntax {
    return data.raw
  }
}

extension _SyntaxBase {
  var raw: RawSyntax {
    return data.raw
  }
  
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

  /// Determines if two nodes are equal to each other.
  public static func ==(lhs: _SyntaxBase, rhs: _SyntaxBase) -> Bool {
    return lhs.data === rhs.data
  }

  /// A source-accurate description of this node.
  public var description: String {
    var s = ""
    self.print(to: &s)
    return s
  }
}

public struct UnknownSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned let data: SyntaxData
}

/// MARK: - Nodes

public struct StructDeclSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned let data: SyntaxData

  public var structKeyword: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.structKeyword))
  }

  public var identifier: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.identifierToken))
  }

  public var leftBrace: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.leftBraceToken))
  }

  public var members: StructDeclMembersSyntax {
    return StructDeclMembersSyntax(root: root,
                                   data: data.cachedChild(at: Cursor.members))
  }

  public var rightBrace: TokenSyntax {
    return TokenSyntax(root: root,
                       data: data.cachedChild(at: Cursor.rightBraceToken))
  }

  public func withStructKeyword(_ keyword: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(keyword.raw,
                                              at: Cursor.structKeyword)
    return StructDeclSyntax(root: root, data: newData)
  }

  public func withIdentifier(_ identifier: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(identifier.raw,
                                              at: Cursor.identifierToken)
    return StructDeclSyntax(root: root, data: newData)
  }

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

  public func withRightBrace(_ token: TokenSyntax) -> StructDeclSyntax {
    let (root, newData) = data.replacingChild(token.raw,
                                              at: Cursor.rightBraceToken)
    return StructDeclSyntax(root: root, data: newData)
  }

  enum Cursor: Int {
    case structKeyword
    case identifierToken
    case leftBraceToken
    case members
    case rightBraceToken
  }
}

public struct StructDeclMembersSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned var data: SyntaxData
}

public struct TokenSyntax: _SyntaxBase {
  let root: SyntaxData
  unowned var data: SyntaxData
  
  public var text: String {
    guard case .token(let kind, _, _, _) = raw else {
      fatalError("TokenSyntax must have token as its raw")
    }
    return kind.text
  }
}
