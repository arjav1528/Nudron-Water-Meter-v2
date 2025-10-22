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

class DataGridWidget extends StatefulWidget {
  final List<dynamic>? data;
  final int frozenColumns;
  final Map<int, int> columnsToTakeHeaderWidthAndExtraPadding;
  final bool exportToIncludeWholeData;
  final bool? devicesTable;
  final String location;

  const DataGridWidget({
    super.key,
    required this.data,
    this.frozenColumns = 1,
    this.columnsToTakeHeaderWidthAndExtraPadding = const {},
    this.exportToIncludeWholeData = false,
    this.devicesTable = false,
    this.location = 'trends',
  });

  @override
  State<DataGridWidget> createState() => _DataGridWidgetState();
}

class _DataGridWidgetState extends State<DataGridWidget> {
  final ScrollController _verticalScrollController1 = ScrollController();
  final ScrollController _verticalScrollController2 = ScrollController();
  final ScrollController _horizontalScrollController1 = ScrollController();
  final ScrollController _horizontalScrollController2 = ScrollController();

  List<double> columnWidths = [];

  final double rowHeight = 41.h;

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
                fontSize: ThemeNotifier.medium.responsiveSp,
                fontWeight: FontWeight.bold,
                height: 1.2, // Reduced line height
                letterSpacing: 0.5, // Matching spacing with the Text widget
              )
            : GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.medium.responsiveSp,
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
        3.responsiveSp +
        (hasDownloadButton
            ? rowHeight
            : 0.0); // Add small padding to account for edges
  }

  num dummyRows = 0;

  void init(double height) {
    calculateColumnWidths();
    
    // Optimize dummy row generation for large datasets
    final dataLength = widget.data![1].length;
    final visibleRows = (height / rowHeight).ceil();
    
    if (height > rowHeight * dataLength) {
      dummyRows = visibleRows - dataLength - 1;
      
      // Only add dummy rows if we have a reasonable number
      if (dummyRows > 0 && dummyRows < 1000) {
        final columnCount = widget.data![1][0].length;
        final dummyRow = List.filled(columnCount, '');
        
        for (int i = 0; i < dummyRows; i++) {
          widget.data![1].add(List.from(dummyRow));
        }
      }
    }
  }

  void calculateColumnWidths() {
    if (widget.data != null && widget.data!.isNotEmpty) {
      var headers = widget.data![0];
      var rows = widget.data![1];

      // Pre-allocate column widths list for better performance
      columnWidths = List<double>.filled(headers.length, 0.0);
      
      // Process columns with optimized width calculation
      for (int index = 0; index < headers.length; index++) {
        double headerWidth = calculateTextWidth(headers[index].toString(),
            isHeader: true, hasDownloadButton: index == 0);
        
        if (widget.columnsToTakeHeaderWidthAndExtraPadding.containsKey(index)) {
          columnWidths[index] = headerWidth +
              widget.columnsToTakeHeaderWidthAndExtraPadding[index]!.toDouble().w;
          continue;
        }

        // Optimize data width calculation with early termination
        double maxDataWidth = 0.0;
        for (var row in rows) {
          if (row[index] != null) {
            double cellWidth = calculateTextWidth(row[index].toString());
            if (cellWidth > maxDataWidth) {
              maxDataWidth = cellWidth;
              // Early termination if we've found a very wide cell
              if (maxDataWidth > headerWidth * 2) break;
            }
          }
        }
        
        columnWidths[index] = max(headerWidth, maxDataWidth);
      }
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
    if (widget.devicesTable == true) {
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
              width: index == columnWidths.length - 1 ? 0 : 3.responsiveSp,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: 3.responsiveSp,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: HeaderWidget(
          title: Utils.cleanFieldName(widget.data![0][index].toString()),
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
              width: index == columnWidths.length - 1 ? 0 : 3.responsiveSp,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: 3.responsiveSp,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: HeaderWidget(
          title: Utils.cleanFieldName(widget.data![0][index].toString()),
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
            width: index2 == widget.data![1][index].length - 1 ? 0 : 3.responsiveSp,
          ),
          bottom: BorderSide(
            color: index == widget.data![1]!.length - 1
                ? Colors.transparent
                : Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridLineColor,
            width: index == widget.data![1]!.length - 1 ? 0.00 : 3.responsiveSp,
          ),
        ),
      ),
      child: widget.columnsToTakeHeaderWidthAndExtraPadding.containsKey(index2)
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _getNCNormalWidget(index, index2, context))
          : _getNCNormalWidget(index, index2, context),
    );
  }

  _getNCNormalWidget(int index, int index2, BuildContext context) {
    String? field = widget.data![0][index2].toString();
    if (field[0] == '%' && widget.devicesTable == true) {
      return Text(
        Utils.lastSeenFromMilliseconds(widget.data![1][index][index2].toString())
            .toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.responsiveSp,
          height: 1.2,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
        ),
      );
    } else if (field[0] == '@' && widget.devicesTable == true) {
      String? lastSeenDate =
          NudronChartMap.convertDaysToDate(widget.data![1][index][index2].toString());
      if (lastSeenDate == '01-Jan-20') {
        lastSeenDate = 'NA';
      }
      return Text(
        lastSeenDate,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.responsiveSp,
          height: 1.2,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
        ),
      );
    } else {
      return Text(
        widget.data![1][index][index2].toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.responsiveSp,
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

    if (widget.data == null || widget.data!.isEmpty || widget.data![1].isEmpty) {
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
                        if (widget.frozenColumns > 0)
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
                                  width: 3.responsiveSp,
                                ),
                                bottom: BorderSide(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                  width: 3.responsiveSp,
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
                                    radius: 20.responsiveSp,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.h, horizontal: 7.w),
                                      // height: rowHeight,
                                      // width: rowHeight,
                                      child: Icon(
                                        Icons.download,
                                        size: 30.responsiveSp,
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
                                          widget.data!,
                                          widget.exportToIncludeWholeData,
                                          widget.location,
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
                                          widget.data![0][0].toString()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: List.generate(
                            widget.frozenColumns - 1,
                            (index) => _getHeaderWidget(index + 1, context),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController1,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                widget.data![0].length - widget.frozenColumns,
                                (index) => _getHeaderWidget(
                                    index + widget.frozenColumns, context),
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
                              children: List.generate(widget.data![1].length, (index) {
                                return Row(
                                  children: List.generate(
                                    widget.frozenColumns,
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
                                      List.generate(widget.data![1].length, (index) {
                                    return Row(
                                      children: List.generate(
                                          widget.data![1][index].length -
                                              widget.frozenColumns, (index2) {
                                        return _getNormalWidget(index,
                                            index2 + widget.frozenColumns, context);
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