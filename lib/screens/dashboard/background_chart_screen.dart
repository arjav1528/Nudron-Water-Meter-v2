import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/loader.dart';
import '../../services/platform_utils.dart';
import 'trends_chart.dart';

class BackgroundChart extends StatefulWidget {
  const BackgroundChart({super.key});

  @override
  State<BackgroundChart> createState() => _BackgroundChartState();
}

class _BackgroundChartState extends State<BackgroundChart> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        BlocProvider.of<DashboardBloc>(context).changeScreen();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(49.h),
          child: AppBar(
            backgroundColor:
                Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/back_arrow.svg',
                height: UIConfig.backButtonIconSize,
                width: UIConfig.backButtonIconSize,
                colorFilter: ColorFilter.mode(
                  Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                BlocProvider.of<DashboardBloc>(context).changeScreen();
              },
            ),
            actions: [
              Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, child) {
                  // Determine splash color based on current theme
                  // Dark mode -> Light mode: black splash
                  // Light mode -> Dark mode: white splash
                  final splashColor = themeNotifier.isDark
                      ? Colors.black.withOpacity(0.4) // Black splash for dark->light
                      : Colors.white.withOpacity(0.4); // White splash for light->dark
                  
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50.r),
                      onTap: themeNotifier.toggleTheme,
                      splashColor: splashColor,
                      highlightColor: splashColor,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 11.w,
                          top: ((51.h - 28.responsiveSp) / 2),
                          bottom: ((51.h - 28.responsiveSp) / 2),
                          left: 11.w,
                        ),
                        child: Icon(
                          Icons.contrast,
                          size: 28.responsiveSp,
                          color: themeNotifier.currentTheme.loginTitleColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            title: Text('FULLSCREEN CHART',
                style: GoogleFonts.roboto(
                  fontSize: UIConfig.fontSizeLargeResponsive,
                  fontWeight: FontWeight.w500,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .loginTitleColor,
                )),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(3.0),
              child: Container(
                color: CommonColors.yellow,
                height: 3.responsiveSp,
              ),
            ),
          ),
        ),
        body: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) {
              final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
              final hasDataLoaded = dashboardBloc.currentFilters.isNotEmpty &&
                  dashboardBloc.filterData != null;

              return current is DashboardPageLoaded ||
                  current is RefreshDashboard2 ||
                  current is RefreshDashboard ||
                  current is DashboardPageError ||
                  current is ChangeScreen ||
                  current is ChangeDashBoardNav ||
                  current is DashboardPageInitial ||
                  hasDataLoaded;
            },
            builder: (context, state) {
              final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
              final hasDataLoaded = dashboardBloc.currentFilters.isNotEmpty &&
                  dashboardBloc.filterData != null;

              if (state is DashboardPageLoaded ||
                  state is RefreshDashboard2 ||
                  state is RefreshDashboard ||
                  state is ChangeScreen ||
                  state is ChangeDashBoardNav ||
                  state is DashboardPageInitial ||
                  hasDataLoaded) {
                final chartWidget = BlocBuilder<DashboardBloc, DashboardState>(
                    buildWhen: (previous, current) {
                  if (current is RefreshDashboard2 ||
                      current is RefreshDashboard ||
                      current is ChangeScreen ||
                      current is ChangeDashBoardNav) {
                    return true;
                  }
                  return false;
                }, builder: (context, state) {
                  return RepaintBoundary(
                    key: dashboardBloc.repaintBoundaryKey,
                    child: Column(
                      children: [
                        Container(
                          height: 3.responsiveSp,
                          color: CommonColors.yellow,
                        ),
                        Expanded(
                          child: TrendsChart(
                              isFullScreen: true,
                              chartData: dashboardBloc.nudronChartData),
                        ),
                      ],
                    ),
                  );
                });

                return Center(
                  child: PlatformUtils.isMobile
                      ? RotatedBox(
                          quarterTurns: 1,
                          child: chartWidget,
                        )
                      : chartWidget,
                );
              } else if (state is DashboardPageError) {
                return Center(
                  child: Text(
                    "Error loading chart data",
                    style: GoogleFonts.roboto(
                      color: CommonColors.red,
                      fontSize: UIConfig.fontSizeMediumResponsive,
                    ),
                  ),
                );
              }

              return CustomLoader();
            },
          ),
        ),
      ),
    );
  }
}
