//===---------- CSVWriter.hpp - Tools for comparing llvm profdata ---------===//
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

#ifndef CSVWriter_hpp
#define CSVWriter_hpp

#include "ProfdataCompare.hpp"
#include "Writer.hpp"
#include <stdio.h>

namespace covcompare {
class CSVWriter : public Writer {
public:
  virtual std::string formattedFilename(std::string filename);
  virtual void writeTable(std::vector<Column> &columns,
                          llvm::raw_ostream &os);
  virtual void write(ProfdataCompare &comparer);
  CSVWriter() {}
};
}
#endif /* CSVWriter_hpp */
