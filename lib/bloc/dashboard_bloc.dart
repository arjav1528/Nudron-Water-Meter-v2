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
import '../utils/performance_monitor.dart';
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
  GlobalKey repaintBoundaryKey = GlobalKey(); 
  changeKey(GlobalKey key) {
    repaintBoundaryKey = key;
  }
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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

          if (Platform.isAndroid || Platform.isIOS) {
            try {
              await Permission.storage.request();
            } catch (e) {
              
            }
          }

          Directory? directory = await getExternalStorageDirectory();
          if (directory == null) {
            throw Exception("Error: External storage directory not available");
          }

          String filePath = "${directory.path}/chart.png";
          File file = File(filePath);
          await file.create(recursive: true);
          await file.writeAsBytes(pngBytes);

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

          if (Platform.isAndroid || Platform.isIOS) {
            try {
              await Permission.storage.request();
            } catch (e) {
              
            }
          }

          Directory directory = await getApplicationDocumentsDirectory();

          String filePath = "${directory.path}/chart.png";
          File file = File(filePath);
          await file.create(recursive: true);
          await file.writeAsBytes(pngBytes);

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
    int baseMonth = (month) % 12 + 1; 
    final firstDay = DateTime(baseYear, baseMonth, 1);
    final lastDay = DateTime(baseYear, baseMonth + 1, 0);
    selectedStartDate = firstDay;
    selectedEndDate = lastDay;

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

    await _loadDevicesDataWithCache();
    refreshDevicesPage();
  }

  filterDevices(String query) {
    debugPrint("Query is : $query");

    List header = allDevices[0]; 
    List dataToFilter = allDevices[1]; 

    List filteredData = dataToFilter.where((device) {
      if (device is! List || device.length < 2) {
        debugPrint("Invalid");
        return false;
      }

      String id = device[0].toString().toLowerCase(); 
      String label = device[1].toString().toLowerCase(); 
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
        getCurrentMonth(); 

    List<int> months = [];
    for (int i = 1; i < 13; i++) {
      months.add(currentMonthNumber - i);
    }
    return months.map((e) => e.toString()).toList();
  }

  String convertMonthNumberToText(String monthNumber) {
    
    int? monthNum = int.tryParse(monthNumber);

    if (monthNum == null) {
      return monthNumber;
    }

    int year = 2020 + (monthNum) ~/ 12;
    int month = (monthNum) % 12;

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

    return "${monthNames[month]} $year";
  }

  getFiltersAndSummaryForProject(String project) async {
    
    final cacheKey = 'filters_$project';
    
    dynamic filtersData;
    if (_isCacheValid(cacheKey)) {
      filtersData = _apiCache[cacheKey];
    } else {
      filtersData = await DataPostRequests.getFilters(project: project);
      _apiCache[cacheKey] = filtersData;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cacheAccessOrder.add(cacheKey);
      _evictLRUEntries();
    }
    
    return FilterAndSummaryForProject(data: filtersData);
  }

  exportDataToExcel(
    var data,
    bool exportToIncludeWholeData,
    String exportType,
    BuildContext context, {
    bool isDevicesTable = false,
  }) async {
    CustomAlert.showCustomScaffoldMessenger(
      mainNavigatorKey.currentContext!,
      "Preparing data for export...",
      AlertType.info,
    );

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
        isDevicesTable: isDevicesTable,
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
        isDevicesTable: isDevicesTable,
      );
    }

    if (path != null) {
      
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

  final Map<String, dynamic> _apiCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Future<dynamic>> _pendingRequests = {};
  static const Duration _cacheExpiry = Duration(minutes: 15);
  
  static const int _maxCacheSize = 50;
  final List<String> _cacheAccessOrder = [];

  Future<FilterAndSummaryForProject?> updateSelectedFilters(
      List<String?> filters, FilterAndSummaryForProject? filterData) async {
    currentFilters = filters.where((filter) => filter != null).cast<String>().toList();
    this.filterData = filterData;
    bool toRefreshSummaryPage = true;

    try {
      
      await updateBottomNavTabs(project: currentFilters.first);
      emit(ChangeDashBoardNav());
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Error in loading trends data : ${e.toString()}", AlertType.error);
      return null;
    }

    final List<Future<void>> dataLoadingTasks = [];
    
    if (currentFilters.isNotEmpty) {
      dataLoadingTasks.add(_loadTrendsDataWithCache(currentFilters.firstOrNull));
    }
    
    if (toRefreshSummaryPage) {
      dataLoadingTasks.add(_loadSummaryDataWithCache());
      dataLoadingTasks.add(_loadDevicesDataWithCache());
    }

    try {
      await Future.wait(dataLoadingTasks);
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Error in loading data : ${e.toString()}", AlertType.error);
      return null;
    }

    refreshSummaryPage();
    refreshDashboard();
    
    return filterData;
  }

  Future<void> _loadTrendsDataWithCache(String? project) async {
    if (project == null) return;
    
    PerformanceMonitor.startTimer('load_trends_data');
    
    final cacheKey = 'trends_${project}_${currentFilters.length > 1 ? currentFilters.sublist(1).join('>') : ""}';
    
    if (_pendingRequests.containsKey(cacheKey)) {
      final data = await _pendingRequests[cacheKey]!;
      updateTrendsData(data);
      PerformanceMonitor.endTimer('load_trends_data');
      return;
    }
    
    if (_isCacheValid(cacheKey)) {
      updateTrendsData(_apiCache[cacheKey]);
      PerformanceMonitor.endTimer('load_trends_data');
      return;
    }

    final future = _loadTrendsDataInternal(project);
    _pendingRequests[cacheKey] = future;
    
    try {
      final data = await future;
      _apiCache[cacheKey] = data;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cacheAccessOrder.add(cacheKey);
      _evictLRUEntries();
      updateTrendsData(data);
    } catch (e) {
      throw Exception("Error loading trends data: ${e.toString()}");
    } finally {
      _pendingRequests.remove(cacheKey);
      PerformanceMonitor.endTimer('load_trends_data');
    }
  }
  
  Future<dynamic> _loadTrendsDataInternal(String project) async {
    return await DataPostRequests.getChartData(
        project: project,
        selectedLevels: currentFilters.length > 1 ? currentFilters.sublist(1) : [""]);
  }

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

  Future<void> _loadDevicesDataWithCache() async {
    if (currentFilters.isEmpty) return;
    
    final project = currentFilters.first;
    final cacheKey = 'devices_$project';
    
    if (_isCacheValid(cacheKey)) {
      devicesData = _apiCache[cacheKey];
      allDevices = _apiCache['${cacheKey}_all'];
      return;
    }

    try {
      
      final filtersCacheKey = 'filters_$project';
      dynamic response;
      
      if (_isCacheValid(filtersCacheKey)) {
        
        response = _apiCache[filtersCacheKey];
      } else {
        
        response = await DataPostRequests.getFilters(project: project);
        _apiCache[filtersCacheKey] = response;
        _cacheTimestamps[filtersCacheKey] = DateTime.now();
        _cacheAccessOrder.add(filtersCacheKey);
        _evictLRUEntries();
      }

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

  bool _isCacheValid(String cacheKey) {
    if (!_apiCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final cacheTime = _cacheTimestamps[cacheKey]!;
    final isValid = DateTime.now().difference(cacheTime) < _cacheExpiry;
    
    if (isValid) {
      
      _cacheAccessOrder.remove(cacheKey);
      _cacheAccessOrder.add(cacheKey);
    }
    
    return isValid;
  }

  void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
    _pendingRequests.clear();
    _cacheAccessOrder.clear();
  }
  
  void _evictLRUEntries() {
    while (_apiCache.length > _maxCacheSize && _cacheAccessOrder.isNotEmpty) {
      final oldestKey = _cacheAccessOrder.removeAt(0);
      _apiCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  void clearProjectCache(String project) {
    final keysToRemove = _apiCache.keys.where((key) => key.contains(project)).toList();
    for (final key in keysToRemove) {
      _apiCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    final pendingKeysToRemove = _pendingRequests.keys.where((key) => key.contains(project)).toList();
    for (final key in pendingKeysToRemove) {
      _pendingRequests.remove(key);
    }
  }

  static Future<List<String>?> updateBottomNavTabs(
      {required String? project}) async {
    
    List<String> standardTabs = ['trends', 'billing', 'activity'];
    MainDashboardPage.bottomNavTabs = standardTabs;
    return standardTabs;
    
  }

  getDateFromDayNumber(int dayNumber) {
    
    var date = DateTime.utc(2020, 1, 1).add(Duration(days: dayNumber));
    
    return DateFormat('dd-MMM-yy').format(date);
  }

  updateTrendsData(var newData) {
    
    nudronChartData = NudronChartMap(newData);
  }

  selectProject(int selectedIndex) async {
    if (selectedIndex < projects.length && selectedIndex >= 0) {
      final selectedProject = projects[selectedIndex];
      
      if (selectedProject == currentFilters.firstOrNull) {
        return filterData;
      }
      
      if (currentFilters.isNotEmpty && currentFilters.first != selectedProject) {
        clearProjectCache(currentFilters.first);
      }
      
      if (selectedIndex == -1) {
        switchBottomNavPos(0); 
      }
      
      return await getFiltersAndSummaryForProject(selectedProject);
    }
    
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
    if (pos == 1 && currentFilters.isNotEmpty) { 
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
      debugPrint('loadInitialData called, current state: $state');
      
      emit(DashboardPageInitial());
      
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        
        if (kDebugMode) {
          debugPrint('User is not logged in, skipping dashboard data load');
        }
        emit(DashboardPageError(message: 'User not authenticated'));
        return;
      }
      
      debugPrint('User is logged in, loading user info...');
      await initUserInfo();
      debugPrint('User info loaded, projects: ${projects.length}');
      
      if (currentFilters.isNotEmpty && projects.isNotEmpty) {
        final selectedProject = currentFilters.first;
        if (projects.contains(selectedProject)) {
          try {
            debugPrint('Loading data for selected project: $selectedProject');
            
            final projectIndex = projects.indexOf(selectedProject);
            final filterData = await selectProject(projectIndex);
            
            if (filterData != null) {
              
              await updateSelectedFilters([selectedProject], filterData);
              
              debugPrint('Project data loaded successfully');
              emit(DashboardPageLoaded());
              return;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error loading project data after init: ${e.toString()}');
            }
            
          }
        }
      }
      
      debugPrint('No project selected, emitting DashboardPageLoaded');
      emit(DashboardPageLoaded());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading dashboard data: ${e.toString()}');
      }
      emit(DashboardPageError(message: e.toString()));
    }
  }

  DashboardBloc() : super(DashboardPageInitial()) {
    toUpdateProfile.addListener(updateProfile);
    
    if (kDebugMode) {
      Timer.periodic(const Duration(minutes: 5), (timer) {
        PerformanceMonitor.logPerformanceSummary();
      });
    }
  }
}