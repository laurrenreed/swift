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
#include "llvm/Support/Path.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/FormattedStream.h"
#include "swift/Basic/Demangle.h"
#include <cxxabi.h>
#include <unistd.h>

using namespace std;
using namespace llvm;

namespace covcompare {
  void withColor(raw_ostream::Colors, bool bold, bool bg, function<void ()> f) {
    bool colored = sys::Process::StandardErrHasColors();
    if (colored)
      ferrs().changeColor(raw_ostream::MAGENTA, bold, bg);
    f();
    if (colored)
      ferrs().resetColor();
  }
  void warn(std::string Text) {
    withColor(raw_ostream::MAGENTA, /*bold=*/true, /*bg=*/false, [] {
      ferrs() << "warning: ";
    });
    ferrs() << Text << "\n";
  }
  
  string extractSymbol(string name) {
    auto pair = StringRef(name).split(':');
    if (pair.second == "") {
      return pair.first;
    } else {
      return pair.second;
    }
  }
  
  string demangled(string symbol) {
    auto prefix = symbol.substr(0, 2);
    if (prefix == "_Z") {
      int status;
      auto demangled = abi::__cxa_demangle(symbol.c_str(), 0, 0, &status);
      if (demangled) {
        string s(demangled);
        free(demangled);
        return s;
      }
    } else if (prefix == "_T") {
      return swift::Demangle::demangleSymbolAsString(symbol);
    }
    warn("Could not demangle " + symbol);
    return symbol;
  }
  
  void exitWithErrorCode(error_code error) {
    withColor(raw_ostream::RED, /* bold = */true, /* bg = */false, []{
      ferrs() << "error: ";
    });
    ferrs() << error.message() << "\n";
    exit(error.value());
  }
  
  string formattedDouble(double n) {
    char buf[12];
    snprintf(buf, 12, "%.02f%%", n);
    return buf;
  }
  
  unique_ptr<raw_ostream> streamForFile(string file) {
    if (file.size()) {
      error_code error;
      auto os = make_unique<raw_fd_ostream>(file,
                                            error, sys::fs::F_RW);
      if (error) exitWithErrorCode(error);
      return move(os);
    } else {
      return make_unique<raw_fd_ostream>(STDOUT_FILENO,
                                         /* shouldClose = */false);
    }
  }
}