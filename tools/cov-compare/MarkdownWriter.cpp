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

namespace covcompare {
namespace md {
std::string bold(std::string text) { return "**" + text + "**"; }
std::string italic(std::string text) { return "*" + text + "*"; }
std::string code(std::string text) { return "`" + text + "`"; }
std::string link(std::string desc, std::string url) {
  return "[" + desc + "](" + url + ")";
}
}

std::string MarkdownWriter::formattedFilename(std::string filename) {
  return md::code(filename);
}

void MarkdownWriter::writeTable(std::vector<Column> &columns, raw_ostream &os) {
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

void MarkdownWriter::writeDropdownTable(
    std::vector<std::shared_ptr<FileComparison>> &comparisons,
    std::string title, bool expanded, raw_ostream &os) {

  auto table = tableForComparisons(comparisons);
  os << "<details" << (expanded ? " open" : "") << ">\n  <summary>"
     << title << "</summary>\n\n";
  writeTable(table, os);
  os << "\n\n</details>\n";
}

void MarkdownWriter::writeAnalysis(
    ProfdataCompare &c,
    std::vector<std::shared_ptr<FileComparison>> &regressed) {
  if (regressed.size()) {
    *c.os << "There are " << regressed.size() << " areas in this pull "
          << "request that need attention:\n\n";
    for (auto &cmp : regressed) {
      *c.os << "  - " << md::code(cmp->newItem->name)
            << "'s coverage has regressed "
            << md::bold(formattedDouble(std::abs(cmp->coverageDifference())))
            << "\n";
    }
    *c.os << "\n";
  } else {
    *c.os << "There are no significant regressions in this pull request.\n";
  }
  *c.os << "You've made changes to the following files:\n\n";
}

void MarkdownWriter::write(ProfdataCompare &comparer) {
  std::vector<std::shared_ptr<FileComparison>> regressed;
  std::vector<std::shared_ptr<FileComparison>> unchanged;
  std::vector<std::shared_ptr<FileComparison>> improved;
  for (auto &cmp : comparer.comparisons) {
    double diff = cmp->coverageDifference();
    if (diff < 0.0) {
      regressed.emplace_back(cmp);
    } /* else if (diff == 0.0) {
      unchanged.emplace_back(cmp);
    } else {
      improved.emplace_back(cmp);
    } */
  }
  writeAnalysis(comparer, regressed);
  auto coverages = covcompare::coveragePercentages(comparer.comparisons);
  
#if 0
  fnCol.insert(0, "Total");
  prevCol.insert(0, formattedDouble(oldTotal));
  currCol.insert(0, formattedDouble(oldTotal));
  regionCol.insert(0, "N/A");
  diffCol.insert(0, formattedDouble(newTotal - oldTotal));

  writeDropdownTable(regressed, "Regressions", true, *comparer.os);
  writeDropdownTable(improved, "Improvements", true, *comparer.os);
  writeDropdownTable(unchanged, "Unchanged", false, *comparer.os);
#endif
  
  auto cols = tableForComparisons(comparer.comparisons);
  writeTable(cols, *comparer.os);
}
}
