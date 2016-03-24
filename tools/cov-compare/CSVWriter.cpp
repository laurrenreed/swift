//===---------- CSVWriter.cpp - Tools for comparing llvm profdata ---------===//
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

#include "CSVWriter.hpp"

namespace covcompare {
  std::string quote(std::string str) {
    return "\"" + str + "\"";
  }
  std::string CSVWriter::formattedFilename(std::string filename) {
    return quote(filename);
  }
  void CSVWriter::writeTable(std::vector<Column> &columns,
                             raw_ostream &os) {
    for (auto &col : columns) {
      os << col.header << ",";
    }
    os << "\n";
    for (size_t i = 0; i < columns[0].elements.size(); ++i) {
      for (size_t j = 0; j < columns.size(); ++j) {
        os << quote(columns[j].elements[i]);
        if (j < columns.size() - 1) {
          os << ",";
        }
      }
      os << "\n";
    }
  }
  void CSVWriter::write(ProfdataCompare &comparer) {
    auto table = tableForComparisons(comparer.comparisons);
    writeTable(table, *comparer.os);
  }
}