//
//  SyntaxCollectionData.swift
//  SwiftLanguage
//
//  Created by Harlan Haskins on 5/31/17.
//

import Foundation

public struct SyntaxCollection<SyntaxElement: Syntax>: _SyntaxBase {
  let root: SyntaxData
  unowned let data: SyntaxData
  
  internal func replacingLayout(_ layout: [RawSyntax]) -> SyntaxCollection<SyntaxElement> {
    let newRaw = data.raw.replacingLayout(layout)
    let (newRoot, newData) = data.replacingSelf(newRaw)
    return SyntaxCollection<SyntaxElement>(root: newRoot, data: newData)
  }
  
  public func appending(_ syntax: SyntaxElement) -> SyntaxCollection<SyntaxElement> {
    var newLayout = data.raw.layout
    newLayout.append(syntax.raw)
    return replacingLayout(newLayout)
  }
  
  public func prepending(_ syntax: SyntaxElement) -> SyntaxCollection<SyntaxElement> {
    return inserting(syntax, at: 0)
  }
  
  public func inserting(_ syntax: SyntaxElement, at index: Int) -> SyntaxCollection<SyntaxElement> {
    var newLayout = data.raw.layout
    newLayout.insert(syntax.raw, at: index)
    return replacingLayout(newLayout)
  }
  
  public func removing(childAt index: Int) -> SyntaxCollection<SyntaxElement> {
    var newLayout = data.raw.layout
    newLayout.remove(at: index)
    return replacingLayout(newLayout)
  }
  
  public func removingFirst() -> SyntaxCollection<SyntaxElement> {
    var newLayout = data.raw.layout
    newLayout.removeFirst()
    return replacingLayout(newLayout)
  }
  
  public func removingLast() -> SyntaxCollection<SyntaxElement> {
    var newLayout = data.raw.layout
    newLayout.removeLast()
    return replacingLayout(newLayout)
  }
}

extension SyntaxCollection: Collection {
  public typealias Element = SyntaxElement
  
  public var startIndex: Int {
    return data.childCaches.startIndex
  }
  
  public var endIndex: Int {
    return data.childCaches.endIndex
  }
  
  public func index(after i: Int) -> Int {
    return data.childCaches.index(after: i)
  }
  
  public subscript(_ index: Int) -> Element {
    return child(at: index)! as! SyntaxElement
  }
}
