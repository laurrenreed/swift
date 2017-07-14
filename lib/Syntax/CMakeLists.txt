set(SWIFT_GYB_FLAGS
  --line-directive "''")

add_swift_library(swiftSyntax STATIC
  SyntaxNodes.cpp.gyb
  SyntaxBuilders.cpp.gyb
  SyntaxKind.cpp.gyb
  SyntaxFactory.cpp.gyb
  Trivia.cpp
  RawSyntax.cpp
  RawTokenSyntax.cpp
  Syntax.cpp
  SyntaxData.cpp
  UnknownSyntax.cpp
<<<<<<< HEAD
=======
  GYB_DEPENDS
    "${SWIFT_SYNTAX_NODE_DEFINITIONS}"
>>>>>>> Generate libSyntax API from JSON
  DEPENDS
    swift-syntax-generated-headers)
