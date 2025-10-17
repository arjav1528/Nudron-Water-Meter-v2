import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../widgets/custom_multiple_selector_horizontal.dart';
import 'trends_chart.dart';
import 'trends_table.dart';


class TrendsChartCombined extends StatefulWidget {
  const TrendsChartCombined({super.key});

  @override
  State<TrendsChartCombined> createState() => _TrendsChartCombinedState();
}

class _TrendsChartCombinedState extends State<TrendsChartCombined> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) => 
        current is RefreshDashboard || current is ChangeDashBoardNav,
      listener: (context, state) {
        if (mounted) {
          setState(() {}); // Force rebuild when state changes
        }
      },
      builder: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        
        // Check if we have any filters selected
        final currentProject = dashboardBloc.currentFilters.isNotEmpty && 
                             dashboardBloc.currentFilters.first != null
          ? dashboardBloc.currentFilters.first.toUpperCase()
          : "NO PROJECT SELECTED";

          print("Current Project: $currentProject");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 3.h,
              color: CommonColors.yellow,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 8.h),
              child: Row(
                children: [
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
                      fontSize: 16.sp,
                      letterSpacing: 0.5.sp
                    ),
                  ),
                ],
              ),
            ),
            
            CustomMultipleSelectorHorizontal(),
            Container(
              height: 3.minSp,
              color: CommonColors.yellow,
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) {
                if (current is RefreshDashboard2 || current is RefreshDashboard) {
                  return true;
                }
                return false;
              }, builder: (context, state) {
                return TrendsChart(
                  key: UniqueKey(),
                );

                // return Container();
              }),
            ),
            Container(
              height: 3.minSp,
              color: CommonColors.yellow,
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) {
                if (current is RefreshDashboard2 || current is RefreshDashboard) {
                  return true;
                }
                return false;
              }, builder: (context, state) {
                return TrendsTable(
                    // key: UniqueKey(),
                    );
                // return Container();
              }),
            ),
            Container(
              height: 3.h,
              color: CommonColors.yellow,
            ),
          ],
        );
      },
    );
  }
  
  @override
  void didUpdateWidget(TrendsChartCombined oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
    if (dashboardBloc.currentFilters.isNotEmpty && mounted) {
      setState(() {}); // Ensure UI updates when widget updates
    }
  }
}