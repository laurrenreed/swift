//===----------- TokenSyntax.h - Swift Token Interface ----------*- C++ -*-===//
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
// This file contains the interface for a `TokenSyntax`, which is a token
// that includes full-fidelity leading and trailing trivia.
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_SYNTAX_TOKENSYNTAX_H
#define SWIFT_SYNTAX_TOKENSYNTAX_H

#include "swift/Syntax/RawTokenSyntax.h"
#include "swift/Syntax/References.h"
#include "swift/Syntax/Syntax.h"
#include "swift/Syntax/SyntaxData.h"
#include "swift/Syntax/TokenKinds.h"
#include "swift/Syntax/Trivia.h"

namespace swift {
namespace syntax {

class TokenSyntax final : public Syntax {
protected:
  virtual void validate() const override {
    assert(getRaw()->isToken());

  }
public:
  TokenSyntax(const RC<SyntaxData> Root, const SyntaxData *Data)
    : Syntax(Root, Data) {}

  RC<RawTokenSyntax> getRawToken() const {
    return cast<RawTokenSyntax>(getRaw());
  }

  static TokenSyntax missingToken(const tok Kind, OwnedString Text) {
    return make<TokenSyntax>(RawTokenSyntax::missingToken(Kind, Text));
  }

  TokenSyntax withLeadingTrivia(const Trivia &Trivia) const {
    auto NewRaw = getRawToken()->withLeadingTrivia(Trivia);
    return Data->replaceSelf<TokenSyntax>(NewRaw);
  }

  TokenSyntax withTrailingTrivia(const Trivia &Trivia) const {
    auto NewRaw = getRawToken()->withTrailingTrivia(Trivia);
    return Data->replaceSelf<TokenSyntax>(NewRaw);
  }

  /// Returns the text of the token without trivia.
  std::string getText() const {
    return getRawToken()->Text.str();
  }

  /// Returns the leading trivia of the token.
  const Trivia &getLeadingTrivia() const {
    return getRawToken()->LeadingTrivia;
  }

  /// Returns the trailing trivia of the token.
  const Trivia &getTrailingTrivia() const {
    return getRawToken()->TrailingTrivia;
  }

  /// Returns true if the token is missing.
  bool isMissing() const {
    return getRawToken()->isMissing();
  }

  /// Returns the kind of token this is.
  tok getTokenKind() const {
    return getRawToken()->getTokenKind();
  }

  /// Returns true if the token is of the ExpectedKind and,
  /// if non-empty, has the same spelling as ExpectedText.
  bool is(tok ExpectedKind, StringRef ExpectedText) const {
    return getRawToken()->is(ExpectedKind, ExpectedText);
  }

  /// Returns true if the token is of the given kind.
  bool is(tok K) const {
    return getRawToken()->is(K);
  }

  /// Returns true if the token is not of the given kind.
  bool isNot(tok K) const {
    return getRawToken()->isNot(K);
  }

  /// Returns true if the token is some kind of keyword.
  bool isKeyword() const {
    return getRawToken()->isKeyword();
  }

  /// Returns true if the token is some kind of literal.
  bool isLiteral() const {
    return getRawToken()->isLiteral();
  }

  static bool classof(const Syntax *S) {
    return S->getKind() == SyntaxKind::Token;
  }
};

} // end namespace syntax
} // end namespace swift

#endif // SWIFT_SYNTAX_TOKENSYNTAX_H
