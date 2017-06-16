//
//  AtomicCache.swift
//  SwiftLanguage
//
//  Created by Harlan Haskins on 5/27/17.
//  Copyright © 2017 Harlan Haskins. All rights reserved.
//

import Foundation

/// AtomicCache is a wrapper class around an uninitialized value.
/// It takes a closure that it will use to create the value atomically. The
/// value is guaranteed to be set exactly one time, but the provided closure
/// may be called multiple times by threads racing to initialize the value.
/// Do not rely on the closure being called only one time.
class AtomicCache<Value: AnyObject> {
  /// The cached pointer that will be filled in the first time `value` is
  /// accessed.
  private var _cachedValue = UnsafeMutablePointer<AnyObject?>
                                .allocate(capacity: 1)

  /// The value inside this cache. If the value has not been initialized when
  /// this value is requested, then the closure will be called and its resulting
  /// value will be atomically compare-exchanged into the cache.
  /// If multiple threads access the value before initialization, they will all
  /// end up returning the correct, initialized value.
  /// - Parameter create: The closure that will return the fully realized value
  ///                     inside the cache.
  func value(_ create: () -> Value) -> Value {
    // Perform an atomic load -- if we get a value, then return it.
    if let _cached = _stdlib_atomicLoadARCRef(object: _cachedValue) {
      _onFastPath()
      return _cached as! Value
    }

    // Otherwise, create the value...
    let value = create()

    // ...and attempt to initialize the pointer with that value.
    if _stdlib_atomicInitializeARCRef(object: _cachedValue, desired: value) {
      // If we won the race, just return the value we made.
      return value
    }

    // Otherwise, perform _another_ load to get the up-to-date value,
    // and let the one we just made die.
    return _stdlib_atomicLoadARCRef(object: _cachedValue) as! Value
  }

  /// Creates a new AtomicCache that will hold the value returned by the
  /// provided closure.
  init() {
    self._cachedValue.pointee = nil
  }

  /// Free the underlying buffer.
  deinit {
    _cachedValue.deallocate(capacity: 1)
  }
}
