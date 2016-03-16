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

#include "ProfdataCompare.hpp"
#include "llvm/Support/CommandLine.h"
#include "HTMLWriter.hpp"
#include "MarkdownWriter.hpp"
#include "YAMLWriter.hpp"

using namespace llvm;
using namespace coverage;

namespace covcompare {
template <typename T, typename U>
inline std::pair<T, U> operator+(const std::pair<T, U> &l,
                                 const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}
  
inline double percent(double x, double y) {
  return (x / y) * 100.0;
}

template<typename T>
inline double percent(T x, T y) {
  return percent(double(x), double(y));
}

std::pair<double, double>
coveragePercentages(std::vector<std::shared_ptr<FileComparison>> &comparisons) {
  std::pair<int, int> oldCounts = {0, 0};
  std::pair<int, int> newCounts = {0, 0};
  for (auto &cmp : comparisons) {
    if (auto old = cmp->oldItem) {
      oldCounts = oldCounts + old->regionCounts();
    }
    newCounts = newCounts + cmp->newItem->regionCounts();
  }
  return { percent(newCounts.first, newCounts.second),
           percent(oldCounts.first, oldCounts.second) };
}

double File::coveragePercentage() {
  if (functions.empty())
    return 100.0;
  double totalPercentagePoints = 0;
  for (auto &func : functions) {
    totalPercentagePoints += func.coveragePercentage();
  }
  return (totalPercentagePoints / (double)functions.size());
}

std::pair<int, int> Function::regionCounts() {
  int regions = 0;
  int regionsExecuted = 0;
  for (auto &region : this->regions) {
    if (region.executionCount > 0) {
      regionsExecuted++;
    }
    regions++;
  }
  return { regionsExecuted, regions };
}

std::pair<int, int> File::regionCounts() {
  std::pair<int, int> counts = { 0, 0 };
  for (auto &func : functions) {
    counts = counts + func.regionCounts();
  }
  return counts;
}

std::vector<FunctionComparison> FileComparison::functionComparisons() {
  std::vector<FunctionComparison> funcComparisons;
  for (auto &function : newItem->functions) {
    std::shared_ptr<Function> oldFunction;
    if (oldItem) {
      auto pair = oldItem->functionMap()->find(function.name);
      if (pair != oldItem->functionMap()->end()) {
        oldFunction = pair->second;
      }
    }
    auto func =
        FunctionComparison(oldFunction, std::make_shared<Function>(function));
    funcComparisons.emplace_back(func);
  }
  return funcComparisons;
}

std::unique_ptr<CoverageMapping> CoverageFilePair::coverageMapping() {
  auto map = CoverageMapping::load(binary, filename);

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

std::map<std::string, std::shared_ptr<File>>
CoverageFilePair::fileMap(std::string coveredDir) {
  auto mapping = coverageMapping();
  std::map<std::string, std::shared_ptr<File>> files;
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
    files[filename] = std::make_shared<File>(truncatedFilename, functions);
  }
  return files;
}

std::map<std::string, File> fileMapFromYAML(std::string yamlFile) {
  auto buffer = MemoryBuffer::getFile(yamlFile);
  if (auto error = buffer.getError()) {
    exitWithErrorCode(error);
  }
  yaml::Input yin(buffer.get()->getBuffer());
  std::vector<File> files;
  yin >> files;
  if (auto error = yin.error()) {
    exitWithErrorCode(error);
  }
  std::map<std::string, File> fileMap;
  for (auto &file : files) {
    fileMap[file.name] = file;
  }
  return fileMap;
}

std::string FunctionComparison::functionName() {
  auto name = extractSymbol(newItem->name);
  return demangled(name);
}

std::vector<std::shared_ptr<FileComparison>> ProfdataCompare::genComparisons() {
  std::vector<std::shared_ptr<FileComparison>> comparisons;
  auto oldFiles = fileMapFromYAML(oldFile);
  auto newFiles = fileMapFromYAML(newFile);
  for (auto &iter : newFiles) {
    std::shared_ptr<File> oldFile;
    auto old = oldFiles.find(iter.first);
    if (old != oldFiles.end()) {
      oldFile = std::make_shared<File>(old->second);
    }
    auto newFile = std::make_shared<File>(iter.second);
    auto c = std::make_shared<FileComparison>(oldFile, newFile);
    comparisons.emplace_back(c);
  }

  std::sort(
      comparisons.begin(), comparisons.end(),
      [](std::shared_ptr<FileComparison> a, std::shared_ptr<FileComparison> b) {
        if (!a)
          return true;
        if (!b)
          return false;
        return a->coverageDifference() < b->coverageDifference();
      });
  return comparisons;
}

void ProfdataCompare::compare() {
  switch (options.output) {
  case Options::HTML:
    HTMLWriter(options.outputFilename).write(*this);
    break;
  case Options::Markdown:
    MarkdownWriter().write(*this);
    break;
  }
}

int compareMain(int argc, const char *argv[]) {
  cl::opt<std::string> output("o", cl::desc("<output filename>"),
                              cl::value_desc("The output file to write. "
                                             "If targeting HTML, this will "
                                             "be the name of the output "
                                             "directory."));
  cl::opt<std::string> oldFile(cl::Positional, cl::desc("<old yaml file>"),
                               cl::Required);
  cl::opt<std::string> newFile(cl::Positional, cl::desc("<new yaml file>"),
                               cl::Required);
  cl::opt<Options::Format> format(
      "f", cl::desc("Format to output comparison"),
      cl::values(
          clEnumValN(Options::HTML, "html", "HTML output"),
          clEnumValN(Options::Markdown, "markdown", "Markdown table output"),
          clEnumValEnd),
      cl::init(Options::Markdown));
  cl::ParseCommandLineOptions(argc, argv);

  Options options(format.getValue(), output);

  ProfdataCompare comparer(oldFile, newFile, options);

  comparer.compare();
  return 0;
}

int yamlMain(int argc, const char *argv[]) {
  cl::opt<std::string> output("o", cl::desc("<output filename>"),
                              cl::value_desc("The output file to write. "
                                             "If targeting HTML, this will "
                                             "be the name of the output "
                                             "directory."),
                              cl::init(""));
  cl::opt<std::string> file(cl::Positional, cl::desc("<profdata file>"),
                            cl::Required);
  cl::opt<std::string> binary(cl::Positional, cl::desc("<binary file>"),
                              cl::Required);
  cl::opt<std::string> coveredDir("covered-dir", cl::Optional,
                                  cl::desc("Restrict output to a certain "
                                           "covered subdirectory"));
  cl::ParseCommandLineOptions(argc, argv);

  CoverageFilePair filePair(file, binary);
  auto map = filePair.fileMap(coveredDir);
  std::vector<File> files;
  for (auto &pair : map) {
    files.emplace_back(*pair.second);
  }

  std::unique_ptr<raw_ostream> os = streamForFile(output);

  yaml::Output yout(*os);
  yout << files;

  return 0;
}
}
