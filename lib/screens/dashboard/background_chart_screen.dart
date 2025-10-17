import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../utils/loader.dart';
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
              icon: Icon(
                Icons.arrow_back,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
              ),
              onPressed: () {
                BlocProvider.of<DashboardBloc>(context).changeScreen();
              },
            ),
            actions: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50.r),
                  onTap: Provider.of<ThemeNotifier>(context).toggleTheme,
                  splashColor:
                      Provider.of<ThemeNotifier>(context, listen: false)
                          .currentTheme
                          .splashColor,

                  // Customize the splash color
                  highlightColor:
                      Provider.of<ThemeNotifier>(context, listen: false)
                          .currentTheme
                          .splashColor,
                  // Customize the highlight color
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 11.w,
                      top: (51.h - 28.minSp) / 2,
                      bottom: (51.h - 28.minSp) / 2,
                      left: 11.w,
                    ),
                    // child: Image.asset(
                    //   "assets/icons/themetoggle.png",
                    //   width: 28.minSp,
                    //   height: 28.minSp,
                    //   color: Provider.of<ThemeNotifier>(context)
                    //       .currentTheme
                    //       .loginTitleColor,
                    // ),
                    child: Icon(
                      Icons.contrast,
                      size: 28.minSp,
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .loginTitleColor,
                    ),
                  ),
                ),
              ),
            ],
            title: Text('FULLSCREEN CHART',
                style: GoogleFonts.roboto(
                  fontSize: 24.minSp,
                  fontWeight: FontWeight.w500,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .loginTitleColor,
                )),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(3.0),
              // Define the height of the line
              child: Container(
                color: CommonColors.yellow, // The color of the line
                height: 3.minSp, // Define the thickness of the line
              ),
            ),
          ),
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          buildWhen: (previous, current) =>
              current is DashboardPageLoaded ||
              current is RefreshDashboard2 ||
              current is RefreshDashboard ||
              current is DashboardPageError,
          builder: (context, state) {
            if (state is DashboardPageLoaded ||
                state is RefreshDashboard2 ||
                state is RefreshDashboard) {
              return Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: BlocBuilder<DashboardBloc, DashboardState>(
                      buildWhen: (previous, current) {
                    if (current is RefreshDashboard2 ||
                        current is RefreshDashboard) {
                      return true;
                    }
                    return false;
                  }, builder: (context, state) {
                    GlobalKey key = GlobalKey();
                    BlocProvider.of<DashboardBloc>(context).changeKey(key);
                    return RepaintBoundary(
                      key: key,
                      child: Column(
                        children: [
                          Container(
                            height: 3.minSp, // Divider
                            color: CommonColors.yellow,
                          ),
                          Expanded(
                            child: TrendsChart(isFullScreen: true, key: UniqueKey()),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            } else if (state is DashboardPageError) {
              return Center(
                child: Text(
                  "Error loading chart data",
                  style: GoogleFonts.roboto(
                    color: CommonColors.red,
                    fontSize: ThemeNotifier.medium.minSp,
                  ),
                ),
              );
            }
            // Show loader while fetching
            return CustomLoader();
          },
        ),
      ),
    );
  }
}