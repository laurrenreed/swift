// A type annotation for a variable.
// (x: @autoclosure (Int) -> Bool)
//     ^~~~~~~~~~~~~~~~~~~~~~~~~~
def TypeAnnotationSyntax : Syntax {
  Layout Attributes = Layout<AttributeListSyntax>;
  Layout InOut = OptionalLayout<InoutTokenSyntax>;
  Layout Type = Layout<AnyTypeSyntax>;
}

// An element of a generic argument.
// Dictionary<Int, String>
//            ^~~~ ^~~~~~
def GenericArgumentClauseElementSyntax : Syntax {
  Layout GenericArgument = Layout<AnyTypeSyntax>;
  Layout Comma = Layout<CommaTokenSyntax>;
}

// A full generic argument clause, comprising all elements.
// Dictionary<Int, String>
//            ^~~~~~~~~~~
def GenericArgumentClauseSyntax : SyntaxCollection<GenericArgumentClauseElementSyntax>;

// A type that represents a possibly nested type identifier
// Foo.Bar<Int>
def TypeIdentifierSyntax : Syntax {
  Layout TypeName = Layout<IdentifierTokenSyntax>;
  Layout GenericArgumentClause = OptionalLayout<GenericArgumentClauseSyntax>;
  Layout Period = OptionalLayout<PeriodTokenSyntax>;
  Layout TypeIdentifier = OptionalLayout<TypeIdentifierSyntax>;
}

// A tuple type element. It may be labelled.
// (x: Int, y: @autoclosure (Int) -> Bool)
//  ^~~~~~~ ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def TupleTypeElementSyntax : Syntax {
  Layout Label = Layout<IdentifierTokenSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
  Layout TypeAnnotation = Layout<TypeAnnotationSyntax>;
  Layout Comma = Layout<CommaTokenSyntax>;
}

// A list of tuple type elements.
def TupleTypeElementListSyntax : SyntaxCollection<TupleTypeElementSyntax>;

// The syntax for a full tuple type.
// (x: Int, y: Bool)
def TupleTypeSyntax : TypeSyntax {
  Layout LeftParen = Layout<LeftParenTokenSyntax>;
  Layout ElementList = Layout<TupleTypeElementListSyntax>;
  Layout RightParen = Layout<RightParenTokenSyntax>;
}

// A function parameter type.
// func foo(_ x: Bool, y: Int) {}
//          ^~~~~~~~~~ ^~~~~~
def FunctionTypeArgumentSyntax : Syntax {
  Layout ExternalParameterName = Layout<IdentifierTokenSyntax>;
  Layout LocalParameterName = OptionalLayout<IdentifierTokenSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
  Layout TypeAnnotation = Layout<TypeAnnotationSyntax>;
}

// A list of function parameter types.
def FunctionTypeArgumentListSyntax : SyntaxCollection<FunctionTypeArgumentSyntax>;

// A full function type.
// @autoclosure (Int, Bool) -> Bool
def FunctionTypeSyntax : TypeSyntax {
  Layout TypeAttributes = Layout<AttributeListSyntax>;
  Layout OpenParen = Layout<LeftParenTokenSyntax>;
  Layout ArgumentList = Layout<FunctionTypeArgumentListSyntax>;
  Layout CloseParen = Layout<RightParenTokenSyntax>;
  Layout ThrowsOrRethrows = OptionalLayout<AnyTokenSyntax>;
  Layout Arrow = OptionalLayout<ArrowTokenSyntax>;
  Layout ReturnType = OptionalLayout<AnyTypeSyntax>;
}

// An array type.
// [Int]
def ArrayTypeSyntax : TypeSyntax {
  Layout LeftBracket = Layout<LeftSquareTokenSyntax>;
  Layout ElementType = Layout<AnyTypeSyntax>;
  Layout RightBracket = Layout<RightSquareTokenSyntax>;
}

// A dictionary type.
// [Int: Bool]
def DictionaryTypeSyntax : TypeSyntax {
  Layout LeftSquare = Layout<LeftSquareTokenSyntax>;
  Layout KeyType = Layout<AnyTypeSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
  Layout ValueType = Layout<AnyTypeSyntax>;
  Layout RightSquare = Layout<RightSquareTokenSyntax>;
}

// An optional type.
// Int?
def OptionalTypeSyntax : TypeSyntax {
  Layout ValueType = Layout<AnyTypeSyntax>;
  Layout QuestionMark = Layout<QuestionMarkPostfixTokenSyntax>;
}

// An implicitly unwrapped optional type.
// Int!
def ImplicitlyUnwrappedOptionalTypeSyntax : TypeSyntax {
  Layout ValueType = Layout<AnyTypeSyntax>;
  Layout ExclamationMark = Layout<ExclamationMarkTokenSyntax>;
}

// The element of a protocol composition
// Sequence & Equatable
// ^~~~~~~~~~ ^~~~~~~~~
def ProtocolCompositionElementSyntax : Syntax {
  Layout ProtocolType = Layout<TypeIdentifierSyntax>;
  Layout Ampersand = Layout<AmpersandTokenSyntax>;
}

// A protocol composition type is a list of protocol composition elements.
def ProtocolCompositionTypeSyntax : SyntaxCollection<ProtocolCompositionElementSyntax>;

// A metatype type.
// Foo.Type
// Foo.Protocol
def MetatypeTypeSyntax : TypeSyntax {
  Layout TypeValue = Layout<AnyTypeSyntax>;
  Layout Period = Layout<PeriodTokenSyntax>;
  // FIXME: Add set of allowable values to assert
  Layout TypeOrProtocol = Layout<IdentifierTokenSyntax>;
}

