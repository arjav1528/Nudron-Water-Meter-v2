import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../bloc/dashboard_state.dart';
import '../../utils/pok.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../services/platform_utils.dart';

class CustomDateRangePicker extends StatefulWidget {
  const CustomDateRangePicker({super.key});

  @override
  _CustomDateRangePickerState createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTime? startDate;
  DateTime? endDate;
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    final maxDate = DateTime(now.year, now.month, now.day);

    DateTime defaultStart = DateTime(now.year, now.month, 1);
    DateTime defaultEnd = DateTime(now.year, now.month + 1, 0);

    if (defaultStart.isBefore(minDate)) {
      defaultStart = minDate;
    }
    if (defaultEnd.isAfter(maxDate)) {
      defaultEnd = maxDate;
    }

    startDate = defaultStart;
    endDate = defaultEnd;
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithBlocDates();
    });
  }

  void _syncWithBlocDates() {
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
    
    if (dashboardBloc.selectedStartDate != null && dashboardBloc.selectedEndDate != null) {
      
      if (startDate != dashboardBloc.selectedStartDate || endDate != dashboardBloc.selectedEndDate) {
        setState(() {
          startDate = dashboardBloc.selectedStartDate;
          endDate = dashboardBloc.selectedEndDate;
        });
      }
    } else {
      
      dashboardBloc.selectedStartDate = startDate;
      dashboardBloc.selectedEndDate = endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
        if (dashboardBloc.selectedStartDate != null && dashboardBloc.selectedEndDate != null) {
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
        } else if (startDate != null && endDate != null) {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (dashboardBloc.selectedStartDate == null || dashboardBloc.selectedEndDate == null)) {
              dashboardBloc.selectedStartDate = startDate;
              dashboardBloc.selectedEndDate = endDate;
            }
          });
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
              height: UIConfig.headerWidgetHeight,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: UIConfig.accentColorGreen,
                    width: UIConfig.headerWidgetBorderWidth,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: UIConfig.spacingMedium.w, right: PlatformUtils.isMobile ? 3.w : 0.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        startDate != null && endDate != null
                            ? "${DateFormat('MMM dd, yyyy').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}"
                            : "Select Month Range",
                        style: GoogleFonts.robotoMono(
                          fontSize: UIConfig.fontSizeMediumResponsive,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                        ),
                      ),
                    ),
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/calendar_month.svg',
                        color: isDialogOpen
                            ? UIConfig.accentColorGreen
                            : Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                        height: UIConfig.iconSizeLarge,
                      ),
                    ),
                    SizedBox(width: UIConfig.spacingSmall),
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
      final now = DateTime.now();
      final minDate = DateTime(2020, 1, 1);
      final maxDate = DateTime(now.year, now.month, now.day);

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

      if (validStartDate != null && validEndDate != null && validEndDate.isBefore(validStartDate)) {
        validEndDate = validStartDate;
      }

      DateTimeRange? selectedRange;
      if (validStartDate != null && validEndDate != null) {
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

      DateTimeRange? currentSelectedRange = selectedRange;
      final dialogWidth = UIConfig.getDesktopDialogWidth(context);

      final DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                backgroundColor: currentTheme.dialogBG,
                elevation: 0,
                  child: Container(
                    
                    constraints: BoxConstraints(
                      maxWidth: (PlatformUtils.isDesktop ? UIConfig.desktopDrawerWidthMin : UIConfig.desktopDrawerWidthMin.w) - 60.w,
                      
                    ),
                  decoration: BoxDecoration(
                    color: currentTheme.dialogBG,
                    border: Border.all(
                      color: currentTheme.gridLineColor,
                      width: UIConfig.dialogBorderWidth,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                     
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChamferedTextWidgetInverted(
                            text: "SELECT DATE RANGE",
                            borderColor: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .gridLineColor,
                            fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: dialogWidth),
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
                      SizedBox(
                          width: (PlatformUtils.isDesktop ? UIConfig.desktopDrawerWidthMin : UIConfig.desktopDrawerWidthMin.w) - 90.w,
                          height: PlatformUtils.isMobile ? UIConfig.dialogMaxHeight * 0.6 : null,
                          child: RangeDatePicker(
                            minDate: minDate,
                            maxDate: maxDate,
                            initialDate: validStartDate ?? maxDate,
                            selectedRange: currentSelectedRange,
                            centerLeadingDate: true,

                            currentDateDecoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: UIConfig.accentColorGreen,
                                  width: UIConfig.borderWidthMedium,
                                ),
                                borderRadius: BorderRadius.circular(UIConfig.iconSizeLarge * 3.33)
                            ),
                            currentDateTextStyle: TextStyle(
                              color: UIConfig.accentColorGreen,
                              fontSize: UIConfig.fontSizeExtraSmallResponsive,
                              fontWeight: FontWeight.w600,

                            ),

                            enabledCellsDecoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(UIConfig.iconSizeLarge * 3.33),
                            ),
                            enabledCellsTextStyle: TextStyle(
                              color: currentTheme.basicAdvanceTextColor,
                              fontSize: UIConfig.fontSizeExtraSmallResponsive,
                            ),

                            selectedCellsDecoration: BoxDecoration(
                              color: UIConfig.accentColorGreen.withOpacity(UIConfig.opacityLow * 1.5),
                            ),
                            selectedCellsTextStyle: TextStyle(
                              color: currentTheme.basicAdvanceTextColor,
                              fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeExtraSmall, desktopWidth: 16.0),
                              fontWeight: FontWeight.w500,
                            ),

                            singleSelectedCellDecoration: BoxDecoration(
                              color: UIConfig.accentColorGreen,
                              borderRadius: BorderRadius.circular(UIConfig.iconSizeLarge * 3.33),
                            ),
                            singleSelectedCellTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeExtraSmall, desktopWidth: 16.0),
                              fontWeight: FontWeight.w600,
                            ),

                            daysOfTheWeekTextStyle: TextStyle(
                              color: currentTheme.gridHeadingColor,
                              fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeExtraSmall, desktopWidth: 14.0),
                              fontWeight: FontWeight.w500,
                            ),

                            disabledCellsTextStyle: TextStyle(
                              color: currentTheme.noEntriesColor,
                              fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeExtraSmall, desktopWidth: 16.0),
                            ),

                            leadingDateTextStyle: GoogleFonts.robotoMono(
                              fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeMedium, desktopWidth: 20.0),
                              fontWeight: FontWeight.w600,
                              color: currentTheme.basicAdvanceTextColor,
                            ),

                            slidersColor: UIConfig.accentColorGreen,
                            splashColor: UIConfig.accentColorGreen.withOpacity(UIConfig.opacityLow),
                            highlightColor: UIConfig.accentColorGreen.withOpacity(UIConfig.opacityLow * 2),

                            onStartDateChanged: (DateTime? date) {
                              if (date != null) {
                                final currentStart = currentSelectedRange?.start;
                                final currentEnd = currentSelectedRange?.end;

                                DateTimeRange? newRange;

                                if (currentStart != null && currentEnd != null &&
                                    !_areDatesEqual(currentStart, currentEnd)) {
                                  newRange = DateTimeRange(start: date, end: date);
                                }
                                else if (currentStart != null && currentEnd != null &&
                                    _areDatesEqual(currentStart, currentEnd)) {
                                  if (date.isBefore(currentStart)) {
                                    newRange = DateTimeRange(start: date, end: currentEnd);
                                  }
                                  else if (date.isAfter(currentStart)) {
                                    newRange = DateTimeRange(start: currentStart, end: date);
                                  }
                                  else {
                                    newRange = DateTimeRange(start: date, end: date);
                                  }
                                }
                                else {
                                  newRange = DateTimeRange(start: date, end: currentEnd ?? date);
                                }

                                final daysDifference = newRange.end.difference(newRange.start).inDays + 1;
                                if (daysDifference > 92) {
                                  CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Maximum date range is 92 days. Selected range is $daysDifference days.",
                                    AlertType.error,
                                  );
                                  return;
                                }

                                currentSelectedRange = newRange;
                                setDialogState(() {
                                });
                              }
                            },
                            onEndDateChanged: (DateTime? date) {
                              if (date != null) {
                                final currentStart = currentSelectedRange?.start;
                                final currentEnd = currentSelectedRange?.end;

                                DateTimeRange? newRange;

                                if (currentStart != null && currentEnd != null &&
                                    !_areDatesEqual(currentStart, currentEnd)) {
                                  newRange = DateTimeRange(start: date, end: date);
                                }
                                else if (currentStart != null && currentEnd != null &&
                                    _areDatesEqual(currentStart, currentEnd)) {
                                  if (date.isBefore(currentStart)) {
                                    newRange = DateTimeRange(start: date, end: currentEnd);
                                  }
                                  else if (date.isAfter(currentStart)) {
                                    newRange = DateTimeRange(start: currentStart, end: date);
                                  }
                                  else {
                                    newRange = DateTimeRange(start: date, end: date);
                                  }
                                }
                                else {
                                  newRange = DateTimeRange(start: currentStart ?? date, end: date);
                                }

                                final daysDifference = newRange.end.difference(newRange.start).inDays + 1;
                                if (daysDifference > 92) {
                                  CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Maximum date range is 92 days. Selected range is $daysDifference days.",
                                    AlertType.error,
                                  );
                                  return;
                                }

                                currentSelectedRange = newRange;
                                setDialogState(() {
                                });
                              }
                            },

                            onRangeSelected: (DateTimeRange? range) {
                              if (range != null) {
                                final currentStart = currentSelectedRange?.start;
                                final currentEnd = currentSelectedRange?.end;
                                final clickedStart = range.start;
                                final clickedEnd = range.end;

                                DateTimeRange? newRange;

                                final isSingleDateClick = _areDatesEqual(clickedStart, clickedEnd);

                                if (isSingleDateClick) {
                                  if (currentStart != null && currentEnd != null &&
                                      !_areDatesEqual(currentStart, currentEnd)) {
                                    newRange = DateTimeRange(start: clickedStart, end: clickedStart);
                                  }
                                  else if (currentStart != null && currentEnd != null &&
                                      _areDatesEqual(currentStart, currentEnd)) {
                                    if (clickedStart.isBefore(currentStart)) {
                                      newRange = DateTimeRange(start: clickedStart, end: currentEnd);
                                    }
                                    else if (clickedStart.isAfter(currentStart)) {
                                      newRange = DateTimeRange(start: currentStart, end: clickedStart);
                                    }
                                    else {
                                      newRange = DateTimeRange(start: clickedStart, end: clickedStart);
                                    }
                                  }
                                  else {
                                    newRange = DateTimeRange(start: clickedStart, end: clickedStart);
                                  }
                                } else {
                                  newRange = range;
                                }

                                final daysDifference = newRange.end.difference(newRange.start).inDays + 1;
                                if (daysDifference > 92) {
                                  CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Maximum date range is 92 days. Selected range is $daysDifference days.",
                                    AlertType.error,
                                  );
                                  return;
                                }

                                currentSelectedRange = newRange;
                                setDialogState(() {
                                });
                              } else {
                                currentSelectedRange = null;
                                setDialogState(() {
                                });
                              }
                            },
                          ),
                        ),
                      Container(
                        width: (PlatformUtils.isDesktop ? UIConfig.desktopDrawerWidthMin : UIConfig.desktopDrawerWidthMin.w) - 125.w,
                        padding: EdgeInsets.symmetric(vertical: UIConfig.spacingXSmall * 1.5.h, horizontal: UIConfig.spacingMedium.w),
                        decoration: BoxDecoration(
                          color: currentTheme.dropDownColor,
                          border: Border.all(
                            color: currentTheme.gridLineColor,
                            width: UIConfig.borderWidthThin,
                          ),
                          borderRadius: UIConfig.borderRadiusCircularMedium,
                        ),
                        child: Text(
                          currentSelectedRange != null
                              ? '${DateFormat('MMM dd, yyyy').format(currentSelectedRange!.start)} - ${DateFormat('MMM dd, yyyy').format(currentSelectedRange!.end)}'
                              : 'No date range selected',
                          style: TextStyle(
                            color: currentSelectedRange != null 
                                ? UIConfig.accentColorGreen 
                                : currentTheme.noEntriesColor,
                            fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeExtraSmall + 1.responsiveSp, desktopWidth: 15.0),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 30.h,),
                      SizedBox(

                        width: (PlatformUtils.isDesktop ? UIConfig.desktopDrawerWidthMin : UIConfig.desktopDrawerWidthMin.w) - 125.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              
                              text: 'CANCEL',
                              isEnabled: true,
                              isRed: true,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              dynamicWidth: true,
                            ),
                            CustomButton(
                              text: 'CONFIRM',
                              isEnabled: true,
                              isRed: false,
                              onPressed: () {
                                Navigator.of(context).pop(currentSelectedRange);
                              },
                              dynamicWidth: true,
                            ),
                          ],
                        ),
                      ),
                        SizedBox(height: 30.h,),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (pickedRange != null) {
        setState(() {
          startDate = pickedRange.start;
          endDate = pickedRange.end;
        });

        await _applyDateRange();
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.showCustomScaffoldMessenger(
          context,
          "Error selecting date range: $e",
          AlertType.error,
        );
        
      }
    }
  }

  Future<void> _applyDateRange() async {
    if (startDate != null && endDate != null) {
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
        setState(() {
          startDate = validRange.start;
          endDate = validRange.end;
        });

        if (mounted) {

        }
      }
    }
  }

  bool _areDatesEqual(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  DateTimeRange _getValidDateRange() {
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    final maxDate = DateTime(now.year, now.month, now.day);

    DateTime validStart = startDate ?? minDate;
    DateTime validEnd = endDate ?? maxDate;

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

    if (validEnd.isBefore(validStart)) {
      validEnd = validStart;
    }

    final daysDifference = validEnd.difference(validStart).inDays + 1;
    if (daysDifference > 92) {
      validEnd = validStart.add(Duration(days: 91));
    }

    return DateTimeRange(start: validStart, end: validEnd);
  }
}