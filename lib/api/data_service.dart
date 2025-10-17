import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../utils/custom_exception.dart';
import '../utils/getDeviceID.dart';
import '../services/auth_service.dart';


class DataPostRequests {
  static const String portalUrl = 'https://api.nudron.com/prod/portal';
  static const String nf1Url = '$portalUrl/nf1';
  static const String nf3Url = '$portalUrl/nf3';
  static const String wm1Url = 'https://api.nudron.com/prod/dashboard/wm1';
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static getIconNamesForAlerts(int index) {
    switch (index) {
      case 0:
        return "Empty Pipe";
      case 1:
        return "No Consumption";
      case 2:
        return "Reverse Flow";
      case 3:
        return "Leak Flow";
      case 4:
        return "Continuos Flow";
      case 5:
        return "Burst Pipe";
      case 6:
        return "Max Flow";
      case 7:
        return "Freeze";
      default:
        return "RFU";
    }
  }

  static getIconNamesForStatus(int index) {
    switch (index) {
      case 1:
        return "Low Bat";
      case 2:
        return "Bad Temp";
      case 3:
        return "Motion";
      case 7:
        return "Air in Pipe";
      default:
        return "RFU";
    }
  }

  static int getDayNumberFromDate(DateTime date) {
    final startDate = DateTime(2020, 1, 1);
    return date.difference(startDate).inDays;
  }

  static DateTime getDateFromDayNumber(int dayNumber) {
    final startDate = DateTime(2020, 1, 1);
    return startDate.add(Duration(days: dayNumber));
  }

  static Future<void> printJson(Map<dynamic, dynamic> data, int number) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(data);

    // Check if the JSON string is too long for the console
    if (jsonString.length > 1000) {
      // Print in chunks
      const int chunkSize = 1000;
      for (int i = 0; i < jsonString.length; i += chunkSize) {
        print(jsonString.substring(
            i,
            i + chunkSize > jsonString.length
                ? jsonString.length
                : i + chunkSize));
      }
    } else {
      // Print directly if the string is short enough
      print(jsonString);
    }

    // Dummy wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
  }

  static getDummyFilters() async {
    await Future.delayed(const Duration(seconds: 2));
    return '''[ [ "Trends", [ "Building", "Flat", "Device" ], { "Building": { "402": [ "Main" ], "3rd Floor": [ "Main Line", "Main" ], "4th Floor": [ "Main Line", "Main" ], "Flat": [ "Flush Line", "Flush", "Domestic Line", "Main" ], "Basement": [ "Main" ], "Basement Floor": [ "Main Line" ], "Ground Floor": [ "Main", "Main Line" ] }, "Gitaneel Arcawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwde22": { "1st Floor": [ "Main" ], "3rd Floor": [ "Main Line", "Main" ], "4th Floor": [ "Main Line", "Main" ], "Flat": [ "Flush Line", "Flush", "Domestic Line", "Main" ], "Basement": [ "Main" ], "Basement Floor": [ "Main Line" ], "Ground Floor": [ "Main", "Main Line" ] } } ], [ "Billing", "200<10:15<20:25<30:40<50" ], ["Devices",[
            [
                "Label   ",
                "Serial #",
                "Model",
                "%Last Seen",
                "Totalizer",
                "@Last Record",
                "Usage(L)",
                "Alerts",
                "!Al0",
                "!Al1",
                "!Al2",
                "!Al3",
                "!Al4",
                "!Al5",
                "!Al6",
                "!Al7",
                "!St1",
                "!St2",
                "!St3",
                "!St7",
                "US:00-02",
                "US:02-04",
                "US:04-06",
                "US:06-08",
                "US:08-10",
                "US:10-12",
                "US:12-14",
                "US:14-16",
                "US:16-18",
                "US:18-20",
                "US:20-22",
                "US:22-24"
            ],
            [
                [
                    "Gitaneel Arcade>5&6 Floor>Main",
                    "101100000248",
                    "NuFM-B-25W",
                    1740385683000,
                    344388,
                    1880,
                    1703,
                    3,
                    0,
                    0,
                    1,
                    1,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    6,
                    6,
                    4,
                    55,
                    33,
                    317,
                    258,
                    319,
                    240,
                    281,
                    175,
                    9
                ],
                [
                    "Gitaneel Arcade>Ground Floor>Main",
                    "101100000235",
                    "NuFM-B-15W",
                    1740386249000,
                    484038,
                    1880,
                    1508,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    11,
                    0,
                    0,
                    139,
                    29,
                    198,
                    177,
                    247,
                    182,
                    218,
                    201,
                    106
                ],
                [
                    "Gitaneel Arcade>1st Floor>Main",
                    "101100000251",
                    "NuFM-B-25W",
                    1740341675000,
                    395770,
                    1880,
                    1994,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    130,
                    215,
                    151,
                    233,
                    62,
                    136,
                    327,
                    151,
                    178,
                    124,
                    94,
                    193
                ],
                [
                    "Gitaneel Arcade>4th Floor>Main",
                    "101100000247",
                    "NuFM-B-25W",
                    1577836800000,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
                ],
                [
                    "Gitaneel Arcade>Basement>Main",
                    "101100000238",
                    "NuFM-B-15W",
                    1740365360000,
                    187405,
                    1880,
                    1561,
                    1,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    16,
                    8,
                    6,
                    160,
                    646,
                    143,
                    60,
                    256,
                    145,
                    67,
                    41,
                    13
                ],
                [
                    "Gitaneel Arcade>5&6 Floor>Flush",
                    "101100000246",
                    "NuFM-B-25W",
                    1740386080000,
                    305404,
                    1880,
                    761,
                    1,
                    0,
                    0,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    92,
                    73,
                    91,
                    147,
                    28,
                    106,
                    142,
                    75,
                    7
                ],
                [
                    "Gitaneel Arcade>3rd Floor>Main",
                    "101100000249",
                    "NuFM-B-25W",
                    1740393510000,
                    49608,
                    1880,
                    255,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    36,
                    3,
                    57,
                    15,
                    39,
                    23,
                    57,
                    25,
                    0
                ]
            ]
        ]]]''';
  }

  static getDummyChartData() async {
    await Future.delayed(const Duration(seconds: 1));
    return '''[["Date","Usage"," #AL ","!Al0","!Al1","!Al2","!Al3","!Al4","!Al5","!Al6","!Al7"," #ST ","!St1","!St2","!St3","!St7","US:00-02","US:02-04","US:04-06","US:06-08","US:08-10","US:10-12","US:12-14","US:14-16","US:16-18","US:18-20","US:20-22","US:22-24"],[[1780,7076,5,0,0,2,1,2,0,0,0,0,0,0,0,0,89,101,185,556,857,1128,1175,1449,1396,1210,639,146]]]''';
  }

  static getDummyBillingData() async {
    await Future.delayed(const Duration(seconds: 1));

    // return '''[["Building","  Flat  ","Usage"," #AL ","!Al0","!Al1","!Al2","!Al3","!Al4","!Al5","!Al6","!Al7"," #ST ","!St1","!St2","!St3","!St7","US:00-02","US:02-04","US:04-06","US:06-08","US:08-10","US:10-12","US:12-14","US:14-16","US:16-18","US:18-20","US:20-22","US:22-24"],[["Gitaneel Arcade","5\u00266 Floor",112269,104,0,0,60,6,38,0,0,0,0,0,0,0,0,949,967,3512,9548,11905,12872,13460,12965,16881,18583,9453,1174],["Gitaneel Arcade","3rd Floor",9313,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,15,218,795,875,516,526,1252,1554,1799,1577,160],["Gitaneel Arcade","Ground Floor",89808,38,0,0,0,10,28,0,0,0,0,0,0,0,0,1889,1879,1987,5005,10433,10753,9753,10507,10049,8578,8831,4114],["Gitaneel Arcade","1st Floor",80208,30,0,0,0,0,30,0,0,0,0,0,0,0,0,6173,5628,7931,7962,6581,6861,7283,7371,6147,5411,5917,6943],["Gitaneel Arcade","Basement",41626,11,0,0,0,0,11,0,0,0,0,0,0,0,0,515,503,674,7165,10860,2361,4869,4834,3581,3711,1991,562]]]''';

    return '''[
  [ "Building", "Flat", "Usage", "#Al", "!Al0", "!Al1", "!Al2", "!Al3", "!Al4", "!Al5", "!Al6", "!Al7", "#Status", "!St1", "!St2", "!St3", "!St7" ],
  [
    [ "Lakeside Residency", "101",  12000, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ],
    [ "Lakeside Residency", "102",  11000, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0 ],
    [ "Lakeside Residency", "103",  15000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ "Oak Towers", "201",  18000, 3, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 ],
    [ "Oak Towers", "202",  19000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ "Pine Apartments", "301",  9500, 2, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ],
    [ "Pine Apartments", "302",  8700, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ],
    [ "Cedar Heights", "401",  23000, 5, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0 ],
    [ "Cedar Heights", "402",  22000, 3, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0 ],
    [ "Willow Estates", "501",  14000, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ],
    [ "Willow Estates", "502",  13500, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1 ],
    [ "Spruce Residences", "601",  20000, 4, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ],
    [ "Spruce Residences", "602",  21000, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0 ],
    [ "Elm Grove", "701",  16000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ "Elm Grove", "702",  15500, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ]
  ]
]''';
  }

  static Future<dynamic> getFilters({required String project}) async {
    String body = "00$project>Water Metering";
    var response;
    if (project.toLowerCase() == 'test') {
      response = await getDummyFilters();
    } else {
      response = await _makeRequest(
        body,
        url: wm1Url,
      );
    }

    return jsonDecode(response);
  }

  static Future<dynamic> getChartData(
      {required String project, required List<String> selectedLevels}) async {
    String body = "01$project>Water Metering|${selectedLevels.join('>')}";
    var response;
    if (project.toLowerCase() == 'test') {
      response = await getDummyChartData();
    } else {
      response = await _makeRequest(
        body,
        url: wm1Url,
      );
    }

    return jsonDecode(response);
  }

  static Future<dynamic> getBillingData(
      {required String project, required int monthNumber}) async {
    String body = "02$project>Water Metering|$monthNumber";
    var response;

    if (project.toLowerCase() == 'test') {
      response = await getDummyBillingData();
    } else {
      response = await _makeRequest(body, url: wm1Url);
    }
    // final response =
    //     await _makeRequest(body, url: wm1Url, contenttype: 'application/json');
    return jsonDecode(response);
  }

  static Future<dynamic> getBillingDataByDateRange(
      {required String project, required int startDayNum, required int endDayNum}) async {
    String body = "05$project>Water Metering|$startDayNum|$endDayNum";
    var response;

    if (project.toLowerCase() == 'test') {
      response = await getDummyBillingData();
    } else {
      response = await _makeRequest(body, url: wm1Url);
    }
    return jsonDecode(response);
  }

  static Future<dynamic> setBillingFormula(
      {required String project, required String formulaString}) async {
    String body = "03$project>Water Metering|$formulaString";
    final response = await _makeRequest(
      body,
      url: wm1Url,
    );
    return jsonDecode(response);
  }

  static Future<String> _makeRequest(String requestBody,
      {String url = wm1Url, Duration? timeout}) async {
    DateTime now = DateTime.now();

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw CustomException('No internet connection');
    }
    final jwt = await AuthService.getAccessToken();
    String userAgent = await DeviceInfoUtil.getUserAgent();
    final headers = {
      'User-Agent': userAgent,
      'medium': 'phone',
      'Content-Type': 'text/plain',
      'Authorization': 'Bearer $jwt',
    };
    var request = http.Request('POST', Uri.parse(url));
    request.body = requestBody;
    request.headers.addAll(headers);

    if (kDebugMode) {
      print("url ${request.url}");
      print("body ${request.body}");
      print("header ${request.headers}");
    }

    try {
      http.StreamedResponse response =
          await request.send().timeout(timeout ?? const Duration(seconds: 5));
      DateTime later = DateTime.now();

      if (kDebugMode) {
        print("Time taken: ${later.difference(now).inMilliseconds} ms");
        print(response.statusCode);
      }

      if (response.statusCode == 200) {
        var resp = await response.stream.bytesToString();
        if (kDebugMode) {
          print(resp);
        }
        return resp;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthService.logout();
        throw CustomException('Redirecting to login page..Please login again');
      } else {
        String responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print(responseBody);
        }
        throw CustomException(responseBody);
      }
    } on TimeoutException {
      throw CustomException('Request timed out');
    }
  }
}