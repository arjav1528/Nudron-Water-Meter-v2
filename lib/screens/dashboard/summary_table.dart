import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../widgets/billing_formula.dart';
import '../../widgets/custom_date_range_picker.dart';
import '../../widgets/data_grid_widget.dart';

class SummaryTable extends StatefulWidget {
  const SummaryTable({super.key});

  @override
  State<SummaryTable> createState() => _SummaryTableState();
}

class _SummaryTableState extends State<SummaryTable> {
  String? _lastProject;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc,DashboardState>(
      listenWhen: (previous, current) =>
      current is RefreshDashboard || current is ChangeDashBoardNav,
      listener: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first
            : null;
        
        if (mounted && _lastProject != currentProject) {
          _lastProject = currentProject;
          setState(() {});
        }
      },
      builder: (context, state){
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);

        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first.toUpperCase()
            : "NO PROJECT SELECTED";

        return Column(
          children: [
            Container(
              height: 3.responsiveSp,
              color: CommonColors.green,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 12.5.w, top: 8.h, bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      
                      Container(
                        height: 30.h,
                        width: 40.w,
                        
                        alignment: Alignment.center,
                        
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.r),
                          color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                          
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              colors: [
                                CommonColors.green,
                                CommonColors.green.withOpacity(0.6),
                                Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            width: 2.responsiveSp,
                          )
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/projectSelection');
                            },
                            child: Transform.scale(
                              scaleX: -1,
                              child: Icon(
                                Icons.arrow_right_alt,
                                color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                                size: 30.responsiveSp,
                              ),
                            ),
                            
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset('assets/icons/project.svg',
                        color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                        height: 30.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        currentProject.toUpperCase(),
                        style: TextStyle(
                            color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.responsiveSp,
                            letterSpacing: 0.5.sp
                        ),
                      ),
                    ],
                  ),
                  const BillingFormula(),

                ],
              ),
            ),
            Container(
              height: 3.responsiveSp,
              color: CommonColors.green,
            ),

            const CustomDateRangePicker(),
            Container(
              height: 3.responsiveSp,
              color: CommonColors.green,
            ),

            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                buildWhen: (previous, current) {
                  if (current is RefreshSummaryPage ||
                      current is RefreshSummaryPage2) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) {
                  final data =
                      BlocProvider.of<DashboardBloc>(context).summaryData;
                  
                  final Map<int, int> desktopJson = {};
                      final Map<int, int> mobileJson = {
                        0: 20.responsiveSp.toInt(),
                        1: 20.responsiveSp.toInt(),
                      };
                      final json = PlatformUtils.isDesktop ? desktopJson : mobileJson;

                  return DataGridWidget(
                    data: data,
                    key: UniqueKey(),
                    columnsToTakeHeaderWidthAndExtraPadding: json,
                    frozenColumns : 2,
                    location: 'billing',
                  );
                },
              ),
            ),
            Container(
              height: 3.h,
              color: CommonColors.green,
            ),
          ],
        );

      },
    );

  }
}