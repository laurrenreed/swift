//===--------=- main.cpp - Tools for analyzing llvm profdata --------------===//
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

#include "llvm/Support/CommandLine.h"
#include "ProfileData.hpp"
#include "JSONWriter.hpp"

using namespace llvm;
using namespace cov2json;

int main(int argc, const char **argv) {
  cl::opt<std::string> output("output", cl::desc("<output filename>"),
                              cl::value_desc("The output file to write. "),
                              cl::init(""));
  cl::opt<std::string> file(cl::Positional, cl::desc("<profdata file>"),
                            cl::Required);
  cl::opt<std::string> binary(cl::Positional, cl::desc("<binary file>"),
                              cl::Required);
  cl::opt<std::string> coveredDir("covered-dir", cl::Optional,
                                  cl::desc("Restrict output to a certain "
                                         "covered subdirectory."));
  cl::ParseCommandLineOptions(argc, argv);
  
  CoverageFilePair filePair(file, binary);
  std::vector<File> files;
  
  filePair.loadFileMap(files, coveredDir);
  
  std::unique_ptr<raw_ostream> os = streamForFile(output);
  
  swift::json::Output jout(*os, false);
  jout << files;
}
