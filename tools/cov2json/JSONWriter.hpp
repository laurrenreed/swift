//===--------- YAMLWriter.hpp - Tools for analyzing llvm profdata ---------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#ifndef YAMLWriter_hpp
#define YAMLWriter_hpp

#include <stdio.h>
#include "swift/Basic/JSONSerialization.h"
#include "ProfdataCompare.hpp"

namespace swift {
namespace json {

template <typename U> struct ArrayTraits<std::vector<U>> {
  static size_t size(Output &out, std::vector<U> &seq) { return seq.size(); }
  static U &element(Output &out, std::vector<U> &seq, size_t index) {
    if (seq.size() <= index) {
      seq.resize(index + 1);
    }
    return seq[index];
  }
};

template <> struct ObjectTraits<cov2json::Region> {
  static void mapping(Output &out, cov2json::Region &region) {
    out.mapRequired("column-start", region.columnStart);
    out.mapRequired("column-end", region.columnEnd);
    out.mapRequired("line-start", region.lineStart);
    out.mapRequired("line-end", region.lineEnd);
    out.mapRequired("count", region.executionCount);
  }
};

template <> struct ObjectTraits<cov2json::Function> {
  static void mapping(Output &out, cov2json::Function &function) {
    out.mapRequired("name", function.name);
    out.mapRequired("regions", function.regions);
    out.mapRequired("count", function.executionCount);
  }
};

template <> struct ObjectTraits<cov2json::File> {
  static void mapping(Output &out, cov2json::File &file) {
    out.mapRequired("filename", file.name);
    out.mapRequired("functions", file.functions);
  }
};
    
}
}
#endif /* YAMLWriter_hpp */
