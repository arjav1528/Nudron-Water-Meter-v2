class Utils {
  static List<dynamic> sortTableDataByMonthDescending(
      List<dynamic>? tableData) {
    if (tableData == null) return [];
    if (tableData.length < 2 || tableData[1].isEmpty) return tableData;

    List<dynamic> data = tableData[1];

    data.sort((a, b) {
      DateTime dateA = parseMMMYYToDate(a[0]);
      DateTime dateB = parseMMMYYToDate(b[0]);
      return dateB.compareTo(dateA); 
    });

    return [tableData[0], data];
  }

  static DateTime parseMMMYYToDate(String dateStr) {
    List<String> parts = dateStr.split(' ');
    if (parts.length != 2) return DateTime(1900); 

    String monthStr = parts[0];
    int year = int.tryParse(parts[1]) ?? 1900;

    Map<String, int> monthMap = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12
    };

    int month = monthMap[monthStr] ?? 1;
    return DateTime(year, month);
  }

  static String cleanFieldName(String fieldName) {
    return fieldName.replaceAll(RegExp(r'^[^\w.!#( ]+|[^\w.#) ]+$'), '');
  }

  static String lastSeenFromMilliseconds(dynamic milliseconds) {
    try {
      if (milliseconds == null || milliseconds.toString().isEmpty) {
        return "";
      }

      int ms = (milliseconds is int)
          ? milliseconds
          : int.tryParse(milliseconds.toString()) ?? 0;

      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(ms);
      Duration diffEpoch = DateTime.now().difference(DateTime(2020, 1, 1));
      Duration diff = DateTime.now().difference(timestamp);

      if (diff.inDays == diffEpoch.inDays) return "NA";
      if (diff.inDays >= 365) return "${diff.inDays ~/ 365} years";
      if (diff.inDays >= 30) return "${diff.inDays ~/ 30} months";
      if (diff.inDays > 0) return "${diff.inDays} days";
      if (diff.inHours > 0) return "${diff.inHours} hours";
      if (diff.inMinutes > 0) return "${diff.inMinutes} minutes";
      if (diff.inSeconds > 0) return "${diff.inSeconds} seconds";

      return "Just now";
    } catch (e) {
      return "Invalid date";
    }
  }

}