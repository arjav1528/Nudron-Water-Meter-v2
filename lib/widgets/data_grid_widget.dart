import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/chartModels.dart';
import '../../utils/pok.dart';
import '../../utils/utils.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../utils/no_entries.dart';

import '../../widgets/export_to_excel.dart';
import '../../widgets/icon_header.dart';
import '../utils/scrollConfig.dart';

class DataGridWidget extends StatelessWidget {
  List<dynamic>? data;
  final int frozenColumns;
  Map<int, int> columnsToTakeHeaderWidthAndExtraPadding;
  final bool exportToIncludeWholeData;
  final bool? devicesTable;
  final String location;

  DataGridWidget({
    super.key,
    required this.data,
    this.frozenColumns = 1,
    this.columnsToTakeHeaderWidthAndExtraPadding = const {},
    this.exportToIncludeWholeData = false,
    this.devicesTable = false,
    this.location = 'trends',
  });

  final ScrollController _verticalScrollController1 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();
  final ScrollController _horizontalScrollController1 = ScrollController();
  final ScrollController _horizontalScrollController2 = ScrollController();

  List<double> columnWidths = [];

  double rowHeight = 41.h;

  double calculateTextWidth(String text,
      {bool isHeader = false, bool hasDownloadButton = false}) {
    if (isHeader && text[0] == '!') {
      return 60.w;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: Utils.cleanFieldName(text),
        style: isHeader
            ? GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.medium.minSp,
                fontWeight: FontWeight.bold,
                height: 1.2, // Reduced line height
                letterSpacing: 0.5, // Matching spacing with the Text widget
              )
            : GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.medium.minSp,
                height: 1.2,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.5,
              ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0);

    // No longer multiplying the width excessively
    return textPainter.width +
        8 +
        3.minSp +
        (hasDownloadButton
            ? rowHeight
            : 0.0); // Add small padding to account for edges
  }

  num dummyRows = 0;

  void init(double height) {
    calculateColumnWidths();
    if (height > rowHeight * data![1].length) {
      //add dummy rows
      dummyRows = (height / rowHeight).ceil() - data![1].length - 1;
      for (int i = 0; i < dummyRows; i++) {
        data![1].add(List.generate(data![1][0].length, (index) => ''));
      }
    }
  }

  void calculateColumnWidths() {
    if (data != null && data!.isNotEmpty) {
      var headers = data![0];
      var rows = data![1];

      columnWidths = List.generate(headers.length, (index) {
        double headerWidth = calculateTextWidth(headers[index].toString(),
            isHeader: true, hasDownloadButton: index == 0);
        if (columnsToTakeHeaderWidthAndExtraPadding.containsKey(index)) {
          return headerWidth +
              columnsToTakeHeaderWidthAndExtraPadding[index]!.toDouble().w;
        }

        double maxDataWidth = rows.fold<double>(
          0.0,
          (prev, row) {
            double cellWidth = row[index] != null
                ? calculateTextWidth(row[index].toString())
                : 0.0;
            return max<double>(prev, cellWidth);
          },
        );
        return max(headerWidth, maxDataWidth);
      });
    }
  }

  void syncScrollControllers(
      ScrollController controller1, ScrollController controller2) {
    controller1.addListener(() {
      if (controller1.hasClients &&
          controller2.hasClients &&
          controller1.offset != controller2.offset) {
        controller2.jumpTo(controller1.offset);
      }
    });

    controller2.addListener(() {
      if (controller2.hasClients &&
          controller1.hasClients &&
          controller2.offset != controller1.offset) {
        controller1.jumpTo(controller2.offset);
      }
    });
  }

  _getHeaderWidget(int index, BuildContext context) {
    if (devicesTable == true) {
      return Container(
        height: rowHeight,
        width: columnWidths[index],
        decoration: BoxDecoration(
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .onSecondaryContainer,
          border: Border(
            right: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: index == columnWidths.length - 1 ? 0 : 3.minSp,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: 3.minSp,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: HeaderWidget(
          title: Utils.cleanFieldName(data![0][index].toString()),
        ),
      );
    } else {
      return Container(
        height: rowHeight,
        width: columnWidths[index],
        decoration: BoxDecoration(
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .onSecondaryContainer,
          border: Border(
            right: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: index == columnWidths.length - 1 ? 0 : 3.minSp,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: 3.minSp,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: HeaderWidget(
          title: Utils.cleanFieldName(data![0][index].toString()),
        ),
      );
    }
  }

  _getNormalWidget(int index, int index2, BuildContext context) {
    return Container(
      width: columnWidths[index2],
      height: rowHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: index % 2 == 1
            ? Provider.of<ThemeNotifier>(context)
                .currentTheme
                .onSecondaryContainer
            : Provider.of<ThemeNotifier>(context).currentTheme.primaryContainer,
        border: Border(
          right: BorderSide(
            color:
                Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
            width: index2 == data![1][index].length - 1 ? 0 : 3.minSp,
          ),
          bottom: BorderSide(
            color: index == data![1]!.length - 1
                ? Colors.transparent
                : Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridLineColor,
            width: index == data![1]!.length - 1 ? 0.00 : 3.minSp,
          ),
        ),
      ),
      child: columnsToTakeHeaderWidthAndExtraPadding.containsKey(index2)
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _getNCNormalWidget(index, index2, context))
          : _getNCNormalWidget(index, index2, context),
    );
  }

  _getNCNormalWidget(int index, int index2, BuildContext context) {
    String? field = data![0][index2].toString();
    if (field[0] == '%' && devicesTable == true) {
      print("Index: $index $index2");
      return Text(
        Utils.lastSeenFromMilliseconds(data![1][index][index2].toString())
            .toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.minSp,
          height: 1.2,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
        ),
      );
    } else if (field[0] == '@' && devicesTable == true) {
      String? lastSeenDate =
          NudronChartMap.convertDaysToDate(data![1][index][index2].toString());
      if (lastSeenDate == '01-Jan-20') {
        lastSeenDate = 'NA';
      }
      return Text(
        lastSeenDate,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.minSp,
          height: 1.2,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
        ),
      );
    } else {
      return Text(
        data![1][index][index2].toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.minSp,
          height: 1.2,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    syncScrollControllers(
        _verticalScrollController1, _verticalScrollController2);
    syncScrollControllers(
        _horizontalScrollController1, _horizontalScrollController2);

    if (data == null || data!.isEmpty || data![1].isEmpty) {
      return Center(
        child: const NoEntries(),
      );
    } else {
      return LayoutBuilder(builder: (context, contraints) {
        init(contraints.maxHeight);
        return ScrollConfiguration(
          behavior: NoBounceScrollBehavior(),
          child: Stack(
            children: [
              IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row including the top-left cell
                    Row(
                      children: [
                        if (frozenColumns > 0)
                          Container(
                            width: columnWidths[0],
                            height: rowHeight,
                            decoration: BoxDecoration(
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .onSecondaryContainer,
                              border: Border(
                                right: BorderSide(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                  width: 3.minSp,
                                ),
                                bottom: BorderSide(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                  width: 3.minSp,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .splashColor,
                                    splashFactory: InkRipple.splashFactory,
                                    radius: 20.minSp,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.h, horizontal: 7.w),
                                      // height: rowHeight,
                                      // width: rowHeight,
                                      child: Icon(
                                        Icons.download,
                                        size: 30.minSp,
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor
                                                .withOpacity(0.8),
                                      ),
                                    ),
                                    onTap: () async {
                                      bool confirm = await showDialog(
                                        context: context,
                                        builder: (context2) {
                                          return ConfirmationDialog(
                                            heading: "Export to Excel",
                                            message: "Export table to excel?"
                                                .toUpperCase(),
                                          );
                                        },
                                      );

                                      if (confirm == true) {
                                        BlocProvider.of<DashboardBloc>(context)
                                            .exportDataToExcel(
                                          data!,
                                          exportToIncludeWholeData,
                                          location,
                                          context,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: HeaderWidget(
                                      title: Utils.cleanFieldName(
                                          data![0][0].toString()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: List.generate(
                            frozenColumns - 1,
                            (index) => _getHeaderWidget(index + 1, context),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController1,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                data![0].length - frozenColumns,
                                (index) => _getHeaderWidget(
                                    index + frozenColumns, context),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // Main Grid Content with Scrollable Rows
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Column (Scrollable Vertically)
                          SingleChildScrollView(
                            controller: _verticalScrollController1,
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(data![1].length, (index) {
                                return Row(
                                  children: List.generate(
                                    frozenColumns,
                                    (index2) => _getNormalWidget(
                                        index, index2, context),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Main Grid Content (excluding first column)
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _verticalScrollController2,
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController2,
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      List.generate(data![1].length, (index) {
                                    return Row(
                                      children: List.generate(
                                          data![1][index].length -
                                              frozenColumns, (index2) {
                                        return _getNormalWidget(index,
                                            index2 + frozenColumns, context);
                                      }),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    }
  }
}