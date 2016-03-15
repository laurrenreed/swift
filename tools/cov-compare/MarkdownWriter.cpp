//===------- MarkdownWriter.cpp - Tools for analyzing llvm profdata -------===//
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

#include "MarkdownWriter.hpp"

using namespace llvm;
using namespace std;

namespace covcompare {
namespace md {
  std::string bold(std::string text) {
    return "**" + text + "**";
  }
  std::string italic(std::string text) {
    return "*" + text + "*";
  }
  std::string code(std::string text) {
    return "`" + text + "`";
  }
  std::string link(std::string desc, std::string url) {
    return "[" + desc + "](" + url + ")";
  }
}

  void MarkdownWriter::writeTable(raw_ostream &os) {
    os << "| ";
    for (auto &column : columns) {
      os << column.header << " | ";
    }
    os << "\n|";
    for (auto &column : columns) {
      auto leftMark = "-";
      auto rightMark = "-";
      switch (column.alignment) {
        case Column::Left:
          leftMark = ":";
          break;
        case Column::Right:
          rightMark = ":";
          break;
        case Column::Center:
          leftMark = ":";
          rightMark = ":";
          break;
      }
      os << leftMark << std::string(column.header.size(), '-') << rightMark
      << "|";
    }
    for (size_t i = 0; i < columns[0].elements.size(); i++) {
      os << "\n| ";
      for (auto &column : columns) {
        os << column.elements[i] << " | ";
      }
    }
  }
  void MarkdownWriter::writeAnalysis(raw_ostream &os) {
    vector<shared_ptr<FileComparison>> regressed;
    for (auto &cmp : comparisons) {
      if (cmp->coverageDifference() < 0.0) {
        regressed.push_back(cmp);
      }
    }
    if (regressed.size()) {
      os << "There are " << regressed.size() << " areas in this pull "
      << "request that need attention:\n\n";
      for (auto &cmp : regressed) {
        os << "  - " << md::code(cmp->newItem->name)
        << "'s coverage has regressed "
        << md::bold(formattedDouble(abs(cmp->coverageDifference())))
        << "\n";
      }
      os << "\n";
    } else {
      os << "There are no significant regressions in this pull request.\n";
    }
    os << "You've made changes to the following files:\n\n";
  }
  void MarkdownWriter::write(raw_ostream &os) {
    writeAnalysis(os);
    writeTable(os);
  }
  MarkdownWriter::MarkdownWriter(vector<shared_ptr<FileComparison>> comparisons)
  : comparisons(comparisons) {
    Column fnCol("Filename");
    Column prevCol("Previous Coverage", Column::Alignment::Center);
    Column currCol("Current Coverage", Column::Alignment::Center);
    Column regionCol("Regions Exec'd", Column::Alignment::Center);
    Column diffCol("Coverage Difference", Column::Alignment::Center);
    for (auto &cmp : comparisons) {
      std::string oldPercentage = cmp->oldItem ?
      formattedDouble(cmp->oldItem->coveragePercentage()) : "N/A";
      std::string newPercentage =
      formattedDouble(cmp->newItem->coveragePercentage());
      fnCol.add(md::code(cmp->newItem->name));
      prevCol.add(oldPercentage);
      currCol.add(newPercentage);
      auto pair = cmp->newItem->regionCounts();
      regionCol.add(to_string(pair.first) + "/" + to_string(pair.second));
      diffCol.add(cmp->formattedCoverageDifference());
    }
    auto coverages = covcompare::coveragePercentages(this->comparisons);
    auto oldTotal = coverages.first;
    auto newTotal = coverages.second;
    fnCol.elements.insert(fnCol.elements.begin(), "Total");
    prevCol.elements.insert(prevCol.elements.begin(),
                            formattedDouble(oldTotal));
    currCol.elements.insert(currCol.elements.begin(),
                            formattedDouble(oldTotal));
    regionCol.elements.insert(regionCol.elements.begin(),
                              "N/A");
    diffCol.elements.insert(diffCol.elements.begin(),
                            formattedDouble(newTotal - oldTotal));
    this->columns = { fnCol, prevCol, currCol, regionCol, diffCol };
  }
}
