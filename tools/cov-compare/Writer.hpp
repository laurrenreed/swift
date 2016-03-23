//
//  Column.hpp
//  cov-compare
//
//  Created by Harlan Haskins on 3/15/16.
//  Copyright © 2016 Harlan Haskins. All rights reserved.
//

#ifndef Writer_hpp
#define Writer_hpp

#include <stdio.h>
#include <vector>
#include <string>
#include "ProfdataCompare.hpp"

namespace covcompare {
/// A struct that holds a 'column' of information, as represented in a table.
struct Column {
  /// The alignment of the column,
  /// respected if possible in the output medium.
  typedef enum { Left, Center, Right } Alignment;

  /// The 'header' at the top of the column in a table.
  std::string header;

  /// The individual elements per row of this column.
  std::vector<std::string> elements;

  /// The alignment of the values in this column.
  Alignment alignment;

  /// Add a value to the end of this column.
  void add(const std::string val) { elements.emplace_back(val); }

  /// Insert a value into the column at a specific index.
  void insert(size_t index, const std::string val) {
    elements.insert(elements.begin(), index, val);
  }

  Column(std::string header, Alignment alignment = Left,
         std::vector<std::string> elements = {})
      : header(header), elements(elements), alignment(alignment) {}
};

class Writer {
protected:
  virtual void writeTable(std::vector<Column> &columns,
                          llvm::raw_ostream &os) = 0;
  std::string formattedDouble(double n);
  virtual std::string formattedDiff(double n);
  virtual std::string formattedFilename(std::string filename) = 0;
  std::vector<Column> tableForComparisons(
      std::vector<std::shared_ptr<FileComparison>> &comparisons);

public:
  /// Writes a full directory corresponding to the
  /// provided ProfdataCompare object.
  virtual void write(ProfdataCompare &comparer) = 0;
  Writer() {}
};
}

#endif /* Writer_hpp */
