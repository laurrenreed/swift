//
//  SyntaxChildren.swift
//  SwiftLanguage
//
//  Created by Harlan Haskins on 6/16/17.
//

import Foundation

public struct SyntaxChildren: Sequence {
  let node: Syntax

  public func makeIterator() -> AnyIterator<Syntax> {
    var index = 0
    return AnyIterator {
      defer { index += 1 }
      return self.node.child(at: index)
    }
  }
}
