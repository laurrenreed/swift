add_swift_library(swiftSwiftSyntax ${SWIFT_STDLIB_LIBRARY_BUILD_TYPES} IS_STDLIB
  # This file should be listed the first.  Module name is inferred from the
  # filename.
  SwiftSyntax.swift
  RawSyntax.swift
  AtomicCache.swift
  Syntax.swift
  SyntaxData.swift
  SyntaxChildren.swift
  SyntaxBuilders.swift.gyb
  SyntaxFactory.swift.gyb
  SyntaxNodes.swift.gyb
  SyntaxKind.swift.gyb
  SyntaxKind.swift.gyb
  Trivia.swift

  SWIFT_MODULE_DEPENDS Foundation
  GYB_DEPENDS
    "${SWIFT_SYNTAX_NODE_DEFINITIONS}"
  SWIFT_COMPILE_FLAGS ${STDLIB_SIL_SERIALIZE_ALL} -parse-stdlib
  INSTALL_IN_COMPONENT stdlib-experimental)

