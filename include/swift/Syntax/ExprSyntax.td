// The try operator.
// try foo()
// try? foo()
// try! foo()
def TryOperatorSyntax : Syntax {
  Layout Try = Layout<TryTokenSyntax>;
  Layout QuestionOrExclamationMark = OptionalLayout<TokenChoice<[QuestionMarkPostfixTokenSyntax, ExclamationMarkTokenSyntax]>>;
}

// Any postfix expression.
class PostfixExprSyntax : ExprSyntax;
def AnyPostfixExprSyntax : PostfixExprSyntax;

// Any literal expression.
class LiteralExprSyntax : PostfixExprSyntax;

// A #line expression.
def PoundLineExprSyntax : LiteralExprSyntax {
  Layout PoundLine = Layout<PoundLineTokenSyntax>;
}

// A #file expression.
def PoundFileExprSyntax : LiteralExprSyntax {
  Layout PoundFile = Layout<PoundFileTokenSyntax>;
}

// A #column expression.
def PoundColumnExprSyntax : LiteralExprSyntax {
  Layout PoundColumn = Layout<PoundColumnTokenSyntax>;
}

// A #function expression.
def PoundFunctionExprSyntax : LiteralExprSyntax {
  Layout PoundFunction = Layout<PoundFunctionTokenSyntax>;
}

// An integer literal.
// 3
// +3_400
// +0x4f
def IntegerLiteralExprSyntax : LiteralExprSyntax {
  Layout Sign = OptionalLayout<PrefixOperatorTokenSyntax>; // - or +
  Layout Digits = Layout<IntegerLiteralTokenSyntax>;
}

// A floating-point literal
// 4.0
// -3.9
// +4e20
def FloatLiteralExprSyntax : LiteralExprSyntax {
  Layout Sign = OptionalLayout<PrefixOperatorTokenSyntax>; // - or +
  Layout FloatingDigits = Layout<FloatingLiteralTokenSyntax>;
}

// TODO: String Literal

// Any prefix expression.
class PrefixExprSyntax : ExprSyntax;
def AnyPrefixExprSyntax : PrefixExprSyntax;

// An inout expression.
// &x
def InOutExprSyntax : PrefixExprSyntax {
  Layout Ampersand = Layout<AmpersandTokenSyntax>;
  Layout Identifier = Layout<IdentifierTokenSyntax>;
}

// A prefix operator expression.
// -x
// !true
def PrefixOperatorExprSyntax : PrefixExprSyntax {
  Layout Operator = OptionalLayout<PrefixOperatorTokenSyntax>;
  Layout PostfixExpression = Layout<AnyPostfixExprSyntax>;
}

/// symbolic-reference-expression -> identifier generic-argument-clause?
def SymbolicReferenceExprSyntax : ExprSyntax {
  Layout Identifier = Layout<IdentifierTokenSyntax>;
  Layout GenericArgumentClause = OptionalLayout<GenericArgumentClauseSyntax>;
}

/// function-call-argument -> label? ':'? expression ','?
def FunctionCallArgumentSyntax : Syntax {
  Layout Label = OptionalLayout<IdentifierTokenSyntax>;
  Layout Colon = OptionalLayout<ColonTokenSyntax>;
  Layout Expression = Layout<AnyExprSyntax>;
  Layout TrailingComma = OptionalLayout<CommaTokenSyntax>;
}

def FunctionCallArgumentListSyntax : SyntaxCollection<FunctionCallArgumentSyntax>;

def FunctionCallExprSyntax : Syntax {
  Layout CalledExpression = Layout<AnyExprSyntax>;
  Layout LeftParen = Layout<LeftParenTokenSyntax>;
  Layout ArgumentList = Layout<FunctionCallArgumentListSyntax>;
  Layout RightParen = Layout<RightParenTokenSyntax>;
}

/*
// def BinaryExprSyntax: TODO

// A full expression.
// try foo(x) + 4 + 3
def ExpressionSyntax : ExprSyntax {
  Layout Try = OptionalLayout<TryOperatorSyntax>;
  Layout PrefixExpression = Layout<AnyPrefixExpr>;
  Layout BinaryExpressions = OptionaLayout<BinaryExprListSyntax>;
}

// An expression inside a list of expressions.
def ExpressionListElement : Syntax {
  Layout Expression = Layout<AnyExpr>;
  Layout Comma = Layout<CommaToken>;
}

def ExpressionListSyntax : SyntaxCollection<ExpressionListElement>;
*/
