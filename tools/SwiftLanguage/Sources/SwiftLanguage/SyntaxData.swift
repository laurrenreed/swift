import Foundation

/// SyntaxData is the underlying storage for each Syntax node.
final class SyntaxData: Equatable {
  let raw: RawSyntax
  let indexInParent: Int
  weak var parent: SyntaxData?

  let childCaches: [AtomicCache<SyntaxData>]

  required init(raw: RawSyntax, indexInParent: Int = 0, parent: SyntaxData?) {
    self.raw = raw
    self.indexInParent = indexInParent
    self.parent = parent
    self.childCaches = raw.layout.map { _ in AtomicCache<SyntaxData>() }
  }

  convenience init<CursorType: RawRepresentable>(
      raw: RawSyntax, cursorInParent: CursorType,
      parent: SyntaxData?) where CursorType.RawValue == Int {
    self.init(raw: raw, indexInParent: cursorInParent.rawValue, parent: parent)
  }

  func cachedChild(at index: Int) -> SyntaxData {
    return childCaches[index].value { realizeChild(index) }
  }

  func cachedChild<CursorType: RawRepresentable>(at cursor: CursorType) -> SyntaxData
    where CursorType.RawValue == Int {
    return cachedChild(at: cursor.rawValue)
  }

  /// Creates a copy of `self` and puts it into a `SyntaxNode`
  /// - parameter newRaw: The new RawSyntax that will back the new `Data`
  /// - returns: A generic `SyntaxNode` with `self`
  func replacingSelf(_ newRaw: RawSyntax) -> (root: SyntaxData, newValue: SyntaxData) {
    let newMe = SyntaxData(raw: newRaw, indexInParent: indexInParent,
                           parent: nil)
    if let parent = parent {
      let (root, newParent) = parent.replacingChild(newRaw, at: indexInParent)
      newMe.parent = newParent
      return (root: root, newValue: newMe)
    } else {
      return (root: newMe, newValue: newMe)
    }
  }

  /// Creates a copy of `self` with the child at the provided index replaced
  /// with a new SyntaxData containing the raw syntax provided.
  ///
  /// - Parameters:
  ///   - child: The raw syntax for the new child to replace.
  ///   - index: The index pointing to where in the raw layout to place this
  ///            child.
  /// - Returns: The new root node created by this operation, and the new child
  ///            syntax data.
  func replacingChild(_ child: RawSyntax, at index: Int) -> (root: SyntaxData, newValue: SyntaxData) {
    let newRaw = raw.replacingChild(index, with: child)
    return replacingSelf(newRaw)
  }

  /// Creates a copy of `self` with the child at the provided cursor replaced
  /// with a new SyntaxData containing the raw syntax provided.
  ///
  /// - Parameters:
  ///   - child: The raw syntax for the new child to replace.
  ///   - cursor: The cursor pointing to where in the raw layout to place this
  ///             child.
  /// - Returns: The new root node created by this operation, and the new child
  ///            syntax data.
  func replacingChild<
    CursorType: RawRepresentable
   >(_ child: RawSyntax, at cursor: CursorType) -> (root: SyntaxData, newValue: SyntaxData)
    where CursorType.RawValue == Int {
    return replacingChild(child, at: cursor.rawValue)
  }

  /// Creates the child's syntax data for the provided cursor.
  ///
  /// - Parameter cursor: The cursor pointing into the raw syntax's layout for
  ///                     the child you're creating.
  /// - Returns: A new SyntaxData subclass for the specific child you're
  ///            creating.
  func realizeChild<
    ChildType: SyntaxData, CursorType: RawRepresentable
    >(_ cursor: CursorType) -> ChildType where CursorType.RawValue == Int {
    return realizeChild(cursor.rawValue)
  }

  /// Creates the child's syntax data for the provided index.
  ///
  /// - Parameter index: The index pointing into the raw syntax's layout for
  ///                    the child you're creating.
  /// - Returns: A new SyntaxData subclass for the specific child you're
  ///            creating.
  func realizeChild<ChildType: SyntaxData>(_ index: Int) -> ChildType {
    return ChildType.init(raw: raw.layout[index],
                          indexInParent: index,
                          parent: self)
  }

  /// Tells whether two SyntaxData nodes have the same identity.
  /// This is not structural equality.
  /// - Returns: True if both datas are exactly the same.
  static func ==(lhs: SyntaxData, rhs: SyntaxData) -> Bool {
    return lhs === rhs
  }
}
