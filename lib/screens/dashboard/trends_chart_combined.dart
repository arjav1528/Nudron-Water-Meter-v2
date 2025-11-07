import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
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
  String? _lastProject;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
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
      builder: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
          ? dashboardBloc.currentFilters.first.toUpperCase()
          : "NO PROJECT SELECTED";

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
                                CommonColors.yellow,
                                CommonColors.yellow.withOpacity(0.6),
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
            ),
            
            CustomMultipleSelectorHorizontal(),
            Container(
              height: 3.responsiveSp,
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

              }),
            ),
            Container(
              height: 3.responsiveSp,
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
                    
                    );
                
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
      setState(() {}); 
    }
  }
}