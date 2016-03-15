//===------- MarkdownWriter.hpp - Tools for analyzing llvm profdata -------===//
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

#ifndef MarkdownWriter_hpp
#define MarkdownWriter_hpp

#include <stdio.h>
#include "ProfdataCompare.hpp"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FormattedStream.h"
#include "Writer.hpp"

namespace covcompare {
namespace md {
std::string bold(std::string text);
std::string italic(std::string text);
std::string code(std::string text);
std::string link(std::string desc, std::string url);
}

/// A class that wraps multiple columns and outputs them as a Markdown table.
class MarkdownWriter : public Writer {
private:
  void writeAnalysis(ProfdataCompare &c);

public:
  /// Writes this table to a stream.
  void write(ProfdataCompare &comparer);
  virtual void writeTable(std::vector<Column> columns, llvm::raw_ostream &os);
  virtual std::string formattedFilename(std::string filename);

  MarkdownWriter() {}
};
}

#endif /* MarkdownWriter_hpp */
