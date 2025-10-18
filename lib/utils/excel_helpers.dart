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
    BuildContext context,
  ) async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();

      // Get today's date in required formats
      String todayDDMMYYYY = DateFormat('ddMMyyyy').format(DateTime.now());
      String todayMMM = DateFormat('MMM').format(DateTime.now());
      List<String> identifier =
          BlocProvider.of<DashboardBloc>(context).currentFilters;

      // Generate filename based on export type
      final String fileName;
      switch (exportType) {
        case 'trends':
          fileName = "Water_Trends_${identifier}_$todayDDMMYYYY.xlsx";
          break;
        case 'billing':
          final bloc = BlocProvider.of<DashboardBloc>(context);
          String rangePart;
          if (bloc.selectedStartDate != null && bloc.selectedEndDate != null) {
            final startStr = DateFormat('ddMMyyyy').format(bloc.selectedStartDate!);
            final endStr = DateFormat('ddMMyyyy').format(bloc.selectedEndDate!);
            rangePart = "${startStr}_${endStr}";
            // Replace slashes to avoid invalid filename characters on some OS
            rangePart = "${startStr.replaceAll('/', '-')}_${endStr.replaceAll('/', '-')}";
          } else {
            rangePart = todayMMM;
          }
          fileName = "Water_Summary_${identifier[0]}_${rangePart}.xlsx";
          break;
        case 'activity':
          fileName = "Water_Meters_${identifier[0]}_$todayDDMMYYYY.xlsx";
          break;
        default:
          fileName = "Water_Export_$todayDDMMYYYY.xlsx";
      }

      // Loop over each sheet's data
      for (var sheetInfo in sheetsData) {
        String sheetName = sheetInfo[0]; // First element is the sheet name
        List<dynamic> data = sheetInfo[1]; // Second element is the data

        // Create or get the sheet
        Sheet sheetObject = excel[sheetName];

        // Add column names (first row) and apply formatting
        List<dynamic> columnNames = data[0];
        List<TextCellValue> textColumnNames = columnNames
            .map((e) => TextCellValue(getActualTitle(e.toString())))
            .toList();
        sheetObject.insertRowIterables(textColumnNames, 0);

        // Add rows of data (subsequent rows)
        List<dynamic> rows = data[1];
        for (int i = 0; i < rows.length; i++) {
          List<CellValue> row = [];
          for (int j = 0; j < rows[i].length; j++) {
            var cellValue = rows[i][j];
            row.add((cellValue is num
                ? DoubleCellValue(cellValue.toDouble())
                : TextCellValue(cellValue.toString())));
          }
          sheetObject.insertRowIterables(row, i + 1);
        }

        // Apply formatting to the title row
        for (var i = 0; i < columnNames.length; i++) {
          var cell = sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.cellStyle = CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
          );
          sheetObject.setColumnAutoFit(i);
        }

        // Apply formatting to data rows
        for (var i = 1; i <= rows.length; i++) {
          for (var j = 0; j < rows[0].length; j++) {
            var cell = sheetObject
                .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
            );
          }
        }
      }

      // Delete the default empty sheet
      excel.delete('Sheet1');

      // Save the file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        // Request storage permission only for mobile platforms
        if (Platform.isAndroid || Platform.isIOS) {
          try {
            await Permission.storage.request();
          } catch (e) {
            print("Permission request failed (this is expected on some platforms): $e");
            // Continue with file operations even if permission request fails
          }
        }

        // Get directory path based on platform
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          // For desktop platforms, use application documents directory
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw UnsupportedError("Unsupported platform");
        }

        if (directory == null) return null;

        // Define file path
        String filePath = "${directory.path}/$fileName";
        File file = File(filePath);

        // Write data to file
        await file.create(recursive: true);
        await file.writeAsBytes(fileBytes);

        // Open the file
        await OpenFile.open(filePath, linuxByProcess: true);

        return filePath;
      }
    } catch (e, stack) {
      print("Error exporting Excel file: $e\n$stack");
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
      // For desktop platforms, use application documents directory
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
    if (directory != null) {
      var files = directory.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith(".xlsx")) {
          await file.delete();
          print("Deleted old file: ${file.path}");
        }
      }
    }
  }
}