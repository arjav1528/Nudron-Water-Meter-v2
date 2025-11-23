import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../main.dart';

import '../../utils/alert_message.dart';
import '../../utils/utils.dart';
import '../../models/chartModels.dart';
import '../api/data_service.dart';

class ExcelHelper {
  static String getActualTitle(String title) {
    return title[0] == '!'
        ? ((title[1] == 'A')
            ? DataPostRequests.getIconNamesForAlerts(int.parse(title[3]))
            : DataPostRequests.getIconNamesForStatus(int.parse(title[3])))
        : title;
  }

  static Future<String?> exportToExcel(
    List<List<dynamic>> sheetsData,
    String exportType,
    BuildContext context, {
    bool isDevicesTable = false,
  }) async {
    try {
      
      var excel = Excel.createExcel();

      String todayDDMMYYYY = DateFormat('ddMMyyyy').format(DateTime.now());
      String timeHHmm = DateFormat('HHmm').format(DateTime.now());
      List<String> identifier =
          BlocProvider.of<DashboardBloc>(context).currentFilters;

      final String fileName;
      switch (exportType) {
        case 'trends':
          fileName = "Water_Trends_${identifier}_$todayDDMMYYYY.xlsx";
          break;
        case 'billing':
          final bloc = BlocProvider.of<DashboardBloc>(context);
          String rangePart;
          DateTime startDate;
          DateTime endDate;
          
          if (bloc.selectedStartDate != null && bloc.selectedEndDate != null) {
            startDate = bloc.selectedStartDate!;
            endDate = bloc.selectedEndDate!;
          } else {
            // Fallback to current month if dates are not set
            final now = DateTime.now();
            startDate = DateTime(now.year, now.month, 1);
            endDate = DateTime(now.year, now.month + 1, 0);
          }
          
          final startStr = DateFormat('ddMMyyyy').format(startDate);
          final endStr = DateFormat('ddMMyyyy').format(endDate);
          rangePart = "${startStr}_$endStr";
          
          fileName = "Water_Summary_${identifier[0]}_$rangePart.xlsx";
          break;
        case 'activity':
        case 'devices':
          fileName = "Water_Meters_${identifier[0]}_${todayDDMMYYYY}_$timeHHmm.xlsx";
          break;
        default:
          fileName = "Water_Export_$todayDDMMYYYY.xlsx";
      }

      for (var sheetInfo in sheetsData) {
        String sheetName = sheetInfo[0]; 
        List<dynamic> data = sheetInfo[1]; 

        Sheet sheetObject = excel[sheetName];

        List<dynamic> columnNames = data[0];
        
        // Process headers: use getActualTitle for ! columns, cleanFieldName for others in devices table
        List<TextCellValue> textColumnNames;
        if (isDevicesTable) {
          textColumnNames = columnNames
              .map((e) {
                String columnName = e.toString();
                // Use getActualTitle for columns starting with ! (like !AI0, !St1)
                if (columnName.isNotEmpty && columnName[0] == '!') {
                  return TextCellValue(getActualTitle(columnName));
                } else {
                  return TextCellValue(Utils.cleanFieldName(columnName));
                }
              })
              .toList();
        } else {
          textColumnNames = columnNames
              .map((e) => TextCellValue(getActualTitle(e.toString())))
              .toList();
        }
        sheetObject.insertRowIterables(textColumnNames, 0);

        List<dynamic> rows = data[1];
        for (int i = 0; i < rows.length; i++) {
          List<CellValue> row = [];
          for (int j = 0; j < rows[i].length; j++) {
            var cellValue = rows[i][j];
            
            // Process cell value for devices table
            if (isDevicesTable && columnNames.length > j) {
              String fieldName = columnNames[j].toString();
              
              // Process fields starting with '%' (Last Seen)
              if (fieldName.isNotEmpty && fieldName[0] == '%') {
                String processedValue = Utils.lastSeenFromMilliseconds(cellValue).toString();
                row.add(TextCellValue(processedValue));
              }
              // Process fields starting with '@' (Last Record)
              else if (fieldName.isNotEmpty && fieldName[0] == '@') {
                String lastSeenDate = NudronChartMap.convertDaysToDate(cellValue.toString());
                if (lastSeenDate == '01-Jan-20') {
                  lastSeenDate = 'NA';
                }
                row.add(TextCellValue(lastSeenDate));
              }
              // Regular cell value
              else {
                row.add((cellValue is num
                    ? DoubleCellValue(cellValue.toDouble())
                    : TextCellValue(cellValue.toString())));
              }
            } else {
              // Regular processing for non-devices table
              row.add((cellValue is num
                  ? DoubleCellValue(cellValue.toDouble())
                  : TextCellValue(cellValue.toString())));
            }
          }
          sheetObject.insertRowIterables(row, i + 1);
        }

        for (var i = 0; i < columnNames.length; i++) {
          var cell = sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.cellStyle = CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
          );
          sheetObject.setColumnAutoFit(i);
        }

        for (var i = 1; i <= rows.length; i++) {
          // Check if this is the average row (last row with "Average" in first cell for billing)
          bool isAverageRow = (exportType == 'billing' && 
                               i == rows.length && 
                               rows.length > 0 &&
                               rows[i - 1].isNotEmpty &&
                               rows[i - 1][0].toString().trim() == "Average");
          
          for (var j = 0; j < rows[0].length; j++) {
            var cell = sheetObject
                .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
              //TODO : Change the bold for the average row
              bold: isAverageRow,
              
            );
          }
        }
      }

      excel.delete('Sheet1');

      var fileBytes = excel.save();
      if (fileBytes != null) {
        
        if (Platform.isAndroid || Platform.isIOS) {
          try {
            await Permission.storage.request();
          } catch (e) {
            
          }
        }

        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw UnsupportedError("Unsupported platform");
        }

        if (directory == null) return null;

        String filePath = "${directory.path}/$fileName";
        File file = File(filePath);

        await file.create(recursive: true);
        await file.writeAsBytes(fileBytes);

        await OpenFile.open(filePath, linuxByProcess: true);

        return filePath;
      }
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(
        mainNavigatorKey.currentContext!,
        "Export failed: ${e.toString()}",
        AlertType.error,
      );
    }
    return null;
  }
  static Future<void> deleteOldExportFiles() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
    if (directory != null) {
      var files = directory.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith(".xlsx")) {
          await file.delete();
        }
      }
    }
  }
}