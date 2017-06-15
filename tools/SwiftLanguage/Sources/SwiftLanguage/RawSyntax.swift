import Foundation

indirect enum RawSyntax: Codable {
  case node(SyntaxKind, [RawSyntax], SourcePresence)
  case token(TokenKind, Trivia, Trivia, SourcePresence)
  
  var kind: SyntaxKind {
    switch self {
    case .node(let kind, _, _): return kind
    case .token: return .token
    }
  }
  
  var layout: [RawSyntax] {
    switch self {
    case .node(_, let layout, _): return layout
    case .token: return []
    }
  }
  
  enum CodingKeys: CodingKey {
    // Keys for the `node` case
    case kind, layout, presence
    
    // Keys for the `token` case
    case tokenKind, leadingTrivia, trailingTrivia
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let presence = try container.decode(SourcePresence.self, forKey: .presence)
    if let kind = try container.decodeIfPresent(SyntaxKind.self, forKey: .kind) {
      let layout = try container.decode([RawSyntax].self, forKey: .layout)
      self = .node(kind, layout, presence)
    } else {
      let kind = try container.decode(TokenKind.self, forKey: .tokenKind)
      let leadingTrivia = try container.decode(Trivia.self, forKey: .leadingTrivia)
      let trailingTrivia = try container.decode(Trivia.self, forKey: .trailingTrivia)
      self = .token(kind, leadingTrivia, trailingTrivia, presence)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .node(kind, layout, presence):
      try container.encode(kind, forKey: .kind)
      try container.encode(layout, forKey: .layout)
      try container.encode(presence, forKey: .presence)
    case let .token(kind, leadingTrivia, trailingTrivia, presence):
      try container.encode(kind, forKey: .tokenKind)
      try container.encode(leadingTrivia, forKey: .leadingTrivia)
      try container.encode(trailingTrivia, forKey: .trailingTrivia)
      try container.encode(presence, forKey: .presence)
    }
  }
  
  static func missing(_ kind: SyntaxKind, layout: [RawSyntax]) -> RawSyntax {
    return .node(kind, layout, .missing)
  }
  
  static func missingToken(_ kind: TokenKind) {
    return
  }
  
  func replacingLayout(_ newLayout: [RawSyntax]) -> RawSyntax {
    switch self {
    case let .node(kind, _, presence): return .node(kind, newLayout, presence)
    case .token: return self
    }
  }
  
  func print<StreamType: TextOutputStream>(to stream: inout StreamType) {
    switch self {
    case .node(_, let layout, _):
      for child in layout {
        child.print(to: &stream)
      }
    case let .token(kind, leadingTrivia, trailingTrivia, presence):
      guard case .present = presence else { return }
      for piece in leadingTrivia {
        piece.print(to: &stream)
      }
      stream.write(kind.text)
      for piece in trailingTrivia {
        piece.print(to: &stream)
      }
    }
  }
  
  func makeRootSyntax() -> Syntax {
    return makeSyntax(root: nil, indexInParent: 0, parent: nil)
  }
  
  func makeSyntax(root: SyntaxData?, indexInParent: Int,
                  parent: SyntaxData?) -> Syntax {
    let data = parent?.cachedChild(at: indexInParent) ??
              SyntaxData(raw: self, indexInParent: indexInParent,
                         parent: parent)
    return kind.syntaxType.init(root: root ?? data, data: data)
  }
  
  subscript<CursorType: RawRepresentable>(_ index: CursorType) -> RawSyntax
    where CursorType.RawValue == Int {
      return layout[index.rawValue]
  }

  var isToken: Bool {
    return kind == .token
  }
  
  func replacingChild(_ index: Int,
                      with newChild: RawSyntax) -> RawSyntax {
    precondition(index < layout.count, "cursor reached past layout")
    var newLayout = layout
    newLayout[index] = newChild
    return replacingLayout(newLayout)
  }
}
