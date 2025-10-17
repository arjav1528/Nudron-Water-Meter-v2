import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watermeter2/bloc/dashboard_state.dart';
import 'package:watermeter2/main.dart';

import '../services/auth_service.dart';
import '../api/data_service.dart';
import '../models/chartModels.dart';
import '../models/filterAndSummaryForProject.dart';
import '../models/userInfo.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../utils/alert_message.dart';
import '../utils/custom_exception.dart';
import '../utils/excel_helpers.dart';
import 'dashboard_event.dart';


class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  static ChangeNotifier toUpdateProfile = ChangeNotifier();

  UserInfo userInfo = const UserInfo(
    id: "1234",
    name: "Fake name",
    email: "fakeemail@gmail.com",
    emailVerified: false,
    phone: "+919999999999",
    phoneVerified: false,
  );

  List<String> projects = [];
  List<Session> sessions = [];

  FilterAndSummaryForProject? filterData;
  var summaryData;
  var devicesData;
  var allDevices;
  NudronChartMap? nudronChartData;
  int screenIndex = 0;
  GlobalKey repaintBoundaryKey = GlobalKey(); // Define a global key
  changeKey(GlobalKey key) {
    repaintBoundaryKey = key;
  }
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // Future<void> captureSS(BuildContext context) async {
  //   try {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return Center(
  //           child: Container(
  //             padding: EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color:
  //                   Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 CircularProgressIndicator(
  //                   valueColor: AlwaysStoppedAnimation<Color>(
  //                     Provider.of<ThemeNotifier>(context)
  //                         .currentTheme
  //                         .loginTitleColor,
  //                   ),
  //                 ),
  //                 SizedBox(height: 16),
  //                 Text(
  //                   "Preparing chart...",
  //                   style: TextStyle(
  //                     color: Provider.of<ThemeNotifier>(context)
  //                         .currentTheme
  //                         .basicAdvanceTextColor,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //
  //     final screenshotController = ScreenshotController();
  //
  //     // Get necessary providers and data
  //     final mediaQuery = MediaQuery.of(context);
  //     final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
  //     final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  //
  //     // Create widget with proper dimensions and rotation
  //     final screenWidth = mediaQuery.size.height;
  //     final screenHeight = mediaQuery.size.width;
  //
  //     final widgetToCapture = ScreenUtilInit(
  //       designSize: Size(screenWidth, screenHeight),
  //       minTextAdapt: true,
  //       splitScreenMode: true,
  //       builder: (_, child) => MultiBlocProvider(
  //         providers: [
  //           BlocProvider.value(value: dashboardBloc),
  //         ],
  //         child: MultiProvider(
  //           providers: [
  //             ChangeNotifierProvider.value(value: themeNotifier),
  //           ],
  //           child: MaterialApp(
  //             debugShowCheckedModeBanner: false,
  //             builder: (context, child) => MediaQuery(
  //               data: mediaQuery.copyWith(
  //                 size: Size(screenWidth, screenHeight),
  //                 devicePixelRatio: mediaQuery.devicePixelRatio,
  //               ),
  //               child: Scaffold(
  //                 backgroundColor: themeNotifier.currentTheme.bgColor,
  //                 body: BackgroundChart(),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Capture with a delay to ensure proper rendering
  //     final capturedImage = await screenshotController.captureFromWidget(
  //       widgetToCapture,
  //       delay: const Duration(milliseconds: 300),
  //       targetSize: Size(screenWidth, screenHeight),
  //       context: context,
  //       pixelRatio: mediaQuery.devicePixelRatio,
  //     );
  //
  //     // Remove loading dialog
  //     if (context.mounted) {
  //       Navigator.of(context).pop();
  //     }
  //
  //     // Request storage permission
  //     final permissionStatus = await Permission.storage.request();
  //     if (!permissionStatus.isGranted) {
  //       if (context.mounted) {
  //         CustomAlert.showCustomScaffoldMessenger(
  //           context,
  //           "Storage permission required to save screenshot",
  //           AlertType.error,
  //         );
  //       }
  //       return;
  //     }
  //
  //     // Get appropriate directory
  //     Directory? directory;
  //     if (Platform.isAndroid) {
  //       directory = await getExternalStorageDirectory();
  //     } else if (Platform.isIOS) {
  //       directory = await getApplicationDocumentsDirectory();
  //     } else {
  //       throw UnsupportedError("Unsupported platform");
  //     }
  //
  //     if (directory == null) {
  //       throw Exception("Error: External storage directory not available");
  //     }
  //
  //     // Generate unique filename with timestamp and date
  //     final now = DateTime.now();
  //     final formattedDate =
  //         "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  //     final timestamp = now.millisecondsSinceEpoch;
  //     final filePath =
  //         "${directory.path}/chart_${formattedDate}_$timestamp.png";
  //
  //     // Save the file
  //     final file = File(filePath);
  //     await file.create(recursive: true);
  //     await file.writeAsBytes(capturedImage);
  //
  //     if (context.mounted) {
  //       // Show success message
  //       CustomAlert.showCustomScaffoldMessenger(
  //         context,
  //         "Chart saved successfully",
  //         AlertType.success,
  //       );
  //
  //       // Open the saved file
  //       await OpenFile.open(filePath, linuxByProcess: true);
  //     }
  //   } catch (e) {
  //     // Remove loading dialog if still showing
  //     if (context.mounted && Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }
  //
  //     if (context.mounted) {
  //       CustomAlert.showCustomScaffoldMessenger(
  //         context,
  //         "Error saving chart: ${e.toString()}",
  //         AlertType.error,
  //       );
  //     }
  //   }
  // }

  // Future<void> captureSS() async {
  //   try {
  //     ScreenshotController screenshotController = ScreenshotController();
  //
  //     screenshotController
  //         .captureFromWidget(BackgroundChart())
  //         .then((capturedImage) async {
  //       await Permission.storage.request();
  //
  //       Directory? directory;
  //       if (Platform.isAndroid) {
  //         directory = await getExternalStorageDirectory();
  //       } else if (Platform.isIOS) {
  //         directory = await getApplicationDocumentsDirectory();
  //       } else {
  //         String errorMsg = "Unsupported platform";
  //         CustomAlert.showCustomScaffoldMessenger(
  //             mainNavigatorKey.currentContext!, errorMsg, AlertType.error);
  //         throw UnsupportedError(errorMsg);
  //       }
  //
  //       if (directory == null) {
  //         throw Exception("Error: External storage directory not available");
  //       }
  //
  //       String filePath = "${directory.path}/chart.png";
  //       File file = File(filePath);
  //       await file.create(recursive: true);
  //       await file.writeAsBytes(capturedImage);
  //
  //       // Open the saved file
  //       OpenFile.open(filePath, linuxByProcess: true);
  //     });
  //   } catch (e) {
  //     CustomAlert.showCustomScaffoldMessenger(
  //       mainNavigatorKey.currentContext!,
  //       "Error in capturing screenshot: ${e.toString()}",
  //       AlertType.error,
  //     );
  //   }
  // }

  Future<void> captureSS() async {
    if (Platform.isAndroid) {
      try {
        if (screenIndex == 0) {
          screenIndex = 1;
          emit(ChangeScreen());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
              .findRenderObject() as RenderRepaintBoundary;

          ui.Image image = await boundary.toImage(pixelRatio: 3);
          screenIndex = 0;
          emit(ChangeScreen());
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData == null) {
            throw Exception("Error in capturing screenshot: ByteData is null");
          }

          Uint8List pngBytes = byteData.buffer.asUint8List();

          // Request storage permission
          await Permission.storage.request();

          Directory? directory = await getExternalStorageDirectory();
          if (directory == null) {
            throw Exception("Error: External storage directory not available");
          }

          String filePath = "${directory.path}/chart.png";
          File file = File(filePath);
          await file.create(recursive: true);
          await file.writeAsBytes(pngBytes);

          // Open the saved file
          OpenFile.open(filePath, linuxByProcess: true);
        });
      } catch (e) {
        CustomAlert.showCustomScaffoldMessenger(
          mainNavigatorKey.currentContext!,
          "Error in capturing screenshot: ${e.toString()}",
          AlertType.error,
        );
      }
    } else if (Platform.isIOS) {
      try {
        if (screenIndex == 0) {
          screenIndex = 1;
          emit(ChangeScreen());
        }

        // Allow some time for the UI to render fully
        // await Future.delayed(Duration(milliseconds: 50));

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // await Future.delayed(Duration(milliseconds: 20000));
          RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
              .findRenderObject() as RenderRepaintBoundary;

          // Try to capture the screenshot

          ui.Image image = await boundary.toImage(pixelRatio: 3);
          screenIndex = 0;
          emit(ChangeScreen());
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData == null) {
            throw Exception("Error in capturing screenshot: ByteData is null");
          }

          Uint8List pngBytes = byteData.buffer.asUint8List();

          // Request storage permission
          await Permission.storage.request();

          Directory directory = await getApplicationDocumentsDirectory();

          String filePath = "${directory.path}/chart.png";
          File file = File(filePath);
          await file.create(recursive: true);
          await file.writeAsBytes(pngBytes);

          // Open the saved file
          OpenFile.open(filePath, linuxByProcess: true);
        });
      } catch (e) {
        final errorMsg = "Error in capturing screenshot: ${e.toString()}";
        debugPrint(errorMsg);
        CustomAlert.showCustomScaffoldMessenger(
            mainNavigatorKey.currentContext!, errorMsg, AlertType.error);
      }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  changeScreen() {
    screenIndex = 1 - screenIndex;
    emit(ChangeScreen());
  }

  int selectedMonth = getCurrentMonth() - 1;

  List<String> currentFilters = [];

  refreshSummaryPage() {
    debugPrint("OOPS I WAS HIT 1");
    if (state is RefreshSummaryPage) {
      emit(RefreshSummaryPage2());
    } else {
      emit(RefreshSummaryPage());
    }
  }

  refreshDevicesPage() {
    debugPrint("OOPS I WAS HIT 2");
    if (state is RefreshDevicesPage) {
      emit(RefreshDevicesPage2());
    } else {
      emit(RefreshDevicesPage());
    }
  }

  selectMonth(int month) async {
    String? project = currentFilters.firstOrNull;
    if (project == null) {
      throw CustomException(
          "Please select a project in the TRENDS page first.");
    }

    selectedMonth = month;

    int baseYear = 2020 + (month) ~/ 12;
    int baseMonth = (month) % 12 + 1; // month is 0-based relative, convert to 1-12
    final firstDay = DateTime(baseYear, baseMonth, 1);
    final lastDay = DateTime(baseYear, baseMonth + 1, 0);
    selectedStartDate = firstDay;
    selectedEndDate = lastDay;

    // Use cached data loading
    await _loadSummaryDataWithCache();
    refreshSummaryPage();
  }

  selectDateRange(DateTime startDate, DateTime endDate) async {
    String? project = currentFilters.firstOrNull;
    if (project == null) {
      throw CustomException(
          "Please select a project in the TRENDS page first.");
    }

    int startDayNum = DataPostRequests.getDayNumberFromDate(startDate);
    int endDayNum = DataPostRequests.getDayNumberFromDate(endDate);
    
    selectedStartDate = startDate;
    selectedEndDate = endDate;

    // Use cache for date range data
    final cacheKey = 'summary_${project}_${startDayNum}_$endDayNum';
    
    if (_isCacheValid(cacheKey)) {
      summaryData = _apiCache[cacheKey];
    } else {
      summaryData = await DataPostRequests.getBillingDataByDateRange(
          project: project, startDayNum: startDayNum, endDayNum: endDayNum);
      
      _apiCache[cacheKey] = summaryData;
      _cacheTimestamps[cacheKey] = DateTime.now();
    }
    
    refreshSummaryPage();
  }

  getDevicesData() async {
    String? project = currentFilters.firstOrNull;
    if (project == null) {
      throw CustomException(
          "Please select a project in the TRENDS page first.");
    }

    // Use cached data loading
    await _loadDevicesDataWithCache();
    refreshDevicesPage();
  }

  filterDevices(String query) {
    debugPrint("Query is : $query");

    List header = allDevices[0]; // Save the header
    List dataToFilter = allDevices[1]; // Get the data array to filter

    List filteredData = dataToFilter.where((device) {
      if (device is! List || device.length < 2) {
        debugPrint("Invalid");
        return false;
      }

      String id = device[0].toString().toLowerCase(); // ID is at index 0
      String label = device[1].toString().toLowerCase(); // Label is at index 1
      return id.contains(query.toLowerCase()) ||
          label.contains(query.toLowerCase());
    }).toList();

    devicesData = [header, filteredData];

    debugPrint(devicesData);
    refreshDevicesPage();
  }

  setBillingFormula(String formula) async {
    String? project = currentFilters.firstOrNull;
    if (project == null) {
      throw CustomException(
          "Please select a project in the TRENDS page first.");
    }

    await DataPostRequests.setBillingFormula(
        project: project, formulaString: formula);
    if (filterData != null) {
      filterData!.summaryFormattedtext = formula;
    }
    refreshSummaryPage();
  }

  static getCurrentMonth() {
    DateTime currentDate = DateTime.now();
    return (currentDate.year - 2020) * 12 + currentDate.month - 1;
  }

  List<String> getMonthNumbers() {
    int currentMonthNumber =
        getCurrentMonth(); // (currentDate.year - startDate.year) * 12 + currentDate.month;

    // Generate the last 12 months
    List<int> months = [];
    for (int i = 1; i < 13; i++) {
      months.add(currentMonthNumber - i);
    }
    return months.map((e) => e.toString()).toList();
  }

  String convertMonthNumberToText(String monthNumber) {
    // Try to parse the string to an integer
    int? monthNum = int.tryParse(monthNumber);

    // If parsing fails, return the original text
    if (monthNum == null) {
      return monthNumber;
    }

    // Calculate the year and month based on the parsed month number
    int year = 2020 + (monthNum) ~/ 12;
    int month = (monthNum) % 12;

    // Define month names
    List<String> monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    // Convert to "Month-Year" format
    return "${monthNames[month]} $year";
  }

  getFiltersAndSummaryForProject(String project) async {
    return FilterAndSummaryForProject(
        data: await DataPostRequests.getFilters(project: project));
  }

  exportDataToExcel(
    var data,
    bool exportToIncludeWholeData,
    String exportType,
    BuildContext context,
  ) async {
    CustomAlert.showCustomScaffoldMessenger(
      mainNavigatorKey.currentContext!,
      "Preparing data for export...",
      AlertType.info,
    );

    // Validate data format
    bool isValidSheetData(dynamic sheetData) {
      return sheetData is List &&
             sheetData.length >= 2 &&
             sheetData[0] is List &&
             sheetData[1] is List;
    }

    String? path;
    if (exportToIncludeWholeData) {
      var trendsData = nudronChartData?.getWholeData();
      if (!isValidSheetData(data) || (trendsData != null && !isValidSheetData(trendsData))) {
        CustomAlert.showCustomScaffoldMessenger(
          mainNavigatorKey.currentContext!,
          "Export failed: Data format is invalid.",
          AlertType.error,
        );
        return;
      }
      path = await ExcelHelper.exportToExcel(
        [
          ["Selected Data", data],
          ["Trends Data", trendsData],
        ],
        exportType,
        context,
      );
    } else {
      if (!isValidSheetData(data)) {
        CustomAlert.showCustomScaffoldMessenger(
          mainNavigatorKey.currentContext!,
          "Export failed: Data format is invalid.",
          AlertType.error,
        );
        return;
      }
      path = await ExcelHelper.exportToExcel(
        [
          ["Selected Data", data]
        ],
        exportType,
        context,
      );
    }

    if (path != null) {
      // Show the directory in the ScaffoldMessenger
      final directory = File(path).parent.path;
      CustomAlert.showCustomScaffoldMessenger(
        mainNavigatorKey.currentContext!,
        "Data exported successfully to:\n$directory",
        AlertType.success,
      );
      debugPrint("Data exported successfully to $path");
    } else {
      CustomAlert.showCustomScaffoldMessenger(
        mainNavigatorKey.currentContext!,
        "Export failed. Please try again.",
        AlertType.error,
      );
    }
  }

  // Cache for API responses to prevent duplicate calls
  final Map<String, dynamic> _apiCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  Future<FilterAndSummaryForProject?> updateSelectedFilters(
      List<String?> filters, FilterAndSummaryForProject? filterData) async {
    currentFilters = filters.where((filter) => filter != null).cast<String>().toList();
    this.filterData = filterData;
    bool toRefreshSummaryPage = true;

    try {
      // Remove dynamic tab update, always use static tabs
      await updateBottomNavTabs(project: currentFilters.first);
      emit(ChangeDashBoardNav());
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Error in loading trends data : ${e.toString()}", AlertType.error);
      return null;
    }

    // Load data in parallel to improve performance
    final List<Future<void>> dataLoadingTasks = [];
    
    // Only load trends data once
    if (currentFilters.isNotEmpty) {
      dataLoadingTasks.add(_loadTrendsDataWithCache(currentFilters.firstOrNull));
    }
    
    if (toRefreshSummaryPage) {
      dataLoadingTasks.add(_loadSummaryDataWithCache());
      dataLoadingTasks.add(_loadDevicesDataWithCache());
    }

    // Execute all data loading tasks in parallel
    try {
      await Future.wait(dataLoadingTasks);
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Error in loading data : ${e.toString()}", AlertType.error);
      return null;
    }

    // Emit refresh states only once at the end
    refreshSummaryPage();
    refreshDashboard();
    
    return filterData;
  }

  // Helper method to load trends data with caching
  Future<void> _loadTrendsDataWithCache(String? project) async {
    if (project == null) return;
    
    final cacheKey = 'trends_${project}_${currentFilters.length > 1 ? currentFilters.sublist(1).join('>') : ""}';
    
    if (_isCacheValid(cacheKey)) {
      updateTrendsData(_apiCache[cacheKey]);
      return;
    }

    try {
      final data = await DataPostRequests.getChartData(
          project: project,
          selectedLevels: currentFilters.length > 1 ? currentFilters.sublist(1) : [""]);
      
      _apiCache[cacheKey] = data;
      _cacheTimestamps[cacheKey] = DateTime.now();
      updateTrendsData(data);
    } catch (e) {
      throw Exception("Error loading trends data: ${e.toString()}");
    }
  }

  // Helper method to load summary data with caching
  Future<void> _loadSummaryDataWithCache() async {
    if (currentFilters.isEmpty) return;
    
    final cacheKey = 'summary_${currentFilters.first}_$selectedMonth';
    
    if (_isCacheValid(cacheKey)) {
      summaryData = _apiCache[cacheKey];
      return;
    }

    try {
      summaryData = await DataPostRequests.getBillingData(
          project: currentFilters.first, monthNumber: selectedMonth);
      
      _apiCache[cacheKey] = summaryData;
      _cacheTimestamps[cacheKey] = DateTime.now();
    } catch (e) {
      throw Exception("Error loading summary data: ${e.toString()}");
    }
  }

  // Helper method to load devices data with caching
  Future<void> _loadDevicesDataWithCache() async {
    if (currentFilters.isEmpty) return;
    
    final cacheKey = 'devices_${currentFilters.first}';
    
    if (_isCacheValid(cacheKey)) {
      devicesData = _apiCache[cacheKey];
      allDevices = _apiCache['${cacheKey}_all'];
      return;
    }

    try {
      var response = await DataPostRequests.getFilters(project: currentFilters.first);

      if (response.length > 2 &&
          response[2] is List &&
          response[2].length > 1 &&
          response[2][0] == "Activity") {
        var activityData = response[2][1];

        if (activityData is List) {
          devicesData = activityData;
          allDevices = activityData;
          
          _apiCache[cacheKey] = devicesData;
          _apiCache['${cacheKey}_all'] = allDevices;
          _cacheTimestamps[cacheKey] = DateTime.now();
        } else {
          throw CustomException("Unexpected data format in Activity section.");
        }
      } else {
        throw CustomException("Unexpected response format or missing Activity data.");
      }
    } catch (e) {
      throw Exception("Error loading devices data: ${e.toString()}");
    }
  }

  // Check if cache is valid
  bool _isCacheValid(String cacheKey) {
    if (!_apiCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final cacheTime = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(cacheTime) < _cacheExpiry;
  }

  // Clear cache when needed
  void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
  }

  // Clear cache for specific project
  void clearProjectCache(String project) {
    final keysToRemove = _apiCache.keys.where((key) => key.contains(project)).toList();
    for (final key in keysToRemove) {
      _apiCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  static Future<List<String>?> updateBottomNavTabs(
      {required String? project}) async {
    if (project == null || project.isEmpty) return ["project"];
    
    // Always use these fixed tabs when a project is selected
    List<String> standardTabs = ['project', 'trends', 'billing', 'activity'];
    MainDashboardPage.bottomNavTabs = standardTabs;
    return standardTabs;
    
    // Original dynamic code commented out
    // try {
    //   // Fetch the response from API
    //   dynamic response = await DataPostRequests.getFilters(project: project);
    //   List<String> bottomNavTabs = [];
    //   // Ensure the response is a list
    //   if (response is List) {
    //     // Extract the first element (title) from each top-level list
    //     bottomNavTabs = response
    //         .map((item) {
    //           if (item is List && item.isNotEmpty && item[0] is String) {
    //             return item[0].toLowerCase(); // Convert to lowercase
    //           }
    //           return null;
    //         })
    //         .whereType<String>()
    //         .toList(); // Remove null values
    //   }
    //   debugPrint("Updated bottomNavTabs: $bottomNavTabs");
    //   MainDashboardPage.bottomNavTabs = bottomNavTabs;
    //   return bottomNavTabs; // Debug debugPrint
    // } catch (e) {
    //   debugPrint("Error fetching bottomNavTabs: $e");
    //   return ["project"];
    // }
  }

  getDateFromDayNumber(int dayNumber) {
    // var date = DateTime.now().subtract(Duration(days: dayNumber));
    // return "${date.year}-${date.month}-${date.day}";
    //day number is day from 1/1/2020
    var date = DateTime.utc(2020, 1, 1).add(Duration(days: dayNumber));
    //DATE FORMAT: 01-01-2020
    return DateFormat('dd-MMM-yy').format(date);
  }

  updateTrendsData(var newData) {
    // nudronChartData = NudronChartMap((newData[1] == null ||
    //         (newData[1].runtimeType is String && newData[1] == "null") ||
    //         (newData[1].runtimeType is List && newData[1].isEmpty))
    //     ? []
    //     : trendsData[1]
    //         .map<List<dynamic>>((item) => [item[0], item[1].toInt(), item[2]])
    //         .toList());

    nudronChartData = NudronChartMap(newData);
  }

  loadTrendsData(String? project) async {
    if (project == null) {
      return;
    }

    updateTrendsData(await DataPostRequests.getChartData(
        project: project,
        selectedLevels:
            currentFilters.length > 1 ? currentFilters.sublist(1) : [""]));
  }

  selectProject(int selectedIndex) async {
    if (selectedIndex < projects.length && selectedIndex >= 0) {
      final selectedProject = projects[selectedIndex];
      
      if (selectedProject == currentFilters.firstOrNull) {
        return filterData;
      }
      
      // Clear cache for the previous project if switching projects
      if (currentFilters.isNotEmpty && currentFilters.first != selectedProject) {
        clearProjectCache(currentFilters.first);
      }
      
      // Reset bottom nav position to Project tab if clearing the project
      if (selectedIndex == -1) {
        switchBottomNavPos(0); // Project tab
      }
      
      return await getFiltersAndSummaryForProject(selectedProject);
    }
    
    // If no project selected, ensure we're on the Project tab
    switchBottomNavPos(0);
    return null;
  }

  checkAndAddProject(String projectName) {
    if (projectName.endsWith("Water Metering")) {
      projects.add(projectName.substring(0, projectName.length - 15));
    }
  }

  initUserInfo() async {
    try {
      Map<String, dynamic>? json = await AuthService.getUserInfo();
      if (json == null) {
        throw Exception("Failed to get user info");
      }
      
      // Clear cache when user info is refreshed
      clearCache();
      
      this.projects.clear();
      this.sessions.clear();
      var projects = json["projects"];
      for (var project in projects) {
        if (project["project"] != null) {
          checkAndAddProject(project["project"]);
        }
      }

      var sessions = json["profile"]?["sessions"];
      if (sessions != null) {
        for (var session in sessions) {
          this.sessions.add(Session.fromJson(session));
        }
      }

      userInfo = UserInfo.fromJson(json["profile"]);
      // Two-factor authentication is now handled by AuthService
    } catch (e) {
      throw ("Error in getting user info $e");
    }
  }

  updateProfile() async {
    await initUserInfo();
    if (state is UserInfoUpdate) {
      emit(UserInfoUpdate2());
    } else {
      emit(UserInfoUpdate());
    }
  }

  void switchBottomNavPos(int pos) {
    bottomNavPos = pos;
    emit(ChangeDashBoardNav());
    if (pos == 1 && currentFilters.isNotEmpty) { // If switching to trends tab
      emit(RefreshDashboard());
    }
  }

  int bottomNavPos = 0;

  refreshDashboard() {
    debugPrint("OOPS I WAS HIT 3");
    if (state is RefreshDashboard) {
      emit(RefreshDashboard2());
    } else {
      emit(RefreshDashboard());
    }
  }

  loadInitialData() async {
    try {
      await initUserInfo();
      emit(DashboardPageLoaded());
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e as String?);
      }
      emit(DashboardPageError(message: e.toString()));
    }
  }

  DashboardBloc() : super(DashboardPageInitial()) {
    toUpdateProfile.addListener(updateProfile);
    loadInitialData();
  }
}