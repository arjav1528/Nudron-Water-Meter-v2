import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../bloc/dashboard_state.dart';
import '../../utils/pok.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';

class CustomDateRangePicker extends StatefulWidget {
  const CustomDateRangePicker({super.key});

  @override
  _CustomDateRangePickerState createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTime? startDate;
  DateTime? endDate;
  bool isDialogOpen = false; // Add this line

  @override
  void initState() {
    super.initState();
    // Set default date range to current month, ensuring it's within valid range
    super.initState();
    // Initialize with bloc's selected dates if available, otherwise use current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithBlocDates();
    });
  }

  void _syncWithBlocDates() {
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
    
    if (dashboardBloc.selectedStartDate != null && dashboardBloc.selectedEndDate != null) {
      // Use the bloc's selected dates
      setState(() {
        startDate = dashboardBloc.selectedStartDate;
        endDate = dashboardBloc.selectedEndDate;
      });
    } else {
      // Fallback to current month if bloc dates are not set
      final now = DateTime.now();
      final minDate = DateTime(2020, 1, 1);
      final maxDate = DateTime(now.year, now.month, now.day);

      // Default to current month, but ensure it's within bounds
      DateTime defaultStart = DateTime(now.year, now.month, 1);
      DateTime defaultEnd = DateTime(now.year, now.month + 1, 0);

      // Adjust if default dates are out of bounds
      if (defaultStart.isBefore(minDate)) {
        defaultStart = minDate;
      }
      if (defaultEnd.isAfter(maxDate)) {
        defaultEnd = maxDate;
      }

      setState(() {
        startDate = defaultStart;
        endDate = defaultEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
        if (dashboardBloc.selectedStartDate != null && dashboardBloc.selectedEndDate != null) {
          // Only update if the dates are different to avoid unnecessary rebuilds
          if (startDate != dashboardBloc.selectedStartDate || endDate != dashboardBloc.selectedEndDate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  startDate = dashboardBloc.selectedStartDate;
                  endDate = dashboardBloc.selectedEndDate;
                });
              }
            });
          }
        }
        return Material(
          color: Colors.transparent,
          child: Ink(
            color: Provider.of<ThemeNotifier>(context).currentTheme.dropDownColor,
            child: InkWell(
            onTap: () async {
              setState(() {
                isDialogOpen = true;
              });
              await _showDateRangePicker();
              if (mounted) {
                setState(() {
                  isDialogOpen = false;
                });
              }
            },
            splashFactory: InkRipple.splashFactory,
            splashColor: Provider.of<ThemeNotifier>(context, listen: false)
                .currentTheme
                .splashColor,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: CommonColors.green,
                    width: 12.responsiveSp,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        startDate != null && endDate != null
                            ? "${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}"
                            : "Select Month Range",
                        style: GoogleFonts.robotoMono(
                          fontSize: ThemeNotifier.small.responsiveSp,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: isDialogOpen
                          ? CommonColors.green
                          : Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                      size: 30.responsiveSp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  });
  }

  Future<void> _showDateRangePicker() async {
    
      // Ensure dates are within valid range

    try{
      final now = DateTime.now();
      final minDate = DateTime(2020, 1, 1);
      final maxDate = DateTime(now.year, now.month, now.day);

      // Validate and adjust current dates if needed
      DateTime? validStartDate = startDate;
      DateTime? validEndDate = endDate;

      if (validStartDate != null && validStartDate.isBefore(minDate)) {
        validStartDate = minDate;
      }
      if (validStartDate != null && validStartDate.isAfter(maxDate)) {
        validStartDate = maxDate;
      }

      if (validEndDate != null && validEndDate.isBefore(minDate)) {
        validEndDate = minDate;
      }
      if (validEndDate != null && validEndDate.isAfter(maxDate)) {
        validEndDate = maxDate;
      }

      // Ensure end date is not before start date
      if (validStartDate != null && validEndDate != null && validEndDate.isBefore(validStartDate)) {
        validEndDate = validStartDate;
      }

      // Only set selectedRange if both dates are valid and within bounds
      DateTimeRange? selectedRange;
      if (validStartDate != null && validEndDate != null) {
        // Double-check that dates are within bounds
        if (validStartDate.isAfter(minDate) || validStartDate.isAtSameMomentAs(minDate)) {
          if (validStartDate.isBefore(maxDate) || validStartDate.isAtSameMomentAs(maxDate)) {
            if (validEndDate.isAfter(minDate) || validEndDate.isAtSameMomentAs(minDate)) {
              if (validEndDate.isBefore(maxDate) || validEndDate.isAtSameMomentAs(maxDate)) {
                selectedRange = DateTimeRange(start: validStartDate, end: validEndDate);
              }
            }
          }
        }
      }

      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      final currentTheme = themeNotifier.currentTheme;

      // Store the currently selected range in the dialog
      DateTimeRange? currentSelectedRange = selectedRange;

      final DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
        context: context,
        builder: (BuildContext context) {
          // Store visibleMonth in a variable that persists across rebuilds
          DateTime? _storedVisibleMonth;
          
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Initialize if not set, otherwise use stored value
              _storedVisibleMonth ??= DateTime(
                (currentSelectedRange?.start ?? validStartDate ?? maxDate).year,
                (currentSelectedRange?.start ?? validStartDate ?? maxDate).month,
                1,
              );
              
              // Always use the current stored value (which may have been updated by buttons)
              DateTime visibleMonth = _storedVisibleMonth!;
              
              return Dialog(
                backgroundColor: currentTheme.dialogBG,
                elevation: 0,
                  child: Container(
                    width: 380.w,
                  height: 600.h,
                  decoration: BoxDecoration(
                    color: currentTheme.dialogBG,
                    border: Border.all(
                      color: currentTheme.gridLineColor,
                      width: 3.responsiveSp,
                    ),
                  ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Custom Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChamferedTextWidgetInverted(
                            text: "SELECT MONTH RANGE",
                            borderColor: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .gridLineColor,
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .gridLineColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),

                      // Date Picker Content
                      StatefulBuilder(
                        builder: (context, setLocal) {
                          // visibleMonth is from outer scope and will be updated when outer state rebuilds

                          List<String> dow = ['SUN','MON','TUE','WED','THU','FRI','SAT'];
                          TextStyle dowStyle = TextStyle(
                            color: currentTheme.gridHeadingColor,
                            fontSize: 12.responsiveSp,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                          );

                          Widget buildDayCell(DateTime day) {
                            bool isToday = DateTime.now().year == day.year && DateTime.now().month == day.month && DateTime.now().day == day.day;
                            bool inCurrentMonth = day.month == visibleMonth.month && day.year == visibleMonth.year;
                            bool isDisabled = day.isBefore(minDate) || day.isAfter(maxDate) || !inCurrentMonth;

                            DateTimeRange? r = currentSelectedRange;
                            bool isStart = r != null && day.isAtSameMomentAs(DateTime(r.start.year, r.start.month, r.start.day));
                            bool isEnd = r != null && day.isAtSameMomentAs(DateTime(r.end.year, r.end.month, r.end.day));
                            bool inRange = r != null && !isStart && !isEnd && (day.isAfter(r.start) && day.isBefore(r.end));

                            Color textColor = isDisabled
                                ? currentTheme.noEntriesColor
                                : currentTheme.basicAdvanceTextColor;

                            BoxDecoration? deco;
                            TextStyle textStyle = TextStyle(
                              color: textColor,
                              fontSize: 14.responsiveSp,
                              fontFamily: GoogleFonts.robotoMono().fontFamily,
                              fontWeight: FontWeight.w500,
                            );

                            if (inRange) {
                              deco = BoxDecoration(color: CommonColors.green.withOpacity(0.15));
                            }
                            if (isStart || isEnd) {
                              deco = BoxDecoration(
                                color: CommonColors.green,
                                borderRadius: BorderRadius.circular(100.r),
                              );
                              textStyle = textStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600);
                            } else if (isToday) {
                              deco = BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: CommonColors.green, width: 2),
                                borderRadius: BorderRadius.circular(100.r),
                              );
                              textStyle = textStyle.copyWith(color: CommonColors.green);
                            }

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isDisabled ? null : () {
                                  DateTime tapped = DateTime(day.year, day.month, day.day);
                                  if (currentSelectedRange == null) {
                                    currentSelectedRange = DateTimeRange(start: tapped, end: tapped);
                                  } else {
                                    final s = DateTime(currentSelectedRange!.start.year, currentSelectedRange!.start.month, currentSelectedRange!.start.day);
                                    final e = DateTime(currentSelectedRange!.end.year, currentSelectedRange!.end.month, currentSelectedRange!.end.day);
                                    if (s == e) {
                                      if (tapped.isBefore(s)) {
                                        currentSelectedRange = DateTimeRange(start: tapped, end: s);
                                      } else {
                                        currentSelectedRange = DateTimeRange(start: s, end: tapped);
                                      }
                                    } else {
                                      currentSelectedRange = DateTimeRange(start: tapped, end: tapped);
                                    }
                                  }

                                  // Enforce 92-day cap
                                  final rr = currentSelectedRange!;
                                  final d = rr.end.difference(rr.start).inDays + 1;
                                  if (d > 92) {
                                    currentSelectedRange = DateTimeRange(start: rr.start, end: rr.start.add(Duration(days: 91)));
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text('Maximum date range is 92 days. Selected range adjusted.'),
                                    //     backgroundColor: Colors.red,
                                    //     duration: Duration(seconds: 2),
                                    //   ),
                                    // );
                                    CustomAlert.showCustomScaffoldMessenger(
                                        context, "Maximum date range is 92 days. Selected range adjusted.", AlertType.error);
                                  }

                                  // Update dialog preview immediately
                                  setDialogState(() {});
                                  
                                  // Update bloc instantly with the new range
                                  final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
                                  // Update bloc dates immediately
                                  dashboardBloc.selectedStartDate = currentSelectedRange!.start;
                                  dashboardBloc.selectedEndDate = currentSelectedRange!.end;
                                  
                                  // Load data for the new range
                                  final normalized = DateTimeRange(
                                    start: currentSelectedRange!.start,
                                    end: currentSelectedRange!.end,
                                  );
                                  // ignore: unawaited_futures
                                  dashboardBloc.selectDateRange(normalized.start, normalized.end);
                                },
                                splashColor: CommonColors.green.withOpacity(0.1),
                                highlightColor: CommonColors.green.withOpacity(0.2),
                                child: Container(
                                  decoration: deco,
                                  alignment: Alignment.center,
                                  child: Text('${day.day}', style: textStyle),
                                ),
                              ),
                            );
                          }

                          // Build a 7x6 grid for the month
                          DateTime firstOfMonth = visibleMonth;
                          int weekdayOffset = firstOfMonth.weekday % 7; // Sunday=0
                          // int daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day; // not needed explicitly
                          List<Widget> rows = [];

                          // Header with arrows and month
                          rows.add(
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left, color: CommonColors.green),
                                    onPressed: () {
                                      _storedVisibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1, 1);
                                      setDialogState(() {});
                                    },
                                  ),
                                  Text(
                                    DateFormat('MMMM yyyy').format(visibleMonth),
                                    style: GoogleFonts.robotoMono(
                            fontSize: 18.responsiveSp,
                            fontWeight: FontWeight.w600,
                            color: currentTheme.basicAdvanceTextColor,
                          ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right, color: CommonColors.green),
                                    onPressed: () {
                                      _storedVisibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 1);
                                      setDialogState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );

                          // Days of week row
                          rows.add(
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: dow
                                    .map((d) => Expanded(
                                          child: Center(child: Text(d, style: dowStyle)),
                                        ))
                                    .toList(),
                              ),
                            ),
                          );

                          // Grid
                          List<Widget> gridChildren = [];
                          int totalCells = 42; // 6 weeks
                          for (int i = 0; i < totalCells; i++) {
                            int dayNum = i - weekdayOffset + 1;
                            DateTime cellDate = DateTime(visibleMonth.year, visibleMonth.month, dayNum);
                            gridChildren.add(Expanded(child: SizedBox(height: 38.h, child: buildDayCell(cellDate))));
                          }
                          for (int r = 0; r < 6; r++) {
                            rows.add(Row(children: gridChildren.sublist(r * 7, (r + 1) * 7)));
                          }

                          return SizedBox(
                            width: 320.w,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: rows,
                            ),
                          );
                        },
                      ),

                      // Selected Date Range Display
                      Container(
                        width: 300.w,
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: currentTheme.dropDownColor,
                          border: Border.all(
                            color: currentTheme.gridLineColor,
                            width: 1.responsiveSp,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          currentSelectedRange != null
                              ? (currentSelectedRange!.start == currentSelectedRange!.end
                                  ? '${DateFormat('MMM dd, yyyy').format(currentSelectedRange!.start)}'
                                  : '${DateFormat('MMM dd').format(currentSelectedRange!.start)} - ${DateFormat('MMM dd, yyyy').format(currentSelectedRange!.end)}')
                              : 'No date range selected',
                          style: TextStyle(
                            color: currentSelectedRange != null 
                                ? CommonColors.green 
                                : currentTheme.noEntriesColor,
                            fontSize: 13.responsiveSp,
                            fontWeight: FontWeight.w600,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Tip Text
                      Container(
                        width: 300.w,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          'Tip: Select start and end dates. Max range: 92 days.',
                          style: TextStyle(
                            color: currentTheme.gridHeadingColor,
                            fontSize: 12.responsiveSp,
                            fontStyle: FontStyle.italic,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: EdgeInsets.only(top: 10.h, bottom: 15.h),
                        width: 300.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'CANCEL',
                              isEnabled: true,
                              isRed: true,
                              onPressed: () {
                                // Close dialog without applying changes
                                Navigator.of(context).pop();
                              },
                              fontSize: ThemeNotifier.small.responsiveSp,
                              dynamicWidth: true,
                            ),
                            CustomButton(
                              text: 'CONFIRM',
                              isEnabled: true,
                              isRed: false,
                              onPressed: () {
                                // Return the currently selected range
                                Navigator.of(context).pop(currentSelectedRange);
                              },
                              fontSize: ThemeNotifier.small.responsiveSp,
                              dynamicWidth: true,
                            ),
                          ],
                        ),
                      ),
                      ],
                  ),
                ),
              );

            },
          );
        });
      

      if (pickedRange != null) {
        setState(() {
          startDate = pickedRange.start;
          endDate = pickedRange.end;
        });

        // Apply the date range
        await _applyDateRange();
      }
      
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting date range: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _applyDateRange() async {
    if (startDate != null && endDate != null) {
      // Get validated date range
      final validRange = _getValidDateRange();

      final dashboardBloc = BlocProvider.of<DashboardBloc>(context);

      bool shouldChange = await LoaderUtility.showLoader(
        context,
        dashboardBloc
            .selectDateRange(validRange.start, validRange.end)
            .then((_) => true)
            .catchError((e) {
          CustomAlert.showCustomScaffoldMessenger(
              context, "$e", AlertType.error);
          return false;
        }),
      );

      if (shouldChange) {
        // Update the displayed dates to the validated ones
        setState(() {
          startDate = validRange.start;
          endDate = validRange.end;
        });

        if (mounted) {

        }
      }
    }
  }

  /// Validates and normalizes dates to ensure they're within the valid range
  DateTimeRange _getValidDateRange() {
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    final maxDate = DateTime(now.year, now.month, now.day);

    DateTime validStart = startDate ?? minDate;
    DateTime validEnd = endDate ?? maxDate;

    // Ensure dates are within bounds
    if (validStart.isBefore(minDate)) {
      validStart = minDate;
    }
    if (validStart.isAfter(maxDate)) {
      validStart = maxDate;
    }

    if (validEnd.isBefore(minDate)) {
      validEnd = minDate;
    }
    if (validEnd.isAfter(maxDate)) {
      validEnd = maxDate;
    }

    // Ensure end date is not before start date
    if (validEnd.isBefore(validStart)) {
      validEnd = validStart;
    }

    // Ensure the range doesn't exceed 92 days
    final daysDifference = validEnd.difference(validStart).inDays + 1;
    if (daysDifference > 92) {
      // Adjust the end date to be exactly 92 days from the start date
      validEnd = validStart.add(Duration(days: 91));
    }

    return DateTimeRange(start: validStart, end: validEnd);
  }
}