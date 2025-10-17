class FilterAndSummaryForProject {
  late List<String> levels;
  late var nestedLevels;
  late String summaryFormattedtext;

  FilterAndSummaryForProject({required var data}) {
    levels = data[0][1].cast<String>();
    nestedLevels = data[0][2];
    summaryFormattedtext = data[1][1].toString();
  }

  printData() {
    print("Levels: $levels");
    print("Nested Levels: $nestedLevels");
    print("Summary Formatted Text: $summaryFormattedtext");
  }
}
