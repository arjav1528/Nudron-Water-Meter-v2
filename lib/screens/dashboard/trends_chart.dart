import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../models/chartModels.dart';
import '../../utils/no_entries.dart';
import '../../utils/performance_monitor.dart';
import '../../widgets/export_to_excel.dart';


List<Color> listOfBarColor = [
  const Color(0xffa31420),
  const Color(0xffe42030),
  const Color(0xffec646f),
];

var xLabelsMonthly = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

List<Color> listOfLineColor = [
  const Color(0xff45b4d9),
  const Color(0xff00bc8a),
  const Color(0xffe3b039),
];
double animationDuration = 200;

TooltipBehavior createCustomTooltipBehavior({
  required NudronChartMap? dataMap,
  int? indexMonth,
  required BuildContext context,
}) {
  return TooltipBehavior(
    color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
    tooltipPosition: TooltipPosition.pointer,
    activationMode: ActivationMode.singleTap,
    enable: true,
    shouldAlwaysShow: false,
    animationDuration: 100,
    // duration: 100,
    builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
        int seriesIndex) {
      if (dataMap == null) return Container();

      List<String> tooltipContent = [];
      DateFormat monthFormatter = DateFormat('MMM');
      String x = data.x;
      int xNumeric;

      if (indexMonth != null) {
        xNumeric = int.parse(x); // Parse day as integer
      } else {
        // Convert month abbreviation to month number
        xNumeric = monthFormatter.parse(x.replaceAll('*', '')).month;
      }

      List<int> yearKeys = dataMap.getYearKeys();
      for (int year in yearKeys) {
        NudronChartData2? yearData;
        if (indexMonth != null) {
          yearData = dataMap.getDayDataChart(year, indexMonth, xNumeric);
        } else {
          yearData = dataMap.getMonthDataChart(year, xNumeric);
        }

        if (yearData != null) {
          tooltipContent
              .add("US '${year.toString().substring(2)}: ${yearData.usage}");
          tooltipContent
              .add("AL '${year.toString().substring(2)}: ${yearData.alerts}");
        }
      }

      // tooltipContent.sort((a, b) => b.compareTo(a));

      if (tooltipContent.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "No data available",
            style: GoogleFonts.roboto(
              fontSize: ThemeNotifier.small.responsiveSp,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (String content in tooltipContent)
              Text(
                content,
                style: GoogleFonts.roboto(
                  fontSize: ThemeNotifier.small.responsiveSp,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                ),
              ),
          ],
        ),
      );
    },
  );
}

getLabelName(int year, bool isAlerts, bool isFullScreen) {
  if (isFullScreen) {
    if (!isAlerts) {
      return "Usage $year";
    } else {
      return "Alerts $year";
    }
  } else {
    if (!isAlerts) {
      return "US '${year.toString().substring(2)}";
    } else {
      return "AL '${year.toString().substring(2)}";
    }
  }
}

class MonthlyChart extends StatefulWidget {
  final Function(int month) onMonthSelected;
  final Function onSaveChart;
  final bool isFullScreen;

  const MonthlyChart(
      {super.key,
      required this.onMonthSelected,
      required this.onSaveChart,
      required this.isFullScreen});

  @override
  _MonthlyChartState createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<MonthlyChart> {
  List<CartesianSeries<Entries, String>> monthlySeries = [];
  double usageMaximum = 535.7;
  double alertMaximum = 144;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dataMap = BlocProvider.of<DashboardBloc>(context).nudronChartData;
        if (dataMap != null) {
          _getSeriesMonthly(dataMap);
        }
      }
    });
  }

  void _getSeriesMonthly(NudronChartMap dataMap) {
    PerformanceMonitor.startTimer('get_series_monthly');
    
    List<CartesianSeries<Entries, String>> series = [];
    String currentMonth = DateFormat('MM').format(DateTime.now());

    // Pre-allocate maps for better performance
    final Map<int, List<Entries>> allEntries = {};
    int maxAlerts = 0;
    int maxUsages = 0;

    List<int> years = dataMap.getYearKeys();
    Set<int> doneMonths = {}; // To keep track of months that have data across all years

    // Collect data entries for all years without adding missing months
    for (int year in years) {
      List<Entries> monthlyEntries = [];
      int check = 0;
      for (int month = 1; month <= 12; month++) {
        var monthData = dataMap.getMonthDataChart(year, month);
        String monthLabel = NudronChartMap.getMonthName(month) +
            (month == int.parse(currentMonth) ? "*" : "");
        if (monthData != null &&
            check == 0 &&
            month != 1 &&
            dataMap.getMonthDataLength(year) == 1) {
          monthlyEntries.add(Entries(
            alerts: 0,
            usages: 0,
            x: NudronChartMap.getPreviousMonthName(month).substring(0, 3),
            x2: NudronChartMap.getYearOfPreviousMonth(month, year),
          ));
          check++;
        }
        if (monthData != null) {
          // Add data if available
          monthlyEntries.add(Entries(
            alerts: monthData.alerts,
            usages: monthData.usage,
            x: monthLabel,
            x2: year.toString(),
          ));
          check++;
          doneMonths.add(month); // Track months that have data
          maxAlerts =
              monthData.alerts > maxAlerts ? monthData.alerts : maxAlerts;
          maxUsages = monthData.usage > maxUsages ? monthData.usage : maxUsages;
        }
      }

      allEntries[year] = monthlyEntries;
    }

    // if (doneMonths.isNotEmpty) {
    //   int firstMonthWithData = doneMonths.reduce((a, b) => a < b ? a : b);
    //   int lastMonthWithData = doneMonths.reduce((a, b) => a > b ? a : b);
    //
    //   // Find all months between the first and last month with data
    //   Set<int> monthsToFill = Set.from(List.generate(
    //       lastMonthWithData - firstMonthWithData + 1,
    //       (index) => firstMonthWithData + index));
    //   Set<int> missingMonths = monthsToFill.difference(doneMonths);
    //
    //   // Add missing months to the first year in the list
    //   int firstYear = years.first;
    //   List<Entries>? firstYearEntries = allEntries[firstYear];
    //
    //   if (missingMonths.isNotEmpty && firstYearEntries != null) {
    //     for (int month in missingMonths) {
    //       String monthLabel = NudronChartMap.getMonthName(month) +
    //           (month == int.parse(currentMonth) ? "*" : "");
    //       // Add dummy entry for the missing month
    //       firstYearEntries.add(Entries(
    //         alerts: 0, // No data, so zero alerts
    //         usages: 0, // No data, so zero usage
    //         x: monthLabel,
    //         x2: firstYear.toString(),
    //       ));
    //     }
    //
    //     // Sort the entries by month index to ensure the correct order
    //     firstYearEntries.sort((a, b) {
    //       int monthA =
    //           dataMap.getMonthNumberFromName(a.x.replaceAll('*', '').trim());
    //       int monthB =
    //           dataMap.getMonthNumberFromName(b.x.replaceAll('*', '').trim());
    //       return monthA.compareTo(monthB);
    //     });
    //
    //     // Update the allEntries map with the sorted data
    //     allEntries[firstYear] = firstYearEntries;
    //   }
    // }

    alertMaximum = customRound(maxAlerts.toDouble() * 3);
    usageMaximum = customRound(maxUsages.toDouble() * 1.1);
    int colorIndex = 0;
    if (allEntries.isNotEmpty) {
      List<Entries> dummyEntries = [];
      for (int month = 1; month <= 12; month++) {
        String monthLabel = NudronChartMap.getMonthName(month) +
            (month == int.parse(currentMonth) ? "*" : "");
        dummyEntries.add(Entries(
          alerts: 0,
          usages: 0,
          x: monthLabel,
          x2: years.first.toString(),
        ));
      }

      series.add(LineSeries<Entries, String>(
        dataSource: dummyEntries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => 0,
        isVisibleInLegend: false,
        // visible: false,
        color: Colors.transparent,
        // Fully transparent color
        enableTooltip: false,
        name: '',
        // No label
        markerSettings: MarkerSettings(isVisible: false), // No marker
      ));
    }
    // series.add(ColumnSeries(
    //   animationDuration: animationDuration,
    //   onPointDoubleTap: (ChartPointDetails details) async {
    //     final selectedMonthLabel = details.dataPoints![details.pointIndex!].x;
    //     final monthName = selectedMonthLabel.replaceAll('*', '').trim();
    //     int selectedMonth = NudronChartMap.getMonthNumberFromName(monthName);
    //     widget.onMonthSelected(selectedMonth);
    //   },
    //   dataSource: [Entries(alerts: 0, usages: 0, x: 'Jan', x2: '2024')],
    //   xValueMapper: (Entries data, _) => data.x,
    //   yValueMapper: (Entries data, _) => data.alerts,
    //   name: getLabelName(2024, true, widget.isFullScreen),
    //   yAxisName: 'alert',
    //   color: listOfBarColor[colorIndex % listOfBarColor.length],
    //   // width: (allEntries.length == 1) ? 0.04 : 0.7,
    // ));
    // Generate the series from the allEntries map

    allEntries.forEach((year, entries) {
      series.add(ColumnSeries<Entries, String>(
        animationDuration: animationDuration,
        onPointDoubleTap: (ChartPointDetails details) async {
          final selectedMonthLabel = details.dataPoints![details.pointIndex!].x;
          final monthName = selectedMonthLabel.replaceAll('*', '').trim();
          int selectedMonth = NudronChartMap.getMonthNumberFromName(monthName);
          widget.onMonthSelected(selectedMonth);
        },
        dataSource: entries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => data.alerts,
        name: getLabelName(year, true, widget.isFullScreen),
        yAxisName: 'alert',
        color: listOfBarColor[colorIndex % listOfBarColor.length],
        // width: (allEntries.length == 1) ? 0.04 : 0.7,
      ));
      colorIndex++;
    });
    colorIndex = 0;
    allEntries.forEach((year, entries) {
      series.add(LineSeries<Entries, String>(
        animationDuration: animationDuration,
        markerSettings: MarkerSettings(
            color: listOfLineColor[colorIndex % listOfLineColor.length],
            isVisible: true),
        onPointDoubleTap: (ChartPointDetails details) async {
          final selectedMonthLabel = details.dataPoints![details.pointIndex!].x;
          final monthName = selectedMonthLabel.replaceAll('*', '').trim();

          int selectedMonth = NudronChartMap.getMonthNumberFromName(monthName);
          widget.onMonthSelected(selectedMonth);
        },
        dataSource: (entries.length == 2 &&
                entries[0].alerts == 0 &&
                entries[0].usages == 0 &&
                entries[0].x != 'Jan')
            ? entries.sublist(1)
            : entries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => data.usages,
        yAxisName: 'waterUsage',
        name: getLabelName(year, false, widget.isFullScreen),
        color: listOfLineColor[colorIndex % listOfLineColor.length],
      ));
      colorIndex++;
    });

    

    setState(() {
      monthlySeries = series;
    });
    
    PerformanceMonitor.endTimer('get_series_monthly');
  }

  @override
  Widget build(BuildContext context) {
    
    return BasicChart(
      series: monthlySeries,
      onSaveChart: widget.onSaveChart,
      switchToDaily: widget.onMonthSelected,
      isFullScreen: widget.isFullScreen,
      usageMaximum: usageMaximum,
      alertMaximum: alertMaximum,
      tooltipBehavior: createCustomTooltipBehavior(
        dataMap: BlocProvider.of<DashboardBloc>(context).nudronChartData,
        indexMonth: null,
        context: context,
      ),

      middleWidget: Text(
        "MONTHLY TREND",
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.small.responsiveSp,
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .basicAdvanceTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      // No specific month, for monthly view
      isDaily: false,
    );
  }
}

double customRound(double value) {
  int numDigits = value.abs().toInt().toString().length;
  if (numDigits == 1) {
    return 8;
  }

  if (numDigits == 2) {
    return ((value / 4).ceil()) * 4.toDouble();
  }

  // Calculate the base for rounding based on the number of digits
  int base = pow(10, numDigits - 1).toInt();

  // If numDigits is odd, multiply base by 5 (to handle cases like 500, 5000, etc.)
  if (numDigits % 2 == 0) {
    base = base ~/ 2.0;
  }

  // Round down to the nearest multiple of the calculated base
  var a = ((value / base).ceil() * base).toDouble();
  return a;
}

class DailyChart extends StatefulWidget {
  DailyChart({super.key, required this.onSaveChart, required this.isFullScreen});
  Function onSaveChart;
  bool isFullScreen;

  @override
  _DailyChartState createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  List<CartesianSeries<Entries, String>> dailySeries = [];
  double usageMaximum = 535.7;
  double alertMaximum = 144;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getSeriesDaily(NudronChartMap.selectedMonth.value);
      }
    });

    NudronChartMap.selectedMonth.addListener(() {
      if (mounted) {
        _getSeriesDaily(NudronChartMap.selectedMonth.value);
      }
    });
  }

  @override
  void dispose() {
    clearData(); // Clear the series when the widget is disposed
    super.dispose();
  }

  clearData() {
    dailySeries.clear();
    dailySeries =
        []; // This helps to ensure that the list is completely dereferenced
  }

  bool isShowingState = false;

  clearDailySeries() {
    clearData();
    setState(() {});
  }

  // @override
  // void dispose() {
  //   Provider.of<MonthNotifier>(context, listen: false)
  //       .removeListener(_handleMonthChange);
  //   super.dispose();
  // }

  // void _handleMonthChange(int month) {
  //   if (month != -1)
  //     _getSeriesDaily(month);
  //   else
  //     clearDailySeries();
  // }

  void _getSeriesDaily(int indexMonth) async {
    if (indexMonth == -1) {
      isShowingState = false;
      clearDailySeries();
      return;
    }

    final dataMap = BlocProvider.of<DashboardBloc>(context).nudronChartData;
    if (dataMap == null) return;

    List<CartesianSeries<Entries, String>> series = [];
    Map<int, List<Entries>> allEntries = {}; // Keyed by year

    int maxAlerts = 0;
    int maxUsages = 0;

    int maxDays = DateTime(2024, indexMonth + 1, 0).day;
    DateTime now = DateTime.now();

    int currentMonth = now.month;
    int currentDay = now.day;

    for (int year in dataMap.getYearKeys()) {
      List<Entries> yearEntries = [];
      var check = 0;
      for (int day = 1; day <= DateTime(year, indexMonth + 1, 0).day; day++) {
        String dayLabel = day.toString() +
            ((currentMonth == indexMonth && currentDay == day) ? '*' : '');

        NudronChartData2? dayData =
            dataMap.getDayDataChart(year, indexMonth, day);
        if (dayData != null &&
            check == 0 &&
            day != 1 &&
            dataMap.getDayDataLength(year, indexMonth) == 2) {
          yearEntries.add(Entries(
            alerts: 0,
            usages: 0,
            x: NudronChartMap.getPreviousDate(day, indexMonth),
            x2: NudronChartMap.getYearOfPreviousMonth(indexMonth, year),
          ));
          check++;
        }

        // int todayDate=
        // String dayLabel = day.toString();
        if (dayData != null) {
          yearEntries.add(Entries(
            alerts: dayData.alerts,
            usages: dayData.usage,
            x: dayLabel,
            x2: year.toString(),
          ));
          check++;
          // Update maximum values
          maxAlerts = dayData.alerts > maxAlerts ? dayData.alerts : maxAlerts;
          maxUsages = dayData.usage > maxUsages ? dayData.usage : maxUsages;
        }
      }

     

      if (yearEntries.isNotEmpty) {
        allEntries[year] = yearEntries;
      }
    }

    alertMaximum = customRound(maxAlerts.toDouble() * 3);
    usageMaximum = customRound(maxUsages.toDouble() * 1.1);

    if (allEntries.isNotEmpty) {
      List<Entries> dummyEntries = [];
      for (int day = 1; day <= maxDays; day++) {
        String dayLabel = day.toString() +
            ((currentMonth == indexMonth && currentDay == day) ? '*' : '');

        dummyEntries.add(Entries(
          alerts: 0,
          usages: 0,
          x: dayLabel,
          x2: '',
        ));
      }

      series.add(LineSeries<Entries, String>(
        dataSource: dummyEntries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => 0,
        isVisibleInLegend: false,
        // Transparent at 0
        color: Colors.transparent,
        // Fully transparent color
        enableTooltip: false,
        name: '',
        // No label
        markerSettings: MarkerSettings(isVisible: false), // No marker
      ));
    }

    // Generate the series for each year
    int seriesIndex = 0;

    allEntries.forEach((year, entries) {
      // Column series for alerts
      series.add(ColumnSeries<Entries, String>(
        animationDuration: animationDuration,
        dataSource: entries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => data.alerts,
        color: listOfBarColor[seriesIndex % listOfBarColor.length],
        yAxisName: 'alert',
        name: getLabelName(year, true, widget.isFullScreen),
      ));
      seriesIndex++;
    });
    seriesIndex = 0;
    allEntries.forEach((year, entries) {
      // Line series for usages
      series.add(LineSeries<Entries, String>(
        animationDuration: animationDuration,
        dataSource: (entries.length == 2 &&
                entries[0].usages == 0 &&
                entries[0].alerts == 0 &&
                entries[0].x != '1')
            ? entries.sublist(1)
            : entries,
        xValueMapper: (Entries data, _) => data.x,
        yValueMapper: (Entries data, _) => data.usages,
        markerSettings: MarkerSettings(
          color: listOfLineColor[seriesIndex % listOfLineColor.length],
          isVisible: true,
        ),
        color: listOfLineColor[seriesIndex % listOfLineColor.length],
        yAxisName: 'waterUsage',
        name: getLabelName(year, false, widget.isFullScreen),
      ));
      seriesIndex++;
    });
    // TODO: Make the adjustment for daily data when only one data point is available

   

    setState(() {
      isShowingState = true;
      dailySeries = series;
    });
  }

  void switchBackToMonthly() {
    NudronChartMap.selectedMonth.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return !isShowingState
        ? Container()
        : BasicChart(
            key: UniqueKey(),
            isFullScreen: widget.isFullScreen,
            onSaveChart: widget.onSaveChart,
            middleWidget: Builder(
              builder: (context) {
                return Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .splashColor,
                        splashFactory: InkRipple.splashFactory,
                        radius: 20.responsiveSp,
                        child: SizedBox(
                          height: 41.responsiveSp,
                          width: 41.responsiveSp,
                          child: Icon(
                            Icons.arrow_back_sharp,
                            size: 30.responsiveSp,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor
                                .withOpacity(0.8),
                          ),
                        ),
                        onTap: () async {
                          switchBackToMonthly();
                        },
                      ),
                    ),
                    Text(
                      "${xLabelsMonthly[NudronChartMap.selectedMonth.value - 1]} Trend"
                          .toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        fontSize: ThemeNotifier.small.responsiveSp,
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .basicAdvanceTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            series: dailySeries,
            usageMaximum: usageMaximum,
            alertMaximum: alertMaximum,
            tooltipBehavior: createCustomTooltipBehavior(
              dataMap: BlocProvider.of<DashboardBloc>(context).nudronChartData,
              indexMonth: NudronChartMap.selectedMonth.value,
              context: context,
            ),
            isDaily: true,
          );
  }
}

class TrendsChart extends StatefulWidget {
  final bool isFullScreen;

  const TrendsChart({super.key, this.isFullScreen = false});

  @override
  _TrendsChartState createState() => _TrendsChartState();
}

class _TrendsChartState extends State<TrendsChart> {
  Future<void> _saveChartAsImage(BuildContext context) async {
    try {
      await BlocProvider.of<DashboardBloc>(context).captureSS();
    } catch (e) {
    }
  }

  void switchToDaily(int month) {
    NudronChartMap.selectedMonth.value = month;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                MonthlyChart(
                    onMonthSelected: switchToDaily,
                    isFullScreen: widget.isFullScreen,
                    onSaveChart: _saveChartAsImage),
                DailyChart(
                    onSaveChart: _saveChartAsImage,
                    isFullScreen: widget.isFullScreen),
              ],
            );
          },
        ),
      ],
    );
  }
}

class BasicChart extends StatelessWidget {
  final List<CartesianSeries<Entries, String>> series;
  final double usageMaximum;
  final double alertMaximum;
  final bool isDaily;
  final TooltipBehavior tooltipBehavior;
  final Widget middleWidget;
  final Function onSaveChart;
  final bool isFullScreen;
  final Function? switchToDaily;

  const BasicChart({
    super.key,
    required this.onSaveChart,
    required this.series,
    required this.usageMaximum,
    required this.alertMaximum,
    required this.tooltipBehavior,
    this.isDaily = false,
    required this.middleWidget,
    required this.isFullScreen,
    this.switchToDaily,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (context, constriants) {
          return series.isEmpty && !isDaily
              ? NoEntries()
              : Container(
                  color:
                      Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "USAGE(L)",
                            style: GoogleFonts.robotoMono(
                              fontSize: ThemeNotifier.small.responsiveSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              middleWidget,
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor:
                                      Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .splashColor,
                                  splashFactory: InkRipple.splashFactory,
                                  radius: 20.responsiveSp,
                                  child: SizedBox(
                                    height: 41.responsiveSp,
                                    width: 41.responsiveSp,
                                    child: Icon(
                                      Icons.save,
                                      size: 30.responsiveSp,
                                      color:
                                          Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .basicAdvanceTextColor
                                              .withOpacity(0.8),
                                    ),
                                  ),
                                  onTap: () async {
                                    bool? confirm = await showDialog(
                                      context: context,
                                      builder: (context2) {
                                        return RotatedBox(
                                          quarterTurns: isFullScreen ? 1 : 0,
                                          child: ConfirmationDialog(
                                            heading: "Export image",
                                            message:
                                                "Do you want to save this chart as an image?"
                                                    .toUpperCase(),
                                          ),
                                        );
                                      },
                                    );
                      
                                    if (confirm == true) {
                                      onSaveChart(context);
                                    }
                                  },
                                ),
                              ),
                              if (!isFullScreen)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .splashColor,
                                    splashFactory: InkRipple.splashFactory,
                                    radius: 20.responsiveSp,
                                    child: SizedBox(
                                      height: 41.responsiveSp,
                                      width: 41.responsiveSp,
                                      child: Icon(
                                        Icons.zoom_out_map,
                                        size: 30.responsiveSp,
                                        color: Provider.of<ThemeNotifier>(
                                                context)
                                            .currentTheme
                                            .basicAdvanceTextColor
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    onTap: () async {
                                      BlocProvider.of<DashboardBloc>(context)
                                          .changeScreen();
                      
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context2) =>
                                      //         BlocProvider.value(
                                      //       value:
                                      //           BlocProvider.of<DashboardBloc>(
                                      //               context),
                                      //       child: Scaffold(
                                      //         backgroundColor:
                                      //             Provider.of<ThemeNotifier>(
                                      //                     context)
                                      //                 .currentTheme
                                      //                 .bgColor,
                                      //         appBar: AppBar(
                                      //           backgroundColor:
                                      //               Provider.of<ThemeNotifier>(
                                      //                       context)
                                      //                   .currentTheme
                                      //                   .bgColor,
                                      //           leading: IconButton(
                                      //             icon: Icon(
                                      //               Icons.arrow_back,
                                      //               color: Provider.of<
                                      //                           ThemeNotifier>(
                                      //                       context)
                                      //                   .currentTheme
                                      //                   .basicAdvanceTextColor,
                                      //             ),
                                      //             onPressed: () {
                                      //               Navigator.pop(context2);
                                      //             },
                                      //           ),
                                      //           title: Text('Fullscreen Chart',
                                      //               style: TextStyle(
                                      //                   color: Provider.of<
                                      //                               ThemeNotifier>(
                                      //                           context)
                                      //                       .currentTheme
                                      //                       .basicAdvanceTextColor)),
                                      //         ),
                                      //         body: Center(
                                      //           child: RotatedBox(
                                      //             quarterTurns: 1,
                                      //             // Rotate 90 degrees
                                      //             child: TrendsChart(
                                      //                 isFullScreen: true),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            "ALERTS",
                            style: GoogleFonts.robotoMono(
                              fontSize: ThemeNotifier.small.responsiveSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // width: isFullScreen
                      //     ? constriants.maxWidth
                      //     : constriants.maxWidth * 1.5,
                      Expanded(
                        // height: constriants.maxHeight -25,
                        child: isDaily && series.isEmpty
                            ? NoEntries()
                            : SfCartesianChart(
                                onAxisLabelTapped: (args) {
                                  // var a=DateTime.now();
                                  if (args.axisName == 'primaryXAxis') {
                                    if (!isDaily && switchToDaily != null) {
                                      final monthName =
                                          args.text.replaceAll('*', '').trim();
                                      int selectedMonth =
                                          NudronChartMap.getMonthNumberFromName(
                                              monthName);
                                      switchToDaily!(selectedMonth);
                                    }
                                  }
                                  // var b=DateTime.now();
                                },
                                plotAreaBorderWidth: 0,
                                margin: const EdgeInsets.only(top: 0),
                                legend: Legend(
                                  isVisible: true,
                                  textStyle: GoogleFonts.roboto(
                                    fontSize: ThemeNotifier.small.responsiveSp,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                  ),
                                  position: LegendPosition.bottom,
                                  itemPadding: 10.w,
                                  orientation: LegendItemOrientation.horizontal,
                                  overflowMode: LegendItemOverflowMode.wrap,
                                ),
                                zoomPanBehavior: ZoomPanBehavior(
                                  enablePanning: true,
                                  enablePinching: false,
                                  zoomMode: ZoomMode.x,
                                  enableMouseWheelZooming: false,
                                  enableDoubleTapZooming: false,
                                  enableSelectionZooming: false,
                                ),
                                primaryXAxis: CategoryAxis(
                                  // plotOffset: 10,

                                  // placeLabelsNearAxisLine: true,
                                  initialVisibleMinimum: isFullScreen
                                      ? null
                                      : (series.isNotEmpty ? -0.5 : 0),

                                  // labelAlignment: LabelAlignment.start,
                                  initialVisibleMaximum: isFullScreen
                                      ? null
                                      : isDaily
                                          ? 14
                                          : 6,
                                  axisLine: AxisLine(
                                      width: 1,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .gridLineColor),
                                  labelStyle: GoogleFonts.roboto(
                                    fontSize: ThemeNotifier.small.responsiveSp,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                  ),
                                  desiredIntervals: isFullScreen
                                      ? null
                                      : isDaily
                                          ? 14
                                          : 6,
                                  labelPlacement: LabelPlacement.betweenTicks,
                                  majorGridLines: MajorGridLines(
                                      width: 0.w,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .gridLineColor),
                                  // minimum: 0,
                                  // maximum: isDaily
                                  //     ? DateTime(
                                  //                 2020,
                                  //                 NudronChartMap
                                  //                         .selectedMonth.value +
                                  //                     1,
                                  //                 0)
                                  //             .day
                                  //             .toDouble() -
                                  //         1
                                  //     : 11,
                                  // Adjusted for daily or monthly
                                  interval: 1,
                                ),
                                primaryYAxis: NumericAxis(
                                  axisLine: AxisLine(
                                      width: 0,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .gridLineColor),
                                  numberFormat: NumberFormat.compact(),
                                  desiredIntervals: 4,

                                  majorGridLines: MajorGridLines(
                                      width: 0.5.w,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .gridLineColor),
                                  labelStyle: GoogleFonts.roboto(
                                    fontSize: ThemeNotifier.small.responsiveSp,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                  ),
                                  opposedPosition: false,
                                  name: 'waterUsage',
                                  minimum: 0,
                                  // maximumLabels: 3,
                                  maximum: usageMaximum,
                                  title: AxisTitle(
                                    text: '',
                                    textStyle: TextStyle(
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .basicAdvanceTextColor,
                                      fontFamily: 'Roboto',
                                      fontSize: 12.responsiveSp,
                                    ),
                                  ),
                                ),
                                axes: <ChartAxis>[
                                  NumericAxis(
                                    axisLine: AxisLine(
                                        width: 0,
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .gridLineColor),
                                    numberFormat: NumberFormat.compact(),
                                    opposedPosition: true,
                                    desiredIntervals: 4,
                                    // labelAlignment: LabelAlignment.end,
                                    name: 'alert',
                                    autoScrollingMode: AutoScrollingMode.start,
                                    minimum: 0,
                                    maximum: alertMaximum,
                                    // maximumLabels: 3,
                                    majorGridLines: MajorGridLines(
                                        width: 0.w,
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .gridLineColor),
                                    labelStyle: GoogleFonts.roboto(
                                      fontSize: ThemeNotifier.small.responsiveSp,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .basicAdvanceTextColor,
                                    ),
                                    title: AxisTitle(
                                      text: '',
                                      textStyle: TextStyle(
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 12.responsiveSp,
                                      ),
                                    ),
                                  ),
                                ],
                                tooltipBehavior: tooltipBehavior,
                                series: series,
                              ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}