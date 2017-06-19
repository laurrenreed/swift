//===------------- SyntaxChildren.swift - Syntax Child Iterator -----------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

/// A sequence that allows iteration of the children of a Syntax node.
public struct SyntaxChildren: Sequence {
  /// The node being iterated.
  let node: Syntax

  /// Creates an iterator over the chilren of the provided node.
  public func makeIterator() -> AnyIterator<Syntax> {
    var index = 0
    return AnyIterator {
      defer { index += 1 }
      return self.node.child(at: index)
    }
  }
}
