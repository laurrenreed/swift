// An expression in statement position.
// foo();
def ExpressionStmtSyntax : StmtSyntax {
  Layout Expression = Layout<AnyExprSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A declaration in statement position.
// struct Foo {};
def DeclarationStmtSyntax : StmtSyntax {
  Layout Declaration = Layout<AnyDeclSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A list of statements.
def StatementListSyntax : SyntaxCollection<AnyStmtSyntax>;

// A code block with a list of statements surrounded in braces.
// let x: () -> Void = { foo() }
//                     ^~~~~~~~~
def CodeBlockSyntax : Syntax {
  Layout OpenBrace = Layout<LeftBraceTokenSyntax>;
  Layout Statments = Layout<StatementListSyntax>;
  Layout CloseBrace = Layout<RightBraceTokenSyntax>;
}

// A statement that can appear with a label.
// label: do { }
class LabelledStmtSyntax : StmtSyntax {
  Layout LabelName = Layout<IdentifierTokenSyntax>;
  Layout LabelColon = Layout<ColonTokenSyntax>;
}

// A for-in statement.
// for i in 0..<10 { print(i) }
def ForInStmtSyntax : LabelledStmtSyntax {
  Layout For = Layout<ForTokenSyntax>;
  Layout Case = OptionalLayout<CaseTokenSyntax>;
  Layout ItemPattern = Layout<AnyPatternSyntax>;
  Layout In = Layout<InTokenSyntax>;
  Layout CollectionExpr = Layout<AnyExprSyntax>;
  Layout WhereClause = OptionalLayout<WhereClauseSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A while loop statement.
// while true, true, true { }
def WhileStmtSyntax : LabelledStmtSyntax {
  Layout While = Layout<WhileTokenSyntax>;
  Layout Conditions = Layout<ConditionListSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A repeat-while loop statement.
// repeat { } while true;
def RepeatWhileStmtSyntax : LabelledStmtSyntax {
  Layout Repeat = Layout<RepeatTokenSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout While = Layout<WhileTokenSyntax>;
  Layout Condition = Layout<AnyExprSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// Any of the else clauses of an if statement, either:
// } else { ... }
// } else if foo() { ... }
class ElseClauseSyntax : Syntax {
  Layout Else = Layout<ElseTokenSyntax>;
}

def AnyElseClause : ElseClauseSyntax;

// An else clause with no other condition.
// } else { ... }
def ElseBlockSyntax : ElseClauseSyntax {
  Layout Body = Layout<CodeBlockSyntax>;
}

// An else-if clause with another condition.
// } else if foo() { ... }
def ElseIfContinuationSyntax : ElseClauseSyntax {
  Layout IfStmt = Layout<IfStmtSyntax>;
}

// An if statement.
// if foo(), true { } else { }
def IfStmtSyntax : LabelledStmtSyntax {
  Layout If = Layout<IfTokenSyntax>;
  Layout Conditions = Layout<ConditionListSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout ElseClause = OptionalLayout<AnyElseClause>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// An item of a switch case.
// case foo where bar(baz):
//      ^~~~~~~~~~~~~~~~~~
def CaseItemSyntax : Syntax {
  Layout Pattern = Layout<AnyPatternSyntax>;
  Layout WhereClause = OptionalLayout<WhereClauseSyntax>;
  Layout Comma = OptionalLayout<CommaTokenSyntax>;
}

// A list of items of a case statement.
// case 1, 3, 5:
//      ^~~~~~~
def CaseItemListSyntax : SyntaxCollection<CaseItemSyntax>;

// A possible labeled element in a switch statement, either:
// case 1, 2, 3:
// default:
class SwitchLabelSyntax : Syntax;

def AnySwitchLabel : SwitchLabelSyntax;

// A switch case label.
// case true:
def SwitchCaseLabelSyntax : SwitchLabelSyntax {
  Layout Case = Layout<CaseTokenSyntax>;
  Layout CaseItems = Layout<CaseItemListSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
}

// A default label of a switch statement.
// default:
def SwitchDefaultLabelSyntax : SwitchLabelSyntax {
  Layout Default = Layout<DefaultTokenSyntax>;
  Layout Colon = Layout<ColonTokenSyntax>;
}

// A case of a switch statement, including the list of statements.
// case 3: print("Hello")
def SwitchCaseSyntax : Syntax {
  Layout Label = Layout<AnySwitchLabel>;
  Layout Body = Layout<StatementListSyntax>;
}

// A list of cases in a switch statement.
def SwitchCaseListSyntax : SyntaxCollection<SwitchCaseSyntax>;

// A full switch statement.
// switch expr {
// case 4: print("Hello")
// default: break
// }
def SwitchStmtSyntax : LabelledStmtSyntax {
  Layout Switch = Layout<SwitchTokenSyntax>;
  Layout Expression = Layout<AnyExprSyntax>;
  Layout OpenBrace = Layout<LeftBraceTokenSyntax>;
  Layout Cases = Layout<SwitchCaseListSyntax>;
  Layout CloseBrace = Layout<RightBraceTokenSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A binding clause of a catch statement.
// do { } catch { }
//        ^~~~~~~~~
def CatchClauseSyntax : Syntax {
  Layout Catch = Layout<CatchTokenSyntax>;
  Layout Pattern = OptionalLayout<AnyPatternSyntax>;
  Layout WhereClause = OptionalLayout<WhereClauseSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
}

// A list of possible clauses of a do-catch statement.
def CatchClauseListSyntax : SyntaxCollection<CatchClauseSyntax>;

// A do statement which opens an explicit scope.
// do { let x = 4; print(x) }
def DoStmtSyntax : LabelledStmtSyntax {
  Layout Do = Layout<DoTokenSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout CatchClauses = Layout<CatchClauseListSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A guard statment.
// guard foo() else { return }
def GuardStmtSyntax : StmtSyntax {
  Layout Guard = Layout<GuardTokenSyntax>;
  Layout Conditions = Layout<ConditionListSyntax>;
  Layout Else = Layout<ElseTokenSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A break statement.
// break
// break label
def BreakStmtSyntax : StmtSyntax {
  Layout Break = Layout<BreakTokenSyntax>;
  Layout Label = OptionalLayout<IdentifierTokenSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A continue statement.
// continue
// continue label
def ContinueStmtSyntax : StmtSyntax {
  Layout Continue = Layout<ContinueTokenSyntax>;
  Layout Label = OptionalLayout<IdentifierTokenSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A fallthrough statement.
// fallthrough
def FallthroughStmtSyntax : StmtSyntax {
  Layout Fallthrough = Layout<FallthroughTokenSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A return statement.
// return foo
def ReturnStmtSyntax : StmtSyntax {
  Layout Return = Layout<ReturnTokenSyntax>;
  Layout Expression = OptionalLayout<AnyExprSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A throw statement.
// throw MyError.error
def ThrowStmtSyntax : StmtSyntax {
  Layout Throw = Layout<ThrowTokenSyntax>;
  Layout Expression = Layout<AnyExprSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}

// A defer statement.
// defer { }
def DeferStmtSyntax : StmtSyntax {
  Layout Defer = Layout<DeferTokenSyntax>;
  Layout Body = Layout<CodeBlockSyntax>;
  Layout Semicolon = OptionalLayout<SemicolonTokenSyntax>;
}
