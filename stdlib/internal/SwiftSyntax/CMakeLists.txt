add_swift_library(swiftSwiftSyntax ${SWIFT_STDLIB_LIBRARY_BUILD_TYPES} IS_STDLIB
  # This file should be listed the first.  Module name is inferred from the
  # filename.
  SwiftSyntax.swift
  AtomicCache.swift
  RawSyntax.swift
  SourcePresence.swift
  SwiftcInvocation.swift
  Syntax.swift
  SyntaxData.swift
  SyntaxChildren.swift
  SyntaxCollection.swift
  SyntaxBuilders.swift.gyb
  SyntaxFactory.swift.gyb
  SyntaxKind.swift.gyb
  SyntaxNodes.swift.gyb
  TokenKind.swift.gyb
  Trivia.swift

  SWIFT_MODULE_DEPENDS Foundation
  SWIFT_COMPILE_FLAGS ${STDLIB_SIL_SERIALIZE_ALL} -enable-testing
  INSTALL_IN_COMPONENT stdlib-experimental)