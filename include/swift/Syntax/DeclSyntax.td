/// declaration-modifier -> access-level-modifier
///                       | mutation-modifier
///                       | 'class'
///                       | 'convenience'
///                       | 'dynamic'
///                       | 'final'
///                       | 'infix'
///                       | 'lazy'
///                       | 'optional'
///                       | 'override'
///                       | 'postfix'
///                       | 'prefix'
///                       | 'required'
///                       | 'static'
///                       | 'unowned'
///                       | 'unowned(safe)'
///                       | 'unowned(unsafe)'
///                       | 'weak'
/// mutation-modifier -> 'mutating' | 'nonmutating'
class ModifierSyntax : Syntax {
}
def AnyModifierSyntax : Syntax {
}

def ModifierListSyntax = SyntaxCollection<AnyModifierSyntax>;

def SimpleModifierSyntax : ModifierSyntax {
  Layout Name = Layout<IdentifierTokenSyntax>;
}

/// access-level-modifier -> 'private' | 'private' '(' 'set' ')'
///                        | 'fileprivate' | 'fileprivate' '(' 'set' ')'
///                        | 'internal' | 'internal' '(' 'set' ')'
///                        | 'public' | 'public' '(' 'set' ')'
///                        | 'open' | 'open' '(' 'set' ')'
def AccessLevelModifierSyntax : ModifierSyntax {
  Layout Name = Layout<IdentifierTokenSyntax>;
  Layout OpenParen = OptionalLayout<LeftParenTokenSyntax>;
  Layout Modifier = OptionalLayout<IdentifierTokenSyntax>;
  Layout CloseParen = OptionalLayout<RightParenTokenSyntax>;
}

/// struct-declaration -> attributes? access-level-modifier?
///                       'struct' struct-name
///                       generic-parameter-clause? type-inheritance-clause?
///                       generic-where-clause?
///                       '{' struct-members '}'
/// struct-name -> identifier
def StructDeclSyntax : DeclSyntax {
  Layout Attributes = OptionalLayout<AttributeListSyntax>;
  Layout AccessLevelModifier = OptionalLayout<AccessLevelModifierSyntax>;
  Layout StructKeyword = Layout<StructKeywordToken>;
  Layout Name = Layout<IdentifierTokenSyntax>;
  Layout GenericParameterClause = OptionalLayout<GenericParameterClauseSyntax>;
  Layout InheritanceClause = Layout<TypeInheritanceClause>;
  Layout GenericWhereClauseSyntax = OptionalLayout<GenericWhereClauseSyntax>;
  Layout LeftBrace = Layout<LeftBraceTokenSyntax>;
  Layout Members = Layout<StructMembersSyntax>;
  Layout RightBrace = Layout<RightBraceTokenSyntax>;
}

/// struct-members -> struct-member struct-members?
/// struct-member -> declaration | compiler-control-statement
def StructMembersSyntax : SyntaxCollection<AnyDeclSyntax>;

/// typealias-declaration -> attributes­? access-level-modifier­? 'typealias'
///                         ­ typealias-name­ generic-parameter-clause?­
///                          ­typealias-assignment­
/// typealias-name­ -> identifier
/// typealias-assignment -> =­ type­
def TypeAliasDeclSyntax : DeclSyntax {
  Layout Attributes = OptionalLayout<AttributeListSyntax>;
  Layout AccessLevelModifier = OptionalLayout<AccessLevelModifierSyntax>;
  Layout TypealiasKeyword = Layout<TypealiasKeywordToken>;
  Layout Name = Layout<IdentifierTokenSyntax>;
  Layout Equals = Layout<BinaryOperatorTokenSyntax>;
  Layout Type = Layout<AnyTypeSyntax>;
}

/// parameter ->
/// external-parameter-name? local-parameter-name ':'
///   type '...'? '='? expression? ','?
def FunctionParameterSyntax : Syntax {
  Layout ExternalName = OptionalLayout<IdentifierTokenSyntax>;
  Layout LocalName = Layout<IdentifierTokenSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
  Layout Type = Layout<AnyTypeSyntax>;
  Layout Ellipsis = OptionalLayout<EllipsisTokenSyntax>;
  Layout DefaultEqual = OptionalLayout<BinaryOperatorTokenSyntax>;
  Layout DefaultExpression = OptionalLayout<AnyExprSyntax>;
  Layout TrailingComma = OptionalLayout<CommaTokenSyntax>;
}

def FunctionParameterListSyntax : SyntaxCollection<FunctionParameterSyntax>;

/// function-signature ->
///   '(' parameter-list? ')' (throws | rethrows)? '->'? attributes? type?
def FunctionSignatureSyntax : Syntax {
  Layout LeftParen = Layout<LeftParenTokenSyntax>;
  Layout ParameterList = Layout<FunctionParameterListSyntax>;
  Layout RightParen = Layout<RightParenTokenSyntax>;
  Layout ThrowsOrRethrows = OptionalLayout<TokenChoice<[ThrowsTokenSyntax, RethrowsTokenSyntax]>>;
  Layout Arrow = OptionalLayout<ArrowTokenSyntax>;
  Layout ReturnTypeAttributes = OptionalLayout<TypeAttributeListSyntax>;
  Layout ReturnType = OptionalLayout<AnyTypeSyntax>;
}

def FunctionDeclSyntax : DeclSyntax {
  Layout Attributes = OptionalLayout<AttributeListSyntax>;
  Layout Modifiers = OptionalLayout<ModifierListSyntax>;
  Layout FuncKeyword = Layout<FuncTokenSyntax>;
  Layout Identifier = Layout<IdentifierTokenSyntax>;
  Layout GenericParameterClause = OptionalLayout<GenericParameterClauseSyntax>;
  Layout Signature = Layout<FunctionSignatureSyntax>;
  Layout GenericWhereClause = OptionalLayout<GenericWhereClauseSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
}

// A #else directive of a #if configuration.
// #else
//     // statements...
def ElseDirectiveClause : Syntax {
  Layout PoundElse = Layout<PoundElseTokenSyntax>;
  Layout Body = Layout<StatementListSyntax>;
}

// An #elseif directive of a #if configuration
// #elseif true
//     // statements...
def ElseifDirectiveClause : Syntax {
  Layout PoundElseif = Layout<PoundElseifTokenSyntax>;
  Layout Condition = Layout<AnyExprSyntax>;
  Layout Body = Layout<StatementListSyntax>;
}

// A list of possible #if directive clauses.
def ElseifDirectiveClauseListSyntax : SyntaxCollection<ElseifDirectiveClause>;

// A #if configuration statement.
// #if DEBUG
//     // statements
// #elseif NDEBUG
//      // statements
// #else
//      // statements
// #endif
def IfConfigDSyntax : DeclSyntax {
  Layout PoundIf = Layout<PoundIfTokenSyntax>;
  Layout Condition = Layout<AnyExprSyntax>;
  Layout Body = Layout<StatementListSyntax>;
  Layout ElseifDirectiveClauses = Layout<ElseifDirectiveClauseListSyntax>;
  Layout ElseClause = OptionalLayout<ElseDirectiveClause>;
  Layout PoundEndif = Layout<PoundEndifTokenSyntax>;
}

