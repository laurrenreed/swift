//===----------------- SyntaxFactory.swift - Syntax Factory ---------------===//
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

public enum SyntaxFactory {

  /// Creates a node from the raw representation given a contextual type.
  ///
  /// - Parameter raw: The raw value underlying the node.
  /// - Returns: A Syntax node of the provided contextual type with the provided
  ///            raw as its layout.
  internal static func fromRaw<SyntaxType: _SyntaxBase>(_ raw: RawSyntax) -> SyntaxType {
    let data = SyntaxData(raw: raw, parent: nil)
    return SyntaxType.init(root: data, data: data)
  }

  public static func makeStructDecl(structKeyword: TokenSyntax,
                                    identifier: TokenSyntax,
                                    leftBrace: TokenSyntax,
                                    members: StructDeclMembersSyntax,
                                    rightBrace: TokenSyntax,
                                    presence: SourcePresence = .present) -> StructDeclSyntax {
    return fromRaw(.node(.structDecl,
                         [
                          structKeyword.raw,
                          identifier.raw,
                          leftBrace.raw,
                          members.raw,
                          rightBrace.raw
                         ],
                         presence))
  }

  public static func makeStructDeclMembers(members: [Syntax],
                                           presence: SourcePresence = .present) -> StructDeclMembersSyntax {
    return fromRaw(.node(.declMembers,
                         members.map { $0.raw },
                         presence))
  }

  public static func makeToken(kind: TokenKind,
                               presence: SourcePresence = .present,
                               leadingTrivia: Trivia = .zero,
                               trailingTrivia: Trivia = .zero) -> TokenSyntax {
    return fromRaw(.token(kind, leadingTrivia, trailingTrivia, presence))
  }
}
