class GenericRequirementSyntax : Syntax {
}

def AnyGenericRequirementSyntax : GenericRequirementSyntax {
}

def GenericRequirementListSyntax : SyntaxCollection<AnyGenericRequirementSyntax>;

/// conformance-requirement -> type-identifier : type-identifier
def ConformanceRequirementSyntax : GenericRequirementSyntax {
  Layout LeftTypeIdentifier = Layout<TypeIdentifierSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
  Layout RightTypeIdentifier = Layout<TypeIdentifierSyntax>;
  Layout TrailingComma = OptionalLayout<CommaTokenSyntax>;
}

/// same-type-requirement -> type-identifier == type
def SameTypeRequirementSyntax : GenericRequirementSyntax {
  Layout LeftTypeIdentifier = Layout<TypeIdentifierSyntax>;
  Layout EqualityToken = Layout<BinaryOperatorTokenSyntax>;
  Layout RightType = Layout<TypeIdentifierSyntax>;
  Layout TrailingComma = OptionalLayout<CommaTokenSyntax>;
}

/// generic-parameter -> type-name
///                    | type-name : type-identifier
///                    | type-name : protocol-composition-type
def GenericParameterSyntax : Syntax {
  Layout TypeIdentifier = Layout<TypeIdentifierSyntax>;
  Layout Colon = OptionalLayout<ColonTokenSyntax>;
  Layout InheritedType = OptionalLayout<AnyTypeSyntax>;
}

/// generic-parameter-clause -> '<' generic-argument-list '>'
def GenericParameterClauseSyntax : Syntax {
  Layout LeftAngleBracketToken = Layout<LeftAngleBracketTokenSyntax>;
  Layout GenericParameterList = Layout<GenericParameterListSyntax>;
  Layout RightAngleBracketToken = Layout<RightAngleBracketTokenSyntax>;
}

/// generic-where-clause -> 'where' requirement-list
def GenericWhereClauseSyntax : Syntax {
  Layout WhereKeyword = Layout<WhereTokenSyntax>;
  Layout RequirementList = Layout<GenericRequirementListSyntax>;
}
