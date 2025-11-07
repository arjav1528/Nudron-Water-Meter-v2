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
    
    builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
        int seriesIndex) {
      if (dataMap == null) return Container();

      List<String> tooltipContent = [];
      DateFormat monthFormatter = DateFormat('MMM');
      String x = data.x;
      int xNumeric;

      if (indexMonth != null) {
        xNumeric = int.parse(x); 
      } else {
        
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

      if (tooltipContent.isEmpty) {
        return Container(
          padding: EdgeInsets.all(4.w),
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
        padding: EdgeInsets.all(4.w),
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

    final Map<int, List<Entries>> allEntries = {};
    int maxAlerts = 0;
    int maxUsages = 0;

    List<int> years = dataMap.getYearKeys();
    Set<int> doneMonths = {}; 

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
          
          monthlyEntries.add(Entries(
            alerts: monthData.alerts,
            usages: monthData.usage,
            x: monthLabel,
            x2: year.toString(),
          ));
          check++;
          doneMonths.add(month); 
          maxAlerts =
              monthData.alerts > maxAlerts ? monthData.alerts : maxAlerts;
          maxUsages = monthData.usage > maxUsages ? monthData.usage : maxUsages;
        }
      }

      allEntries[year] = monthlyEntries;
    }

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
        
        color: Colors.transparent,
        
        enableTooltip: false,
        name: '',
        
        markerSettings: MarkerSettings(isVisible: false), 
      ));
    }
    
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

  int base = pow(10, numDigits - 1).toInt();

  if (numDigits % 2 == 0) {
    base = base ~/ 2.0;
  }

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
    clearData(); 
    super.dispose();
  }

  clearData() {
    dailySeries.clear();
    dailySeries =
        []; 
  }

  bool isShowingState = false;

  clearDailySeries() {
    clearData();
    setState(() {});
  }

  void _getSeriesDaily(int indexMonth) async {
    if (indexMonth == -1) {
      isShowingState = false;
      clearDailySeries();
      return;
    }

    final dataMap = BlocProvider.of<DashboardBloc>(context).nudronChartData;
    if (dataMap == null) return;

    List<CartesianSeries<Entries, String>> series = [];
    Map<int, List<Entries>> allEntries = {}; 

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

        if (dayData != null) {
          yearEntries.add(Entries(
            alerts: dayData.alerts,
            usages: dayData.usage,
            x: dayLabel,
            x2: year.toString(),
          ));
          check++;
          
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
        
        color: Colors.transparent,
        
        enableTooltip: false,
        name: '',
        
        markerSettings: MarkerSettings(isVisible: false), 
      ));
    }

    int seriesIndex = 0;

    allEntries.forEach((year, entries) {
      
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
                          child: Transform.scale(
                            scaleX: -1,
                            child: Icon(
                              Icons.arrow_right_alt,
                              size: 30.responsiveSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor
                                  .withOpacity(0.8),
                            ),
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
          
          double screenWidth = constriants.maxWidth;
          int totalMonths = series.isNotEmpty ? (series.first.dataSource?.length ?? 12) : 12;
          int visibleMonths;
          
          if (isFullScreen) {
            
            visibleMonths = totalMonths;
          } else {
            if (isDaily) {
              
              double minWidthPerDay = 35.0;
              visibleMonths = (screenWidth / minWidthPerDay).floor();
              visibleMonths = visibleMonths > 31 ? 31 : visibleMonths; 
              visibleMonths = visibleMonths < 7 ? 7 : visibleMonths; 
            } else {
              
              double minWidthPerMonth = 55.0;
              visibleMonths = (screenWidth / minWidthPerMonth).floor();
              
              visibleMonths = visibleMonths > totalMonths ? totalMonths : visibleMonths;
              
              visibleMonths = visibleMonths < 4 ? 4 : visibleMonths;
              
              if (totalMonths <= visibleMonths) {
                visibleMonths = totalMonths;
              }
            }
          }
          
          return series.isEmpty && !isDaily
              ? NoEntries()
              : Container(
                  color:
                      Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
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
                      
                      Expanded(
                        
                        child: isDaily && series.isEmpty
                            ? NoEntries()
                            : SfCartesianChart(
                                onAxisLabelTapped: (args) {
                                  
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
                                  
                                },
                                plotAreaBorderWidth: 0,
                                margin: EdgeInsets.only(top: 0.h),
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
                                  
                                  initialVisibleMinimum: isFullScreen
                                      ? null
                                      : (series.isNotEmpty ? -0.5 : 0),

                                  initialVisibleMaximum: isFullScreen
                                      ? null
                                      : visibleMonths.toDouble(),
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
                                      : visibleMonths,
                                  labelPlacement: LabelPlacement.betweenTicks,
                                  majorGridLines: MajorGridLines(
                                      width: 0.w,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .gridLineColor),
                                  
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
                                    
                                    name: 'alert',
                                    autoScrollingMode: AutoScrollingMode.start,
                                    minimum: 0,
                                    maximum: alertMaximum,
                                    
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