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
  final double headerRowHeight = UIConfig.headerWidgetHeight; 

  /// Calculates the pure width of the text without padding.
  double calculateTextWidth(String text, {bool isHeader = false}) {
    final cacheKey = '${text}_$isHeader';
    
    if (_textWidthCache.containsKey(cacheKey)) {
      return _textWidthCache[cacheKey]!;
    }
    
    final textStyle = isHeader
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
          );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: Utils.cleanFieldName(text),
        style: textStyle,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0);
    
    // Add a small buffer for subpixel rendering safety
    final width = textPainter.width + 4.w;
    
    _textWidthCache[cacheKey] = width;
    return width;
  }

  num dummyRows = 0;

  void init(double height) {
    bool needsRecalculation = _cachedProcessedData == null || 
        _cachedProcessedData!.length != widget.data![1].length ||
        columnWidths.isEmpty ||
        (widget.data != null && widget.data!.isNotEmpty && 
         columnWidths.length != widget.data![0].length);
    
    if (needsRecalculation) {
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

    for (int colIndex = 2; colIndex < headers.length; colIndex++) {
      if (colIndex < widget.frozenColumns) {
        // Skip frozen columns for average calc (except first 2 which are handled above conceptually)
      } else {
        double sum = 0.0;
        int count = 0;
        
        for (var row in rows) {
          if (row is List && colIndex < row.length && row[colIndex] != null) {
            try {
              String valueStr = row[colIndex].toString().trim();
              if (valueStr.isNotEmpty) {
                double? value = double.tryParse(valueStr);
                if (value != null) {
                  sum += value;
                  count++;
                }
              }
            } catch (e) {
              // ignore error
            }
          }
        }
        
        if (count > 0) {
          double avg = sum / count;
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
      
      // Padding to apply to all columns (Left + Right)
      final double paddingHorizontal = UIConfig.tableCellPaddingHorizontal;
      final double totalPadding = paddingHorizontal * 2;

      for (int index = 0; index < headers.length; index++) {
        // 1. Calculate Header Width
        double headerWidth = calculateTextWidth(headers[index].toString(), isHeader: true);
        
        // Add space for download button in the first column
        if (index == 0) {
          headerWidth += UIConfig.iconSizeLarge + 10.w; // Icon size + spacing
        }
        
        // 2. Calculate Max Data Width
        double maxDataWidth = 0.0;
        bool shouldCheckAllRows = (widget.devicesTable == true && index == 0);
        
        String? fieldName = headers[index].toString();
        bool isLastSeenColumn = widget.devicesTable == true && 
            fieldName.isNotEmpty && fieldName[0] == '%';
        bool isLastRecordColumn = widget.devicesTable == true && 
            fieldName.isNotEmpty && fieldName[0] == '@';
        
        // Determine sampling strategy
        if (rows.length > 1000 && !shouldCheckAllRows) {
          final sampleSize = min<int>(100, rows.length);
          final step = (rows.length ~/ sampleSize) as int;
          
          for (int i = 0; i < rows.length; i += step) {
            if (rows[i][index] != null) {
              String cellValue = _getCellValueAsString(rows[i][index], isLastSeenColumn, isLastRecordColumn);
              double cellWidth = calculateTextWidth(cellValue);
              if (cellWidth > maxDataWidth) {
                maxDataWidth = cellWidth;
              }
            }
          }
        } else {
          for (var row in rows) {
            if (row[index] != null) {
              String cellValue = _getCellValueAsString(row[index], isLastSeenColumn, isLastRecordColumn);
              double cellWidth = calculateTextWidth(cellValue);
              if (cellWidth > maxDataWidth) {
                maxDataWidth = cellWidth;
              }
            }
          }
        }
        
        // 3. Determine Final Column Width based on Rules
        bool isFrozenColumn = index < widget.frozenColumns;
        bool isMobile = PlatformUtils.isMobile;
        
        if (isMobile) {
          if (isFrozenColumn) {
            // Phone + Frozen: Width of Header + Padding
            double frozenWidth = headerWidth + totalPadding;
            
            // Check for specific overrides (e.g. extra space needed)
            if (widget.columnsToTakeHeaderWidthAndExtraPadding.containsKey(index)) {
              frozenWidth += widget.columnsToTakeHeaderWidthAndExtraPadding[index]!.toDouble().w;
            }
            columnWidths[index] = frozenWidth;
          } else {
            // Phone + Unfrozen: Max(Header, Data) + Padding
            columnWidths[index] = max(headerWidth, maxDataWidth) + totalPadding;
          }
        } else {
          // Desktop: Max of all texts (Header vs Data) + Padding
          columnWidths[index] = max(headerWidth, maxDataWidth) + totalPadding;
        }
      }
    }
  }

  String _getCellValueAsString(dynamic rawValue, bool isLastSeen, bool isLastRecord) {
    if (isLastSeen) {
      return Utils.lastSeenFromMilliseconds(rawValue).toString();
    } else if (isLastRecord) {
      String? lastSeenDate = NudronChartMap.convertDaysToDate(rawValue.toString());
      return (lastSeenDate == '01-Jan-20') ? 'NA' : lastSeenDate;
    } else {
      return rawValue.toString();
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

  Widget _buildCellContainer({
    required int index, // Row index (or -1 for header)
    required int colIndex, // Column index
    required BuildContext context,
    required Widget child,
    required bool isHeader,
    Color? backgroundColor,
  }) {
    // Uniform padding logic
    // For headers, HeaderWidget already adds padding, so we don't add it here to avoid double padding.
    final padding = isHeader 
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: UIConfig.tableCellPaddingHorizontal,
          );

    // Alignment - Left aligned for frozen columns on desktop, centered otherwise
    bool isFrozenColumn = colIndex < widget.frozenColumns;
    bool isDesktop = PlatformUtils.isDesktop;
    Alignment alignment = (isFrozenColumn && isDesktop) 
        ? Alignment.centerLeft 
        : Alignment.center;

    // Decoration
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final borderColor = theme.gridLineColor;
    
    final double rightBorderWidth = colIndex == columnWidths.length - 1 ? 0 : UIConfig.tableBorderWidth;
    final double bottomBorderWidth = (index == widget.data![1].length - 1 && !isHeader) ? 0.00 : UIConfig.tableBorderWidth;

    BoxDecoration decoration;
    if (isHeader) {
      decoration = BoxDecoration(
        color: theme.onSecondaryContainer,
        border: Border(
          right: BorderSide(color: borderColor, width: rightBorderWidth),
          bottom: BorderSide(color: borderColor, width: UIConfig.tableBorderWidth),
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: backgroundColor ?? (index % 2 == 1 ? theme.onSecondaryContainer : theme.primaryContainer),
        border: Border(
          right: BorderSide(color: borderColor, width: rightBorderWidth),
          bottom: BorderSide(
              color: (index == widget.data![1].length - 1) ? Colors.transparent : borderColor, 
              width: bottomBorderWidth
          ),
        ),
      );
    }

    return Container(
      width: columnWidths[colIndex],
      height: isHeader ? headerRowHeight : rowHeight,
      alignment: alignment,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  Widget _getHeaderWidget(int index, BuildContext context) {
    return _buildCellContainer(
      index: -1, // Header
      colIndex: index,
      context: context,
      isHeader: true,
      child: HeaderWidget(
        title: Utils.cleanFieldName(widget.data![0][index].toString()),
      ),
    );
  }

  Widget _getNormalWidget(int index, int index2, BuildContext context) {
    return _buildCellContainer(
      index: index,
      colIndex: index2,
      context: context,
      isHeader: false,
      child: widget.columnsToTakeHeaderWidthAndExtraPadding.containsKey(index2)
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _getNCNormalWidget(index, index2, context))
          : _getNCNormalWidget(index, index2, context),
    );
  }
  
  Widget _getAverageRowCell(int colIndex, BuildContext context) {
    if (_averageRow == null || colIndex >= _averageRow!.length) {
      return Container();
    }
    
    final cellValue = _averageRow![colIndex].toString();
    final textStyle = _getTextStyle(context).copyWith(fontWeight: FontWeight.bold);
    
    // Manually use _buildCellContainer logic but slightly customized for Footer look if needed
    // For now using same consistent logic but with specific footer bg
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    
    return _buildCellContainer(
      index: widget.data![1].length, // Treating as next row
      colIndex: colIndex,
      context: context,
      isHeader: false,
      backgroundColor: Provider.of<ThemeNotifier>(context).isDark ? theme.dialogBG : Colors.white,
      child: Text(
        cellValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }

  TextStyle? _cachedTextStyle;
  
  TextStyle _getTextStyle(BuildContext context) {
    _cachedTextStyle ??= GoogleFonts.robotoMono(
        fontSize: UIConfig.fontSizeTableMobile,
        height: UIConfig.lineHeight,
        fontWeight: UIConfig.fontWeightNormal,
        letterSpacing: UIConfig.letterSpacing,
        color: Provider.of<ThemeNotifier>(context).currentTheme.tableText,
      );
    return _cachedTextStyle!;
  }

  Widget _getNCNormalWidget(int index, int index2, BuildContext context) {
    String? field = widget.data![0][index2].toString();
    final cellValue = widget.data![1][index][index2].toString();
    final textStyle = _getTextStyle(context);
    
    String displayText;
    if (field[0] == '%' && widget.devicesTable == true) {
      displayText = Utils.lastSeenFromMilliseconds(cellValue).toString();
    } else if (field[0] == '@' && widget.devicesTable == true) {
      String? lastSeenDate = NudronChartMap.convertDaysToDate(cellValue);
      displayText = (lastSeenDate == '01-Jan-20') ? 'NA' : lastSeenDate;
    } else {
      displayText = cellValue;
    }
    
    return Text(
      displayText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncScrollControllers(
        _verticalScrollController1, _verticalScrollController2);
    syncScrollControllers(
        _horizontalScrollController1, _horizontalScrollController2);
    
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
        
        if (_cachedProcessedData == null || 
            _cachedProcessedData!.length != widget.data![1].length) {
          calculateAverages();
        }
        return ScrollConfiguration(
          behavior: NoBounceScrollBehavior(),
          child: GestureDetector(
            onPanUpdate: (details) {
              // Scroll sync logic
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
                    
                    // Header Row
                    Row(
                      children: [
                        // Frozen Headers
                        if (widget.frozenColumns > 0)
                          Container(
                            width: columnWidths[0],
                            height: headerRowHeight, 
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
                                // Download Button (Fixed padding logic approx 5.w)
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
                                          horizontal: 5.w),
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
                                        }
                                        
                                        var dataToExport = widget.data!;
                                        if (widget.location == 'billing' && _averageRow != null) {
                                          List<dynamic> headers = List.from(dataToExport[0]);
                                          List<List<dynamic>> allRows = List.from(dataToExport[1]);
                                          
                                          List<List<dynamic>> rows = allRows.where((row) {
                                            return row.any((cell) => 
                                              cell != null && 
                                              cell.toString().trim().isNotEmpty
                                            );
                                          }).toList();
                                          
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
                                // Header Text
                                Expanded(
                                  child: Container(
                                    alignment: (PlatformUtils.isDesktop && widget.frozenColumns > 0)
                                        ? Alignment.centerLeft
                                        : Alignment.center,
                                    padding: EdgeInsets.zero,
                                    child: HeaderWidget(
                                      title: Utils.cleanFieldName(
                                          widget.data![0][0].toString()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Remaining Frozen Headers
                        Row(
                          children: List.generate(
                            widget.frozenColumns - 1,
                            (index) => _getHeaderWidget(index + 1, context),
                          ),
                        ),
                        
                        // Unfrozen Headers
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
                    
                    // Data Rows
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Frozen Columns Data
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
                          
                          // Unfrozen Columns Data
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
              
              // Footer (Average Row)
              if (_averageRow != null && widget.location == 'billing')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          widget.frozenColumns,
                          (index) => _getAverageRowCell(index, context),
                        ),
                      ),
                      
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
