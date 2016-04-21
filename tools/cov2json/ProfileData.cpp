//===------ ProfdataCompare.cpp - Tools for comparing llvm profdata -------===//
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

using namespace llvm;
namespace cov2json {

std::unique_ptr<llvm::coverage::CoverageMapping>
    CoverageFilePair::coverageMapping() {
  auto map = llvm::coverage::CoverageMapping::load(binary, filename);

  if (auto error = map.getError()) {
    exitWithErrorCode(error);
  }

  return move(map.get());
}

std::shared_ptr<std::map<std::string, std::shared_ptr<Function>>>
File::functionMap() {
  if (_functionMap)
    return _functionMap;
  _functionMap =
      std::make_shared<std::map<std::string, std::shared_ptr<Function>>>();
  for (auto &function : functions) {
    (*_functionMap)[function.name] = std::make_shared<Function>(function);
  }
  return _functionMap;
}

void CoverageFilePair::loadFileMap(std::vector<File> &files,
                                   std::string coveredDir) {
  auto mapping = coverageMapping();
  for (auto &filename : mapping->getUniqueSourceFiles()) {
    std::string truncatedFilename = filename;
    if (coveredDir != "") {
      if (!filename.startswith(coveredDir)) {
        continue;
      }
      std::string parentPath = sys::path::parent_path(coveredDir);
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
