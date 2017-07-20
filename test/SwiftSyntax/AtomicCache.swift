// RUN: %target-run-simple-swift
// REQUIRES: executable_test

import StdlibUnittest
@testable import SwiftSyntax
import Foundation
import Dispatch

var AtomicCacheAPI = TestSuite("AtomicCacheAPI")

class Foo: CustomStringConvertible, Equatable {
  static func ==(lhs: Foo, rhs: Foo) -> Bool {
    return lhs === rhs
  }

  var description: String {
    return ObjectIdentifier(self).debugDescription
  }
}

AtomicCacheAPI.test("Pathological") {
  let cache = AtomicCache<Foo>()

  DispatchQueue.concurrentPerform(iterations: 100) { _ in
    expectEqual(cache.value(Foo.init), cache.value(Foo.init))
  }
}

AtomicCacheAPI.test("TwoAccesses") {
  let cache = AtomicCache<Foo>()

  let queue1 = DispatchQueue(label: "queue1")
  let queue2 = DispatchQueue(label: "queue2")

  var d1: Foo?
  var d2: Foo?

  let group = DispatchGroup()
  queue1.async(group: group) {
    d1 = cache.value(Foo.init)
  }
  queue2.async(group: group) {
    d2 = cache.value(Foo.init)
  }
  group.wait()

  let final = cache.value(Foo.init)

  expectNotNil(d1)
  expectNotNil(d2)
  expectEqual(d1, d2)
  expectEqual(d1, final)
}