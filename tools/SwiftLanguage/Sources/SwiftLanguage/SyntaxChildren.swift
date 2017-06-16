//
//  SyntaxChildren.swift
//  SwiftLanguage
//
//  Created by Harlan Haskins on 6/16/17.
//

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
