import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../bloc/dashboard_state.dart';
import '../../utils/pok.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/dialog_header.dart';
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
                    width: 12.minSp,
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
                          fontSize: ThemeNotifier.small.minSp,
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
                      size: 30.minSp,
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
    try {
      // Ensure dates are within valid range
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
      final barrierColor = Provider.of<ThemeNotifier>(context, listen: false).currentTheme.dialogBG;

      final DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: currentTheme.dialogBG,
            elevation: 0,
            child: Container(
              height: 530.h,
              decoration: BoxDecoration(
                color: currentTheme.dialogBG, // Match BillingFormula dialog BG
                border: Border.all(
                  color: currentTheme.gridLineColor, // Match BillingFormula border color
                  width: 3.minSp, // Match BillingFormula border width
                ),
                // Remove or comment out the boxShadow if you want it to look exactly like BillingFormula
                // boxShadow: [
                //   BoxShadow(
                //     color: currentTheme.profileBorderColor,
                //     blurRadius: 10.r,
                //     offset: Offset(0, 4.h),
                //   ),
                // ],
              ),
              child: Column(
                children: [
                  // Custom Header
                  Container(
                    // color: Colors.green,
                    child: Row(
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
                  ),

                  // Date Picker Content
                  Container(
                    width: 310.w,
                    height: 350.h,
                    
                    child: RangeDatePicker(
                      minDate: minDate,
                      maxDate: maxDate,
                      initialDate: validStartDate ?? maxDate,
                      selectedRange: selectedRange,
                      centerLeadingDate: true,
                  
                      // Styling
                      currentDateDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: CommonColors.green,
                          width: 2,
                        ),
                          borderRadius: BorderRadius.circular(100.r)
                      ),
                      currentDateTextStyle: TextStyle(
                        color: CommonColors.green,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                  
                      ),
                  
                      enabledCellsDecoration: BoxDecoration(
                        color: Colors.transparent,
                          // shape: BoxShape.circle
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      enabledCellsTextStyle: TextStyle(
                        color: currentTheme.basicAdvanceTextColor,
                        fontSize: 14.sp,
                      ),
                  
                      selectedCellsDecoration: BoxDecoration(
                        color: CommonColors.green.withOpacity(0.15),
                        // borderRadius: BorderRadius.circular(20.r),
                      ),
                      selectedCellsTextStyle: TextStyle(
                        color: currentTheme.basicAdvanceTextColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  
                      singleSelectedCellDecoration: BoxDecoration(
                        color: CommonColors.green,
                          // shape: BoxShape.circle
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      singleSelectedCellTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                  
                      daysOfTheWeekTextStyle: TextStyle(
                        color: currentTheme.gridHeadingColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  
                      disabledCellsTextStyle: TextStyle(
                        color: currentTheme.noEntriesColor,
                        fontSize: 14.sp,
                      ),
                  
                      leadingDateTextStyle: GoogleFonts.robotoMono(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: currentTheme.basicAdvanceTextColor,
                      ),
                  
                      slidersColor: CommonColors.green,
                      splashColor: CommonColors.green.withOpacity(0.1),
                      highlightColor: CommonColors.green.withOpacity(0.2),
                  
                      onRangeSelected: (DateTimeRange? range) {
                        if (range != null) {
                          Navigator.of(context).pop(range);
                        }
                      },
                    ),
                  ),

                  // Tip Text
                  Container(
                    width: 290.w,
                    child: Text(
                      'Tip: You can select a range by tapping the start and end dates.',
                      style: TextStyle(
                        color: currentTheme.gridHeadingColor,
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                    width: 280.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: 'CANCEL',
                          isEnabled: true,
                          isRed: true,
                          onPressed: () {
                            // Get the currently selected range from the picker
                            Navigator.of(context).pop(selectedRange);
                          },
                          fontSize: ThemeNotifier.medium.minSp,
                          dynamicWidth: true,
                        ),
                        CustomButton(
                          text: 'CONFIRM',
                          isEnabled: true,
                          isRed: false,
                          onPressed: () {
                            // Get the currently selected range from the picker
                            Navigator.of(context).pop(selectedRange);
                          },
                          fontSize: ThemeNotifier.medium.minSp,
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

      if (pickedRange != null) {
        setState(() {
          startDate = pickedRange.start;
          endDate = pickedRange.end;
        });

        // Apply the date range
        await _applyDateRange();
      }
    } catch (e) {
      print('Error in date range picker: $e');
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

    return DateTimeRange(start: validStart, end: validEnd);
  }
}