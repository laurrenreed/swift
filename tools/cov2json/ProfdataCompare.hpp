//===------ ProfdataCompare.hpp - Tools for analyzing llvm profdata -------===//
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

#ifndef ProfdataCompare_hpp
#define ProfdataCompare_hpp

#include <stdio.h>
#include <iostream>
#include "llvm/ProfileData/InstrProfReader.h"
#include "llvm/ProfileData/CoverageMappingReader.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Path.h"
#include "Utils.hpp"
#include <map>
#include <set>

using namespace llvm;

namespace cov2json {

struct Region {
public:
  unsigned columnStart, columnEnd, lineStart, lineEnd;
  uint64_t executionCount;

  Region(unsigned columnStart, unsigned columnEnd, unsigned lineStart,
         unsigned lineEnd, uint64_t executionCount)
      : columnStart(columnStart), columnEnd(columnEnd), lineStart(lineStart),
        lineEnd(lineEnd), executionCount(executionCount) {}
  Region(llvm::coverage::CountedRegion &region)
      : Region(region.ColumnStart, region.ColumnEnd, region.LineStart,
               region.LineEnd, region.ExecutionCount) {}
  Region() {}
};

struct Function {
public:
  std::string name;
  std::vector<Region> regions;
  uint64_t executionCount;
  Function(std::string name, std::vector<Region> regions,
           uint64_t executionCount)
      : name(name), regions(regions), executionCount(executionCount) {}

  Function(llvm::coverage::FunctionRecord record) {
    name = extractSymbol(record.Name);
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

  Function(const Function &copy)
      : name(copy.name), regions(copy.regions),
        executionCount(copy.executionCount) {}

  Function(Function &copy)
      : name(copy.name), regions(copy.regions),
        executionCount(copy.executionCount) {}

  Function() {}
};

/// A struct that stores all functions associated with a given source file.
struct File {

  std::shared_ptr<std::map<std::string, std::shared_ptr<Function>>>
      _functionMap;

public:
  std::string name;
  std::vector<Function> functions;

  /// \returns A map of function symbols to the
  /// corresponding Functions.
  std::shared_ptr<std::map<std::string, std::shared_ptr<Function>>>
  functionMap();

  File(std::string name, std::vector<Function> functions)
      : name(name), functions(functions) {}

  File(File &copy)
      : _functionMap(copy._functionMap), name(copy.name),
        functions(copy.functions) {}

  File(const File &copy)
      : _functionMap(copy._functionMap), name(copy.name),
        functions(copy.functions) {}

  File() {}
};


/// A struct that represents a pair of binary file and profdata file,
/// which reads and digests the contents of those files.
struct CoverageFilePair {
public:
  /// The .profdata file path.
  std::string filename;

  /// The binary file path that generated the .profdata.
  std::string binary;

  /// \returns A CoverageMapping object corresponding
  /// to the binary and profdata.
  std::unique_ptr<llvm::coverage::CoverageMapping> coverageMapping();

  /// \returns A map of filenames to File
  /// objects that are covered in this profdata.
  std::map<std::string, std::shared_ptr<File>> fileMap(std::string coveredDir);

  CoverageFilePair(std::string filename, std::string binary)
      : filename(filename), binary(binary) {}
};

int jsonMain(int argc, const char *argv[]);

} // namespace cov2json;

#endif /* ProfdataCompare_hpp */
