import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NudronChartMap {
  late final List<dynamic> headers;
  final Map<int, Map<int, Map<int, List<dynamic>>>> _dataMap = {};
  static ValueNotifier<int> selectedMonth = ValueNotifier(-1);

  NudronChartMap(var chartData) {
    headers = chartData[0];
    _initializeDataMap(chartData[1]);
    selectedMonth.value = -1;
  }

  printClass() {
  }

  static getMonthNumberFromName(String month) {
    return DateFormat.MMM().parse(month).month;
  }

  List<int> getYearKeys() {
    return _dataMap.keys.toList();
  }

  static String getPreviousDate(int day, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Invalid month. Month should be between 1 and 12.');
    }
    if (day < 1 || day > 31) {
      throw ArgumentError('Invalid day. Day should be between 1 and 31.');
    }

    List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    bool isLeapYear(int year) {
      return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    int currentYear = DateTime.now().year;
    if (isLeapYear(currentYear)) {
      daysInMonth[1] = 29;
    }

    if (day > 1) {
      return '${day - 1}';
    } else {
      int previousMonth = month == 1 ? 12 : month - 1;
      int previousDay = daysInMonth[previousMonth - 1];
      return previousDay.toString();
    }
  }

  static String convertDaysToDate(String daysSince2020,
      {String format = 'dd-MMM-yy'}) {
    try {
      int days = int.parse(daysSince2020);
      
      DateTime date = DateTime.utc(2020, 1, 1).add(Duration(days: days));
      
      return DateFormat(format).format(date);
    } catch (e) {
      return "";
    }
  }

  static String getPreviousMonthName(int month) {
    List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (month < 1 || month > 12) {
      throw ArgumentError('Invalid month. Month should be between 1 and 12.');
    }
    int previousMonth = (month == 1) ? 12 : month - 1;

    return monthNames[previousMonth - 1];
  }

  static String getYearOfPreviousMonth(int month, int year) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Invalid month. Month should be between 1 and 12.');
    }

    if (month == 1) {
      return (year - 1).toString();
    }
    return year.toString();
  }

  static String getMonthName(int month) {
    DateTime date = DateTime(2020, month, 1);
    return DateFormat.MMM().format(date);
  }

  String getMMMYY(int month, int year) {
    DateTime date = DateTime(year, month, 1);
    return "${DateFormat.MMM().format(date)} $year";
  }

  String getddmmmyy(int day, int month, int year) {
    DateTime date = DateTime(year, month, day);
    return DateFormat('dd-MMM-yy').format(date);
  }

  dynamic getWholeData() {
    List toReturn = [
      [...headers]
    ];
    List<dynamic> values = [];

    List<int> years = getYearKeys();
    
    years.sort((a, b) => b.compareTo(a));
    for (var year in years) {
      for (var month in _dataMap[year]!.keys) {
        for (var day in _dataMap[year]![month]!.keys) {
          if (day != 0) {
            values.add([
              getddmmmyy(day, month, year),
              ..._dataMap[year]![month]![day]!
            ]);
          }
        }
      }
    }
    toReturn.add(values);
    return toReturn;
  }

  dynamic getCurrentTableData() {
    if (selectedMonth.value == -1) {
      List toReturn = [
        [...headers]
      ];
      List<int> years = getYearKeys();
      
      List<dynamic> values = [];
      years.sort((a, b) => b.compareTo(a));
      for (var year in years) {
        List<int> months = _dataMap[year]!.keys.toList();
        
        months.sort();
        for (var month in months) {
          values.add([getMMMYY(month, year), ..._dataMap[year]![month]![0]!]);
        }
      }
      toReturn.add(values);

      return toReturn;
    } else {
      List toReturn = [
        [...headers]
      ];
      List<dynamic> values = [];

      List<int> years = getYearKeys();
      
      years.sort((a, b) => b.compareTo(a));
      for (var year in years) {
        if (!_dataMap[year]!.containsKey(selectedMonth.value)) {
          continue;
        }
        for (var day in _dataMap[year]![selectedMonth.value]!.keys) {
          if (day != 0) {
            values.add([
              getddmmmyy(day, selectedMonth.value, year),
              ..._dataMap[year]![selectedMonth.value]![day]!
            ]);
          }
        }
      }
      toReturn.add(values);

      return toReturn;
    }
  }

  void _initializeDataMap(List<dynamic> chartData) {
    
    final Map<int, Map<int, Map<int, List<dynamic>>>> tempDataMap = {};
    
    const int batchSize = 1000;
    for (int i = 0; i < chartData.length; i += batchSize) {
      final endIndex = (i + batchSize < chartData.length) ? i + batchSize : chartData.length;
      final batch = chartData.sublist(i, endIndex);
      
      for (var entry in batch) {
        final date = getDateFromDayNumber(entry[0]);
        final year = date.year;
        final month = date.month;
        final day = date.day;

        tempDataMap.putIfAbsent(year, () => {});
        tempDataMap[year]!.putIfAbsent(month, () => {});
        
        tempDataMap[year]![month]![day] = entry.sublist(1);
      }
    }
    
    _dataMap.addAll(tempDataMap);

    for (var year in _dataMap.keys) {
      for (var month in _dataMap[year]!.keys) {
        final monthData = _dataMap[year]![month]!;
        if (monthData.isEmpty) continue;
        
        final firstEntry = monthData.values.first;
        final length = firstEntry.length;
        final aggregatedData = List<dynamic>.filled(length, 0);

        for (var dayData in monthData.values) {
          for (int i = 0; i < length; i++) {
            aggregatedData[i] += dayData[i];
          }
        }
        monthData[0] = aggregatedData;
      }
    }
  }

  List<dynamic>? getDayData(int year, int month, int day) {
    return _dataMap[year]?[month]?[day];
  }

  int? getDayDataLength(int year, int month) {
    var data = _dataMap[year]?[month];
    if (data == null) {
      return null;
    }
    return data.length;
  }

  NudronChartData2? getDayDataChart(int year, int month, int day) {
    var data = _dataMap[year]?[month]?[day];
    if (data == null) {
      return null;
    }
    return NudronChartData2(usage: data[0], alerts: data[1]);
  }

  NudronChartData2? getMonthDataChart(int year, int month) {
    var data = _dataMap[year]?[month]?[0];
    if (data == null) {
      return null;
    }
    return NudronChartData2(usage: data[0], alerts: data[1]);
  }

  int? getMonthDataLength(int year) {
    var data = _dataMap[year];
    if (data == null) {
      return null;
    }
    return data.length;
  }

  List<dynamic>? getMonthData(int year, int month) {
    return _dataMap[year]?[month]?[0];
  }

  getDateFromDayNumber(int dayNumber) {
    
    var date = DateTime.utc(2020, 1, 1).add(Duration(days: dayNumber));
    
    return date;
  }
}

class NudronChartData2 {
  final int usage;
  final int alerts;

  const NudronChartData2({required this.usage, required this.alerts});
}

class Entries {
  Entries({
    required this.alerts,
    required this.usages,
    required this.x,
    required this.x2,
  });

  final int alerts;
  final int usages;
  final String
      x; 
  final String x2; 

  void printClass() {
  }
}