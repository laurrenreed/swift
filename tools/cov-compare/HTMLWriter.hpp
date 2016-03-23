//===--------- HTMLWriter.hpp - Tools for comparing llvm profdata ---------===//
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

#ifndef HTMLWriter_hpp
#define HTMLWriter_hpp

#include <stdio.h>
#include "ProfdataCompare.hpp"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FormattedStream.h"
#include "Writer.hpp"

namespace covcompare {
/// A typedef for a function that purely executes side effects.
typedef std::function<void()> HTMLOutputFunction;

/// A struct that writes a directory of HTML files
/// representing a ProfdataCompare object.
///
/// The directory structure looks like:
///
///   - main directory:
///     - /index.html [a summary of each file and the coverage diff]
///     - /dir1/file1.cpp.html
///     - /dir1/subdir1/.../file2.cpp.html
///     - ...
///     - /dirN/fileM.cpp.html
struct HTMLWriter : public Writer {
  /// The path to the output directory.
  std::string dirname;

  /// Writes a basic CSS file that has CSS classes
  /// for good, okay, and bad coverage.
  void writeCSS(raw_ostream &os);

  /// Writes a detailed list of functions within a comparison,
  /// and their current coverage status.
  void writeComparisonReport(FileComparison &comparison);

  /// Writes a list of \a Columns as an HTML table.
  virtual void writeTable(std::vector<Column> &columns, llvm::raw_ostream &os);

  /// Writes a summary of each file with a link to the in-depth file page,
  /// and a simple diff of the coverage.
  void writeSummary(ProfdataCompare &comparer);

  /// Writes the skeleton of an HTML file, and calls the callback that
  /// is intended to output the body of the HTML.
  void wrapHTMLOutput(llvm::raw_ostream &os, std::string title,
                      HTMLOutputFunction innerGen);

  virtual std::string formattedDiff(double n);
  virtual std::string formattedFilename(std::string filename);

public:
  /// Writes a full directory corresponding to the
  /// provided ProfdataCompare object.
  void write(ProfdataCompare &comparer);
  HTMLWriter(std::string dirname) : dirname(dirname) {}
};
}

#endif /* HTMLWriter_hpp */
