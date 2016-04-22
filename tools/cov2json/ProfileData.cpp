//===--------- ProfileData.cpp - Tools for loading llvm profdata -----------===//
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

#include "ProfileData.hpp"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/FormattedStream.h"
#include "swift/Basic/Demangle.h"
#include <cxxabi.h>

namespace llvm {
namespace cov2json {

/// Runs the provided function with a color set on ferrs().
void withColor(raw_ostream::Colors color, bool bold, bool bg,
               std::function<void()> f) {
  bool colored = sys::Process::StandardErrHasColors();
  if (colored)
    ferrs().changeColor(color, bold, bg);
  f();
  if (colored)
    ferrs().resetColor();
}

/// Prints an error message and exits with the error's value.
void exitWithErrorCode(std::error_code error) {
  withColor(raw_ostream::RED, /* bold = */ true, /* bg = */ false,
            [] { ferrs() << "error: "; });
  ferrs() << error.message() << "\n";
  exit(error.value());
}

/// Grabs the symbol from a string that's 'File.cpp:symbol',
/// or just returns the symbol if there's no ':'.
StringRef extractSymbol(StringRef name) {
  auto pair = name.split(':');
  if (pair.second == "") {
    return pair.first;
  } else {
    return pair.second;
  }
}

/// Returns the demangled (Swift or C++) version of `symbol`
/// into the `out` buffer.
void getDemangled(std::string symbol, std::string &out) {
  auto prefix = symbol.substr(0, 2);
  if (prefix == "_Z") {
    auto demangled = abi::__cxa_demangle(symbol.data(), 0, 0, NULL);
    if (demangled) {
      std::string s(demangled);
      free(demangled);
      out = s;
    }
  } else if (prefix == "_T") {
    out = swift::Demangle::demangleSymbolAsString(symbol);
  }
  out = symbol;
}

/// Opens a stream to a file, or stdout if "" is provided.
std::unique_ptr<raw_ostream> streamForFile(StringRef file) {
  if (file.size()) {
    std::error_code error;
    auto os = make_unique<raw_fd_ostream>(file, error, sys::fs::F_RW);
    if (error)
      exitWithErrorCode(error);
    return move(os);
  } else {
    return make_unique<raw_fd_ostream>(fileno(stdout),
                                       /* shouldClose = */ false);
  }
}

/// Creates a Function struct off of a FunctionRecord.
Function::Function(const coverage::FunctionRecord &record) {
  auto symbol = extractSymbol(record.Name);
  getDemangled(symbol, this->name);
  for (auto &region : record.CountedRegions) {
    if (region.FileID != region.ExpandedFileID)
      continue;
    if (region.Kind !=
        llvm::coverage::CounterMappingRegion::RegionKind::CodeRegion)
      continue;
    Region r(region.ColumnStart, region.ColumnEnd, region.LineStart,
             region.LineEnd, region.ExecutionCount);
    regions.emplace_back(r);
  }
  executionCount = record.ExecutionCount;
}

/// Loads a CoverageMapping for a CoverageFilePair
std::unique_ptr<llvm::coverage::CoverageMapping>
CoverageFilePair::coverageMapping() {
  
  auto map = llvm::coverage::CoverageMapping::load(binary, filename);
  
  if (auto error = map.getError()) {
    exitWithErrorCode(error);
  }
  
  return move(map.get());
}

/// Loads a list of files that are within the provided coveredDir.
void CoverageFilePair::loadFileMap(std::vector<File> &files,
                                   StringRef coveredDir) {
  auto mapping = coverageMapping();
  for (auto &filename : mapping->getUniqueSourceFiles()) {
    StringRef truncatedFilename = filename;
    if (coveredDir != "") {
      if (!filename.startswith(coveredDir)) {
        continue;
      }
      StringRef parentPath = sys::path::parent_path(coveredDir);
      truncatedFilename = filename.substr(parentPath.size(),
                                          filename.size() - parentPath.size());
    }
    std::vector<Function> functions;
    for (auto &func : mapping->getCoveredFunctions(filename)) {
      functions.emplace_back(func);
    }
    files.emplace_back(File(truncatedFilename, functions));
  }
}
  
}
}
