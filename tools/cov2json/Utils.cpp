//===----------- Utils.cpp - Tools for analyzing llvm profdata ------------===//
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

#include "Utils.hpp"
#include "llvm/Support/Process.h"
#include "llvm/Support/FormattedStream.h"
#include "swift/Basic/Demangle.h"
#include "ProfileData.hpp"
#include <cxxabi.h>

using namespace llvm;

namespace cov2json {
void withColor(raw_ostream::Colors color, bool bold, bool bg,
               std::function<void()> f) {
  bool colored = sys::Process::StandardErrHasColors();
  if (colored)
    ferrs().changeColor(color, bold, bg);
  f();
  if (colored)
    ferrs().resetColor();
}

std::string extractSymbol(std::string name) {
  auto pair = StringRef(name).split(':');
  if (pair.second == "") {
    return pair.first;
  } else {
    return pair.second;
  }
}

std::string demangled(std::string symbol) {
  auto prefix = symbol.substr(0, 2);
  if (prefix == "_Z") {
    auto demangled = abi::__cxa_demangle(symbol.c_str(), 0, 0, NULL);
    if (demangled) {
      std::string s(demangled);
      free(demangled);
      return s;
    }
  } else if (prefix == "_T") {
    return swift::Demangle::demangleSymbolAsString(symbol);
  }
  return symbol;
}

void exitWithErrorCode(std::error_code error) {
  withColor(raw_ostream::RED, /* bold = */ true, /* bg = */ false,
            [] { ferrs() << "error: "; });
  ferrs() << error.message() << "\n";
  exit(error.value());
}

std::unique_ptr<raw_ostream> streamForFile(std::string file) {
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
}
