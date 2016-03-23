//===--------- HTMLWriter.cpp - Tools for comparing llvm profdata ---------===//
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

#include "HTMLWriter.hpp"
#include "MarkdownWriter.hpp"
#include "ProfdataCompare.hpp"
#include <libgen.h>
#include <sys/stat.h>
#include <chrono>

using namespace llvm;
namespace html {
/// \returns An HTML-escaped string.
std::string escape(std::string s) {
  std::string result;
  for (size_t i = 0; i < s.size(); ++i) {
    std::string token = s.substr(i, 1);
    if (token == "&")
      token = "&amp;";
    else if (token == "<")
      token = "&lt;";
    else if (token == "\"")
      token = "&quot;";
    else if (token == ">")
      token = "&gt;";
    result += token;
  }
  return result;
}

/// \returns A tag around the provided text
/// (expects the value to be properly escaped).
std::string tag(std::string name, std::string text) {
  return "<" + name + ">" + text + "</" + name + ">";
}

/// \returns An anchor tag with the provided destination and text.
std::string a(std::string dest, std::string text) {
  return "<a href='" + dest + "'>" + text + "</a>";
}

/// \returns Headers of an HTML table, corresponding to the passed-in strings.
std::string headerRow(std::vector<std::string> headers) {
  std::string final;
  for (auto &val : headers) {
    final += tag("th", val);
  }
  return tag("tr", final);
}

/// \returns An HTML table row with the provided strings as td rows inside.
std::string tr(std::vector<std::string> data) {
  std::string final;
  for (auto &val : data) {
    final += tag("td", val);
  }
  return tag("tr", final);
}

/// \returns A span with the provided class, with the provided text inside.
std::string span(std::string _class, std::string text) {
  return "<span class='" + _class + "'>" + text + "</span>";
}
}

namespace covcompare {
typedef enum { Bad, Warning, Good } CoverageStatus;

/// \returns The class name corresponding to a CoverageStatus.
std::string coverageStatusString(CoverageStatus status) {
  switch (status) {
  case Bad:
    return "bad";
  case Warning:
    return "warning";
  case Good:
    return "good";
  }
}

CoverageStatus statusForDiff(double diff) {
  bool isSmallDiff = fabs(diff) < 5.0;
  bool isNegative = diff < 0;
  if (isNegative) {
    return isSmallDiff ? Warning : Bad;
  } else {
    return Good;
  }
}

std::string HTMLWriter::formattedDiff(double n) {
  auto status = statusForDiff(n);
  auto spanClass = coverageStatusString(status);
  return html::span(spanClass, Writer::formattedDiff(n));
}

std::string HTMLWriter::formattedFilename(std::string filename) {
  auto path = sys::path::relative_path(filename);
  auto fn = html::escape(path);
  return html::a(fn + ".html", fn);
}

void HTMLWriter::writeTable(std::vector<Column> &columns,
                            llvm::raw_ostream &os) {
  os << "<table>";
  std::vector<std::string> headers;
  for (auto &column : columns) {
    headers.emplace_back(column.header);
  }
  os << html::headerRow(headers);
  for (size_t i = 0; i < columns[0].elements.size(); i++) {
    std::vector<std::string> elements;
    for (auto &column : columns) {
      elements.emplace_back(column.elements[i]);
    }
    os << html::tr(elements);
  }
  os << "</table>";
}

void HTMLWriter::write(ProfdataCompare &comparer) {
  if (auto err = sys::fs::create_directories(dirname)) {
    exitWithErrorCode(err);
  }
  writeSummary(comparer);
  for (auto &comparison : comparer.comparisons) {
    writeComparisonReport(*comparison);
  }
}

void HTMLWriter::writeComparisonReport(FileComparison &comparison) {
  auto newName = dirname + "/" + comparison.newItem->name + ".html";
  auto base = sys::path::parent_path(newName);
  if (auto err = sys::fs::create_directories(base)) {
    exitWithErrorCode(err);
  }
  std::error_code error;
  raw_fd_ostream os(newName, error, sys::fs::F_RW);
  if (error)
    exitWithErrorCode(error);
  wrapHTMLOutput(os, comparison.newItem->name, [this, &comparison, &os] {
    Column functionCol("Function");
    Column oldCovCol("Previous Coverage", Column::Alignment::Center);
    Column newCovCol("Current Coverage", Column::Alignment::Center);
    Column regionCol("Regions Exec'd", Column::Alignment::Center);
    Column diffCol("Coverage Difference", Column::Alignment::Center);
    for (auto &funcComparison : comparison.functionComparisons()) {
      double newCoverage = funcComparison.newItem->coveragePercentage();
      std::string newCovString = formattedDouble(newCoverage);
      std::string oldCovString = "N/A";
      std::string diffString = "N/A";
      if (auto func = funcComparison.oldItem) {
        double oldCoverage = func->coveragePercentage();
        oldCovString = formattedDouble(oldCoverage);
        diffString = formattedDiff(newCoverage - oldCoverage);
      }
      auto regionCounts = funcComparison.newItem->regionCounts();
      regionCol.add(std::to_string(regionCounts.first) + "/" +
                    std::to_string(regionCounts.second));
      std::string symbol = funcComparison.functionName();
      functionCol.add(html::escape(symbol));
      oldCovCol.add(oldCovString);
      newCovCol.add(newCovString);
      diffCol.add(diffString);
    }
    std::vector<Column> table = {
      functionCol,
      oldCovCol,
      newCovCol,
      regionCol,
      diffCol
    };
    this->writeTable(table, os);
  });
}

void HTMLWriter::writeSummary(ProfdataCompare &comparer) {
  std::error_code error;
  raw_fd_ostream os(dirname + "/index.html", error, sys::fs::F_RW);
  if (error)
    exitWithErrorCode(error);

  std::string oldFn = sys::path::filename(comparer.oldFile);
  std::string newFn = sys::path::filename(comparer.newFile);
  auto title = oldFn + " vs. " + newFn;

  wrapHTMLOutput(os, title, [this, &comparer, &os] {
    auto table = tableForComparisons(comparer.comparisons);
    this->writeTable(table, os);
  });
}

void HTMLWriter::writeCSS(raw_ostream &os) {
// bring in the `css` variable.
#include "CoverageCSS.inc"
  os << css;
}

void HTMLWriter::wrapHTMLOutput(raw_ostream &out, std::string title,
                                HTMLOutputFunction innerGen) {
  out << "<!DOCTYPE html>\n"
         "<html>\n"
         "  <head>\n"
      << "    " << html::tag("title", title)
      << "    <meta name='viewport'"
         "content='width=device-width, initial-scale=1'>";
  out << "    <style>";
  writeCSS(out);
  out << "    </style>";
  out << "  </head>\n"
         "  <body>";
  innerGen();

  auto end = std::chrono::system_clock::now();
  auto end_time = std::chrono::system_clock::to_time_t(end);
  auto date_str = ctime(&end_time);
  out << html::tag("footer",
                   "Generated by cov-compare on " + html::escape(date_str));
  out << "  </body>\n"
         "</html>";
}
}
