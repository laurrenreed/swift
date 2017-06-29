include(SwiftSyntaxLibrary)

add_swift_library(swiftSyntax STATIC
  SyntaxNodes.cpp.gyb
  RawTokenSyntax.cpp
  LegacyASTTransformer.cpp
  Trivia.cpp
  RawSyntax.cpp
  Syntax.cpp
  SyntaxData.cpp
  UnknownSyntax.cpp
  DEPENDS swift-syntax-all-generated-source
)

