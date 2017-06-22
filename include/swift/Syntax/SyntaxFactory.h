//===--- SyntaxFactory.h - Swift Syntax Builder Interface -------*- C++ -*-===//
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
//
// This file defines the SyntaxFactory, one of the most important client-facing
// types in lib/Syntax and likely to be very commonly used.
//
// Effectively a namespace, SyntaxFactory is never instantiated, but is *the*
// one-stop shop for making new Syntax nodes. Putting all of these into a
// collection of static methods provides a single point of API lookup for
// clients' convenience and also allows the library to hide all of the
// constructors for all Syntax nodes, as the SyntaxFactory is friend to all.
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_SYNTAX_SyntaxFactory_H
#define SWIFT_SYNTAX_SyntaxFactory_H

//#include "swift/Syntax/DeclSyntax.h"
//#include "swift/Syntax/GenericSyntax.h"
//#include "swift/Syntax/TokenSyntax.h"
//#include "swift/Syntax/TypeSyntax.h"
#include "swift/Syntax/Trivia.h"
#include "llvm/ADT/ArrayRef.h"

#include <vector>

namespace swift {
namespace syntax {

#define SYNTAX(Id, Parent) class Id##Syntax;
#include "swift/Syntax/SyntaxKinds.def"
class DeclSyntax;
class ExprSyntax;
class StmtSyntax;
class UnknownSyntax;
class TokenSyntax;

/// The Syntax factory - the one-stop shop for making new Syntax nodes.
struct SyntaxFactory {
  /// Make any kind of token.
  static TokenSyntax
  makeToken(tok Kind, OwnedString Text, SourcePresence Presence,
            const Trivia &LeadingTrivia, const Trivia &TrailingTrivia);

  /// Collect a list of tokens into a piece of "unknown" syntax.
  static UnknownSyntax
  makeUnknownSyntax(ArrayRef<TokenSyntax> tokens);
};
} // end namespace syntax
} // end namespace swift
#endif // SWIFT_SYNTAX_SyntaxFactory_H
