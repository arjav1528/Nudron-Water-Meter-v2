import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/chartModels.dart';
import '../../utils/utils.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/no_entries.dart';
import '../../services/platform_utils.dart';

import '../../widgets/export_to_excel.dart';
import '../../widgets/icon_header.dart';
import '../utils/scrollConfig.dart';
import '../utils/excel_helpers.dart';

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
  final ScrollController _horizontalScrollControllerAverage = ScrollController();

  List<double> columnWidths = [];
  
  final Map<String, double> _textWidthCache = {};
  
  List<List<dynamic>>? _cachedProcessedData;
  List<dynamic>? _averageRow;

  final double rowHeight = UIConfig.rowHeight;
  final double headerRowHeight = UIConfig.headerWidgetHeight; // Add this line

  double calculateTextWidth(String text,
      {bool isHeader = false, bool hasDownloadButton = false}) {
    
    final cacheKey = '${text}_${isHeader}_${hasDownloadButton}';
    
    if (_textWidthCache.containsKey(cacheKey)) {
      return _textWidthCache[cacheKey]!;
    }
    
    double width;
    
    if (isHeader && text[0] == '!') {
      
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: Utils.cleanFieldName(text),
          style: GoogleFonts.robotoMono(
            fontSize: UIConfig.fontSizeTableHeaderMobile,
            fontWeight: UIConfig.fontWeightBold,
            height: UIConfig.lineHeight,
            letterSpacing: UIConfig.letterSpacing,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0);
      
      width = textPainter.width + UIConfig.tableTextWidthPadding + UIConfig.tableTextWidthPaddingSmall;
    } else {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: Utils.cleanFieldName(text),
          style: isHeader
              ? GoogleFonts.robotoMono(
                  fontSize: UIConfig.fontSizeTableHeaderMobile,
                  fontWeight: UIConfig.fontWeightBold,
                  height: UIConfig.lineHeight, 
                  letterSpacing: UIConfig.letterSpacing, 
                )
              : GoogleFonts.robotoMono(
                  fontSize: UIConfig.fontSizeTableMobile,
                  height: UIConfig.lineHeight,
                  fontWeight: UIConfig.fontWeightNormal,
                  letterSpacing: UIConfig.letterSpacing,
                ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0);

      width = textPainter.width +
          UIConfig.tableTextWidthPadding + 
          UIConfig.tableTextWidthPaddingSmall + 
          (hasDownloadButton
              ? rowHeight
              : 0.0); 
    }
    
    _textWidthCache[cacheKey] = width;
    return width;
  }

  num dummyRows = 0;

  void init(double height) {
    
    if (_cachedProcessedData == null || 
        _cachedProcessedData!.length != widget.data![1].length) {
      calculateColumnWidths();
      calculateAverages();
      _cachedProcessedData = List.from(widget.data![1]);
    }
    
    final dataLength = widget.data![1].length;
    final visibleRows = (height / rowHeight).ceil();
    
    if (height > rowHeight * dataLength) {
      dummyRows = visibleRows - dataLength - 1;
      
      if (dummyRows > 0 && dummyRows < 1000 && 
          widget.data![1].length == dataLength) {
        final columnCount = widget.data![1][0].length;
        final dummyRow = List.filled(columnCount, '');
        
        for (int i = 0; i < dummyRows; i++) {
          widget.data![1].add(List.from(dummyRow));
        }
      }
    }
  }

  void calculateAverages() {
    if (widget.data == null || 
        widget.data!.isEmpty || 
        widget.data![1].isEmpty ||
        widget.location != 'billing') {
      _averageRow = null;
      return;
    }

    var headers = widget.data![0];
    var rows = widget.data![1];
    
    if (rows.isEmpty) {
      _averageRow = null;
      return;
    }

    List<dynamic> averages = [];

    averages.add("Average");
    averages.add(" ");

    // For each column
    for (int colIndex = 2; colIndex < headers.length; colIndex++) {
      if (colIndex < widget.frozenColumns) {
        
      } else {
        // Numeric columns: calculate average
        double sum = 0.0;
        int count = 0;
        
        for (var row in rows) {
          if (row is List && colIndex < row.length && row[colIndex] != null) {
            try {
              // Try to parse as number
              String valueStr = row[colIndex].toString().trim();
              if (valueStr.isNotEmpty) {
                double? value = double.tryParse(valueStr);
                if (value != null) {
                  sum += value;
                  count++;
                }
              }
            } catch (e) {
              // Skip non-numeric values
            }
          }
        }
        
        if (count > 0) {
          double avg = sum / count;
          //TODO : Change the decimaal places
          String avgStr = avg.toStringAsFixed(0);
          if (avgStr.contains('.')) {
            avgStr = avgStr.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
          }
          averages.add(avgStr);
        } else {
          averages.add("0");
        }
      }
    }
    
    _averageRow = averages;
  }

  void calculateColumnWidths() {
    if (widget.data != null && widget.data!.isNotEmpty) {
      var headers = widget.data![0];
      var rows = widget.data![1];

      columnWidths = List<double>.filled(headers.length, 0.0);
      
      for (int index = 0; index < headers.length; index++) {
        double headerWidth = calculateTextWidth(headers[index].toString(),
            isHeader: true, hasDownloadButton: index == 0);
        
        // For frozen columns on mobile in billing/devices pages, use only header width
        bool isFrozenColumn = index < widget.frozenColumns;
        bool isMobile = PlatformUtils.isMobile;
        bool isBillingOrDevices = widget.location == 'billing' || widget.location == 'devices';
        
        if (isFrozenColumn && isMobile && isBillingOrDevices) {
          columnWidths[index] = headerWidth - 5.w;
          continue;
        }
        
        if (widget.columnsToTakeHeaderWidthAndExtraPadding.containsKey(index)) {
          columnWidths[index] = headerWidth +
              widget.columnsToTakeHeaderWidthAndExtraPadding[index]!.toDouble().w;
          continue;
        }

        double maxDataWidth = 0.0;
        
        bool shouldCheckAllRows = (widget.devicesTable == true && index == 0);
        
        if (rows.length > 1000 && !shouldCheckAllRows) {
          
          final sampleSize = min<int>(100, rows.length);
          final step = (rows.length ~/ sampleSize) as int;
          
          for (int i = 0; i < rows.length; i += step) {
            if (rows[i][index] != null) {
              double cellWidth = calculateTextWidth(rows[i][index].toString());
              if (cellWidth > maxDataWidth) {
                maxDataWidth = cellWidth;
                
                if (maxDataWidth > headerWidth * 2) break;
              }
            }
          }
        } else {
          
          for (var row in rows) {
            if (row[index] != null) {
              double cellWidth = calculateTextWidth(row[index].toString());
              if (cellWidth > maxDataWidth) {
                maxDataWidth = cellWidth;
                
                if (!shouldCheckAllRows && maxDataWidth > headerWidth * 2) break;
              }
            }
          }
        }
        
        columnWidths[index] = max(headerWidth, maxDataWidth);
      }
    }
  }

  @override
  void dispose() {
    
    _verticalScrollController1.dispose();
    _verticalScrollController2.dispose();
    _horizontalScrollController1.dispose();
    _horizontalScrollController2.dispose();
    _horizontalScrollControllerAverage.dispose();
    
    _textWidthCache.clear();
    _cachedProcessedData = null;
    
    super.dispose();
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
    bool isFrozenColumn = index < widget.frozenColumns;
    bool isDesktop = PlatformUtils.isDesktop;
    bool isDevicesPage = widget.location == 'devices' || widget.devicesTable == true;
    Alignment alignment = (isFrozenColumn && isDesktop && isDevicesPage) 
        ? Alignment.centerLeft 
        : Alignment.center;
    
    if (widget.devicesTable == true) {
      return Container(
        height: headerRowHeight, // Change from rowHeight to headerRowHeight
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
              width: index == columnWidths.length - 1 ? 0 : UIConfig.tableBorderWidth,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: UIConfig.tableBorderWidth,
            ),
          ),
        ),
        alignment: alignment,
        child: HeaderWidget(
          title: Utils.cleanFieldName(widget.data![0][index].toString()),
        ),
      );
    } else {
      return Container(
        height: headerRowHeight, // Change from rowHeight to headerRowHeight
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
              width: index == columnWidths.length - 1 ? 0 : UIConfig.tableBorderWidth,
            ),
            bottom: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
              width: UIConfig.tableBorderWidth,
            ),
          ),
        ),
        alignment: alignment,
        child: HeaderWidget(
          title: Utils.cleanFieldName(widget.data![0][index].toString()),
        ),
      );
    }
  }

  _getNormalWidget(int index, int index2, BuildContext context) {
    bool isFrozenColumn = index2 < widget.frozenColumns;
    bool isDesktop = PlatformUtils.isDesktop;
    bool isDevicesPage = widget.location == 'devices' || widget.devicesTable == true;
    Alignment alignment = (isFrozenColumn && isDesktop && isDevicesPage) 
        ? Alignment.centerLeft 
        : Alignment.center;
    
    return Container(
      width: columnWidths[index2],
      height: rowHeight,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: UIConfig.tableCellPaddingHorizontal),
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
            width: index2 == widget.data![1][index].length - 1 ? 0 : UIConfig.tableBorderWidth,
          ),
          bottom: BorderSide(
            color: index == widget.data![1]!.length - 1
                ? Colors.transparent
                : Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridLineColor,
            width: index == widget.data![1]!.length - 1 ? 0.00 : UIConfig.tableBorderWidth,
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

  TextStyle? _cachedTextStyle;
  
  TextStyle _getTextStyle(BuildContext context) {
    if (_cachedTextStyle == null) {
      _cachedTextStyle = GoogleFonts.robotoMono(
        fontSize: UIConfig.fontSizeTableMobile,
        height: UIConfig.lineHeight,
        fontWeight: UIConfig.fontWeightNormal,
        letterSpacing: UIConfig.letterSpacing,
        color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
      );
    }
    return _cachedTextStyle!;
  }

  _getNCNormalWidget(int index, int index2, BuildContext context) {
    String? field = widget.data![0][index2].toString();
    final cellValue = widget.data![1][index][index2].toString();
    final textStyle = _getTextStyle(context);
    
    if (field[0] == '%' && widget.devicesTable == true) {
      return Text(
        Utils.lastSeenFromMilliseconds(cellValue).toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    } else if (field[0] == '@' && widget.devicesTable == true) {
      String? lastSeenDate = NudronChartMap.convertDaysToDate(cellValue);
      if (lastSeenDate == '01-Jan-20') {
        lastSeenDate = 'NA';
      }
      return Text(
        lastSeenDate,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    } else {
      return Text(
        cellValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }
  }

  Widget _getAverageRowCell(int colIndex, BuildContext context) {
    if (_averageRow == null || colIndex >= _averageRow!.length) {
      return Container();
    }
    
    final cellValue = _averageRow![colIndex].toString();
    final textStyle = _getTextStyle(context);
    bool isFrozenColumn = colIndex < widget.frozenColumns;
    bool isDesktop = PlatformUtils.isDesktop;
    bool isDevicesPage = widget.location == 'devices' || widget.devicesTable == true;
    Alignment alignment = (isFrozenColumn && isDesktop && isDevicesPage) 
        ? Alignment.centerLeft 
        : Alignment.center;
    
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    return Container(
      width: columnWidths[colIndex],
      height: rowHeight,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: UIConfig.tableCellPaddingHorizontal),
      decoration: BoxDecoration(
        color: theme.dialogBG,
        border: Border(
          right: BorderSide(
            color: theme.gridLineColor,
            width: colIndex == columnWidths.length - 1 ? 0 : UIConfig.tableBorderWidth,
          ),
          top: BorderSide(
            color: theme.gridLineColor,
            width: UIConfig.tableBorderWidth,
          ),
        ),
      ),
      child: Text(
        cellValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    syncScrollControllers(
        _verticalScrollController1, _verticalScrollController2);
    syncScrollControllers(
        _horizontalScrollController1, _horizontalScrollController2);
    // Sync average row horizontal scroll with main horizontal scroll
    syncScrollControllers(
        _horizontalScrollController2, _horizontalScrollControllerAverage);

    if (widget.data == null || widget.data!.isEmpty || widget.data![1].isEmpty) {
      _averageRow = null;
      return Center(
        child: const NoEntries(),
      );
    } else {
      return LayoutBuilder(builder: (context, contraints) {
        init(contraints.maxHeight);
        // Recalculate averages if data changed
        if (_cachedProcessedData == null || 
            _cachedProcessedData!.length != widget.data![1].length) {
          calculateAverages();
        }
        return ScrollConfiguration(
          behavior: NoBounceScrollBehavior(),
          child: GestureDetector(
            onPanUpdate: (details) {
              
              final newOffsetV1 =
                  _verticalScrollController1.offset - details.delta.dy;
              if (_verticalScrollController1.hasClients) {
                _verticalScrollController1.jumpTo(
                  newOffsetV1.clamp(
                    UIConfig.scrollClampMin,
                    _verticalScrollController1.position.maxScrollExtent,
                  ),
                );
              }

              final newOffsetV2 =
                  _verticalScrollController2.offset - details.delta.dy;
              if (_verticalScrollController2.hasClients) {
                _verticalScrollController2.jumpTo(
                  newOffsetV2.clamp(
                    UIConfig.scrollClampMin,
                    _verticalScrollController2.position.maxScrollExtent,
                  ),
                );
              }

              final newOffsetH1 =
                  _horizontalScrollController1.offset - details.delta.dx;
              if (_horizontalScrollController1.hasClients) {
                _horizontalScrollController1.jumpTo(
                  newOffsetH1.clamp(
                    UIConfig.scrollClampMin,
                    _horizontalScrollController1.position.maxScrollExtent,
                  ),
                );
              }

              final newOffsetH2 =
                  _horizontalScrollController2.offset - details.delta.dx;
              if (_horizontalScrollController2.hasClients) {
                _horizontalScrollController2.jumpTo(
                  newOffsetH2.clamp(
                    UIConfig.scrollClampMin,
                    _horizontalScrollController2.position.maxScrollExtent,
                  ),
                );
              }
            },
            child: Stack(
              children: [
                IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        if (widget.frozenColumns > 0)
                          Container(
                            width: columnWidths[0],
                            height: headerRowHeight, // Change from rowHeight to headerRowHeight
                            decoration: BoxDecoration(
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .onSecondaryContainer,
                              border: Border(
                                right: BorderSide(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                  width: UIConfig.tableBorderWidth,
                                ),
                                bottom: BorderSide(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                  width: UIConfig.tableBorderWidth,
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
                                    radius: UIConfig.buttonSplashRadius,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.h, horizontal: 7.w),
                                      
                                      child: Icon(
                                        Icons.download,
                                        size: UIConfig.iconSizeLarge,
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor
                                                .withOpacity(UIConfig.opacityIcon),
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
                                        try {
                                          await ExcelHelper.deleteOldExportFiles();
                                        } catch (e) {
                                          debugPrint('Error deleting old export files: $e');
                                        }
                                        
                                        // Prepare data for export - include average row for billing
                                        var dataToExport = widget.data!;
                                        if (widget.location == 'billing' && _averageRow != null) {
                                          // Create a copy of the data with average row appended
                                          List<dynamic> headers = List.from(dataToExport[0]);
                                          List<List<dynamic>> allRows = List.from(dataToExport[1]);
                                          
                                          // Filter out empty/dummy rows (rows where all cells are empty or null)
                                          List<List<dynamic>> rows = allRows.where((row) {
                                            // Check if row has any non-empty values
                                            return row.any((cell) => 
                                              cell != null && 
                                              cell.toString().trim().isNotEmpty
                                            );
                                          }).toList();
                                          
                                          // Add average row as the last row
                                          rows.add(List.from(_averageRow!));
                                          dataToExport = [headers, rows];
                                        }
                                        
                                        BlocProvider.of<DashboardBloc>(context)
                                            .exportDataToExcel(
                                          dataToExport,
                                          widget.exportToIncludeWholeData,
                                          widget.location,
                                          context,
                                          isDevicesTable: widget.devicesTable ?? false,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: UIConfig.paddingFromLTRBZero,
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
                    
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
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
              // Fixed average row at the bottom
              if (_averageRow != null && widget.location == 'billing')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frozen columns for average row
                      Row(
                        children: List.generate(
                          widget.frozenColumns,
                          (index) => _getAverageRowCell(index, context),
                        ),
                      ),
                      // Scrollable columns for average row
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _horizontalScrollControllerAverage,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              widget.data![0].length - widget.frozenColumns,
                              (index) => _getAverageRowCell(
                                  index + widget.frozenColumns, context),
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
        );
      });
    }
  }
}