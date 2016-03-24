//
//  Column.cpp
//  cov-compare
//
//  Created by Harlan Haskins on 3/15/16.
//  Copyright © 2016 Harlan Haskins. All rights reserved.
//

#include "Writer.hpp"

namespace covcompare {
std::string Writer::formattedDouble(double n) {
  char buf[12];
  snprintf(buf, 12, "%.02f%%", n);
  return buf;
}

std::string Writer::formattedDiff(double n) {
  return (n > 0 ? "+" : "") + formattedDouble(n);
}

std::vector<Column> Writer::tableForComparisons(
    std::vector<std::shared_ptr<FileComparison>> &comparisons) {
  Column fnCol("Filename");
  Column prevCol("Previous Coverage", Column::Alignment::Center);
  Column currCol("Current Coverage", Column::Alignment::Center);
  Column regionCol("Regions", Column::Alignment::Center);
  Column regionExecCol("Regions Exec'd", Column::Alignment::Center);
  Column diffCol("Coverage Difference", Column::Alignment::Center);
  for (auto &cmp : comparisons) {
    double newPercentage = cmp->newItem->coveragePercentage();
    std::string newCovString = formattedDouble(newPercentage);
    std::string oldCovString = "N/A";
    std::string diffString = "N/A";
    if (auto old = cmp->oldItem) {
      double oldPercentage = old->coveragePercentage();
      oldCovString = formattedDouble(oldPercentage);
      diffString = formattedDiff(newPercentage - oldPercentage);
    }
    fnCol.add(formattedFilename(cmp->newItem->name));
    prevCol.add(oldCovString);
    currCol.add(newCovString);
    auto pair = cmp->newItem->regionCounts();
    regionCol.add(std::to_string(pair.first));
    regionExecCol.add(std::to_string(pair.second));
    diffCol.add(diffString);
  }
  return {fnCol, prevCol, currCol, regionCol, regionExecCol, diffCol};
}
}
