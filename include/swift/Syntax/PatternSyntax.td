// A bindable pattern, which can be used as the left-hand side of an assignment.
class BindablePatternSyntax : PatternSyntax;
def AnyBindablePatternSyntax : BindablePatternSyntax;

// A wildcard (_) pattern.
def WildcardPatternSyntax : BindablePatternSyntax {
 Layout Wildcard = Layout<WildcardTokenSyntax>;
 Layout TypeAnnotation = OptionalLayout<TypeAnnotationSyntax>;
}

// A pattern that is just an identifier.
def IdentifierPatternSyntax : BindablePatternSyntax {
  Layout Identifier = Layout<IdentifierTokenSyntax>;
  Layout TypeAnnotation = OptionalLayout<TypeAnnotationSyntax>;
}

// A label that can exist in a pattern.
def LabelSyntax : Syntax {
  Layout Identifier = Layout<IdentifierTokenSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
}

// A tuple pattern element.
// (label: x, y)
//  ^~~~~~~~  ^
def TuplePatternElementSyntax : Syntax {
  Layout Label = OptionalLayout<LabelSyntax>;
  Layout PatternSyntax = Layout<AnyPatternSyntax>;
  Layout Comma = Layout<LabelSyntax>;
}

// A list of patterns in a tuple.
def TuplePatternElementListSyntax : SyntaxCollection<TuplePatternElementSyntax>;

// A tuple pattern.
// let (label: x, y) = (4, 5)
//     ^~~~~~~~~~~~~
def TuplePatternSyntax : BindablePatternSyntax {
  Layout OpenParen = Layout<LeftParenTokenSyntax>;
  Layout Elements = Layout<TuplePatternElementListSyntax>;
  Layout CloseParen = Layout<RightParenTokenSyntax>;
  Layout TypeAnnotation = OptionalLayout<TypeAnnotationSyntax>;
}

// An optional pattern.
// let x? = 4
//     ^~
def OptionalPatternSyntax : BindablePatternSyntax {
  Layout Identifier = Layout<IdentifierTokenSyntax>;
  Layout QuestionMark = Layout<QuestionMarkPostfixTokenSyntax>;
}

// An `as` pattern.
// case let foo as (Int, Int):
//      ^~~~~~~~~~~~~~~~~~~~~
def AsTypePatternSyntax : BindablePatternSyntax {
  Layout PatternSyntax = Layout<AnyBindablePatternSyntax>;
  Layout As = Layout<AsTokenSyntax>;
  Layout Type = Layout<AnyTypeSyntax>;
}

// An enum case pattern.
// Foo.baz(let x)
def EnumCasePatternSyntax : PatternSyntax {
  Layout TypeIdentifier = OptionalLayout<TypeIdentifierSyntax>;
  Layout Period = Layout<PeriodTokenSyntax>;
  Layout CaseName = Layout<IdentifierTokenSyntax>;
  Layout AssociatedTuple = OptionalLayout<TuplePatternSyntax>;
}

// An `is` pattern.
// case is (Int, Int):
def IsTypePatternSyntax : PatternSyntax {
  Layout Is = Layout<IsTokenSyntax>;
  Layout Type = Layout<AnyTypeSyntax>;
}

// A binding pattern.
// let (x, y) = 5
// ^~~~~~~~~~
def ValueBindingPatternSyntax : PatternSyntax {
  Layout LetOrVar = Layout<TokenChoice<[LetTokenSyntax, VarTokenSyntax]>>;
  Layout ValuePatternSyntax = Layout<AnyBindablePatternSyntax>;
}

// A pattern that is an expression.
def ExpressionPatternSyntax : PatternSyntax {
  Layout Expression = Layout<AnyExprSyntax>;
}

