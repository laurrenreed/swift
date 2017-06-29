// Represents an element that's an argument to an attribute, i.e.:
// @available(*, unavailable, message: "Unavailable.")
//            ^  ^~~~~~~~~~~  ^~~~~~~~~~~~~~~~~~~~~~~
class AttributeArgumentListElement {
  string Category = "Attribute";
}

// Erased container of a single argument list element.
def AnyAttributeArgumentListElement : AttributeArgumentListElement, Syntax;

// A collection of argument list elements.
def AttributeArgumentListSyntax : SyntaxCollection<AnyAttributeArgumentListElement> {
  let Category = "Attribute";
}

// Represents any Syntax node balanced between braces, parens, or brackets.
// [x] (x, y) { x }
def BalancedTokensSyntax : AttributeArgumentListElement, Syntax {
  Layout LeftMatch = Layout<AnyTokenSyntax>;
  Layout BalancedTokenSyntaxs = Layout<AttributeArgumentListSyntax>;
  Layout RightMatch = Layout<AnyTokenSyntax>;
}

// Represents the full declaration of an attribute:
// @available(*, unavailable, message: "Unavailable.")
def AttributeSyntax : Syntax {
  Layout AtSign = Layout<AtSignTokenSyntax>;
  Layout AttributeName = Layout<IdentifierTokenSyntax>;
  Layout OpenParen = Layout<LeftParenTokenSyntax>;
  Layout AttributeArguments = Layout<AttributeArgumentListSyntax>;
  Layout CloseParen = Layout<RightParenTokenSyntax>;
}

// Represents a list of attributes that can appear on a declaration.
def AttributeListSyntax : SyntaxCollection<AttributeSyntax> {
  let Category = "Attribute";
}
