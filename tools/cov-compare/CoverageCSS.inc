//===---- CoverageCSS.inc - CSS for styling reports based on coverage -----===//
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

std::string css = R"(body {
  font-family: -apple-system, sans-serif;
}
footer {
  padding: 15px;
}
a {
  text-decoration: none;
}
table, th, td {
  padding: 10px;
  text-align: left;
  border: 1px solid #ddd;
  border-collapse: collapse;
}
.warning {
  color: #f9a03f;
  font-weight: normal;
}
.bad {
  color: #ba1b1d;
  font-weight: bold;
}
.good {
  color: #1cc000;
  font-weight: normal;
})";