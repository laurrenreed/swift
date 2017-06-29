// Base class for all Syntax records.
class Syntax {
  string Category = "CommonSyntax";
}

// Represents a child of a Syntax node. It has a field, `Required`, that
// determines if it will be optional in the child's layout.
class Layout<Syntax node> {
  Syntax Node = node;
  bit Required = 1;
}

// Represents an optional child in the layout. Its `Required` bit is always 0.
class OptionalLayout<Syntax node> : Layout<node> {
  let Required = 0;
}

// Represents a contiguous collection of elements of the provided type.
class SyntaxCollection<Syntax element> : Syntax {
  Syntax Element = element;
}

// Base class for Statement syntax nodes.
class StmtSyntax : Syntax {
  let Category = "StmtSyntax";
}

// Can represent any StmtSyntax node, used for heterogeneous collections of non-
// specific Stmt nodes.
def AnyStmtSyntax: StmtSyntax;


// Base class for Expression syntax nodes.
class ExprSyntax : Syntax {
  let Category = "ExprSyntax";
}

// Can represent any ExprSyntax node, used for heterogeneous collections of non-
// specific Stmt nodes.
def AnyExprSyntax : ExprSyntax;

// Base class for Declaration syntax nodes.
class DeclSyntax : Syntax {
  let Category = "DeclSyntax";
}

// Can represent any DeclSyntax node, used for heterogeneous collections of non-
// specific Stmt nodes.
def AnyDeclSyntax : DeclSyntax;

// Base class for Pattern syntax nodes.
class PatternSyntax : Syntax {
  let Category = "PatternSyntax";
}

// Can represent any PatternSyntax node, used for heterogeneous collections of
// non-specific Stmt nodes.
def AnyPatternSyntax : PatternSyntax;

// Base class for Type syntax nodes.
class TypeSyntax : Syntax {
  let Category = "TypeSyntax";
}

// Can represent any TypeSyntax node, used for heterogeneous collections of
// non-specific Stmt nodes.
def AnyTypeSyntax : TypeSyntax;

// Base class for Attribute syntax nodes.
class AttributeSyntax : Syntax;

// Base class for Token syntax nodes. These nodes will only really have one
// structure, 'TokenSyntax', but there are specific records of TokenSyntax for
// generation of token kind enums.
class TokenSyntax<string spelling, string kind> : Syntax {
  string Spelling = spelling;
  string Kind = kind;
  let Category = "TokenSyntax";
}

// A semantic construct for representing a restricted set of possible tokens.
// This will be generated as separate accessors that are optional, but that each
// overlap in the parent's children.
class TokenChoice<list<TokenSyntax> choices> : Syntax {
  list<TokenSyntax> Choices = choices;
}


