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

namespace covcompare {
  namespace md {
    std::string bold(std::string text);
    std::string italic(std::string text);
    std::string code(std::string text);
    std::string link(std::string desc, std::string url);
  }
  /// A struct that holds a 'column' of information, as represented in a table.
  struct Column {
    /// The alignment of the column,
    /// respected if possible in the output medium.
    typedef enum {
      Left,
      Center,
      Right
    } Alignment;
    
    /// The 'header' at the top of the column in a table.
    std::string header;
    
    /// The individual elements per row of this column.
    std::vector<std::string> elements;
    
    /// The alignment of the values in this column.
    Alignment alignment;
    
    /// A shortcut to add a value to this column.
    void add(std::string val) {
      elements.push_back(val);
    }
    
    Column(std::string header, Alignment alignment = Left,
           std::vector<std::string> elements = {})
    : header(header), elements(elements), alignment(alignment) {}
  };
  
  /// A class that wraps multiple columns and outputs them as a Markdown table.
  class MarkdownWriter {
  private:
    void writeTable(raw_ostream &os);
    void writeAnalysis(raw_ostream &os);
    std::string bold(std::string text);
    std::string code(std::string text);
  public:
    /// The comparisons this writer will analyze.
    std::vector<std::shared_ptr<FileComparison>> comparisons;
    
    /// The columns this writer will write.
    std::vector<Column> columns;
    
    /// Writes this table to a stream.
    void write(llvm::raw_ostream &os);
    
    MarkdownWriter(std::vector<std::shared_ptr<FileComparison>> comparisons)
    : comparisons(comparisons) {
      double oldTotal = 0.0;
      double oldCount = 0.0;
      double newTotal = 0.0;
      double newCount = comparisons.size();
      Column fnCol("Filename");
      Column prevCol("Previous Coverage", Column::Alignment::Center);
      Column currCol("Current Coverage", Column::Alignment::Center);
      Column diffCol("Coverage Difference", Column::Alignment::Center);
      for (auto &cmp : comparisons) {
        dbgs() << "Creating column for: " << cmp->newItem->name << "\n";
        if (auto old = cmp->oldItem) {
          oldTotal += old->coveragePercentage();
          oldCount += 1.0;
        }
        newTotal += cmp->newItem->coveragePercentage();
        std::string oldPercentage = cmp->oldItem ?
          formattedDouble(cmp->oldItem->coveragePercentage()) : "N/A";
        std::string newPercentage =
          formattedDouble(cmp->newItem->coveragePercentage());
        newTotal += cmp->newItem->coveragePercentage();
        fnCol.add(md::code(cmp->newItem->name));
        prevCol.add(oldPercentage);
        currCol.add(newPercentage);
        diffCol.add(cmp->formattedCoverageDifference());
      }
      if (oldCount > 0.0) {
        oldTotal /= oldCount;
      }
      newTotal /= newCount;
      fnCol.elements.insert(fnCol.elements.begin(), "Total");
      prevCol.elements.insert(prevCol.elements.begin(), formattedDouble(oldTotal));
      currCol.elements.insert(currCol.elements.begin(), formattedDouble(oldTotal));
      diffCol.elements.insert(diffCol.elements.begin(), formattedDouble(newTotal - oldTotal));
      this->columns = { fnCol, prevCol, currCol, diffCol };
    }
  };
}

#endif /* MarkdownWriter_hpp */
