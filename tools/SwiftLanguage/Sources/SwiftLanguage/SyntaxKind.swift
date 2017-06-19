//===------------------ SyntaxKind.swift - Syntax Kind Enum ---------------===//
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

/// Enumerates the known kinds of Syntax represented in the Syntax tree.
internal enum SyntaxKind: String, Codable {
  case token = "Token"
  case unknown = "Unknown"
  case missingDecl = "MissingDecl"
  case unknownDecl = "UnknownDecl"
  case missingStmt = "MissingStmt"
  case unknownStmt = "UnknownStmt"
  case missingExpr = "MissingExpr"
  case unknownExpr = "UnknownExpr"
  case structDecl = "StructDecl"
  case declMembers = "DeclMembers"
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let kind = try container.decode(String.self)
    self = SyntaxKind(rawValue: kind) ?? .unknown
  }
}

extension SyntaxKind {
  var syntaxType: _SyntaxBase.Type {
    // TODO: Generate this once we've got all TableGen nodes filled out.
    switch self {
    case .structDecl: return StructDeclSyntax.self
    case .token: return TokenSyntax.self
    default: return UnknownSyntax.self
    }
  }
}
