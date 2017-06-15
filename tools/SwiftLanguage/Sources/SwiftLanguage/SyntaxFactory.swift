import Foundation

public enum SyntaxFactory {
  internal static func fromRaw<T: _SyntaxBase>(_ raw: RawSyntax) -> T {
    let data = SyntaxData(raw: raw, parent: nil)
    return T.init(root: data, data: data)
  }

  public static func makeStructDecl(structKeyword: TokenSyntax,
                                    identifier: TokenSyntax,
                                    leftBrace: TokenSyntax,
                                    members: StructDeclMembersSyntax,
                                    rightBrace: TokenSyntax,
                                    presence: SourcePresence = .present) -> StructDeclSyntax {
    return fromRaw(.node(.structDecl,
                         [
                          structKeyword.raw,
                          identifier.raw,
                          leftBrace.raw,
                          members.raw,
                          rightBrace.raw
                         ],
                         presence))
  }

  public static func makeStructDeclMembers(members: [Syntax],
                                           presence: SourcePresence = .present) -> StructDeclMembersSyntax {
    return fromRaw(.node(.declMembers,
                         members.map { ($0 as! _SyntaxBase).data.raw },
                         presence))
  }

  public static func makeToken(kind: TokenKind,
                               presence: SourcePresence = .present,
                               leadingTrivia: Trivia = .zero,
                               trailingTrivia: Trivia = .zero) -> TokenSyntax {
    return fromRaw(.token(kind, leadingTrivia, trailingTrivia, presence))
  }
}
