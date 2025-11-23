import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
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
        final width = (MediaQuery.of(context).size.width * 1 / 3);
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first.toUpperCase()
            : "NO PROJECT SELECTED";

        return Column(
          children: [
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorYellow,
            ),
            Container(
              height: UIConfig.headerSectionHeight,
              padding: EdgeInsets.only(
                  left: UIConfig.spacingLarge.w,
                  right: (UIConfig.spacingExtraLarge - 1).w),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/projectSelection');
                      },
                      child: Container(
                        height: UIConfig.backButtonHeight,
                        // width: UIConfig.backButtonWidth,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: UIConfig.borderRadiusCircularMedium,
                            color: UIConfig.colorTransparent,
                            border: GradientBoxBorder(
                              width: UIConfig.chartBorderWidth,
                              gradient: LinearGradient(
                                colors: [
                                  UIConfig.accentColorYellow,
                                  UIConfig.accentColorYellow
                                      .withOpacity(UIConfig.opacityVeryHigh),
                                  Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .gridLineColor,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            )),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/back_arrow.svg',
                            height: UIConfig.projectIconHeight,
                            width: UIConfig.projectIconWidth,
                            colorFilter: ColorFilter.mode(
                              Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  UIConfig.spacingSizedBoxMedium,
                  SvgPicture.asset(
                    'assets/icons/project.svg',
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                    height: UIConfig.projectIconHeight,
                    width: UIConfig.projectIconWidth,
                  ),
                  UIConfig.spacingSizedBoxSmall,
                  Text(
                    currentProject.toUpperCase(),
                    style: TextStyle(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .basicAdvanceTextColor,
                        fontFamily: GoogleFonts.robotoMono().fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: UIConfig.fontSizeMediumResponsive,
                        letterSpacing: UIConfig.letterSpacingSp),
                  ),
                ],
              ),
            ),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorYellow,
            ),
            CustomMultipleSelectorHorizontal(),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorYellow,
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) {
                if (current is RefreshDashboard2 ||
                    current is RefreshDashboard) {
                  return true;
                }
                return false;
              }, builder: (context, state) {
                return TrendsChart(
                  chartData: dashboardBloc.nudronChartData,
                );
              }),
            ),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorYellow,
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) {
                if (current is RefreshDashboard2 ||
                    current is RefreshDashboard) {
                  return true;
                }
                return false;
              }, builder: (context, state) {
                return TrendsTable();
              }),
            ),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorYellow,
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(TrendsChartCombined oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dashboardBloc =
        BlocProvider.of<DashboardBloc>(context, listen: false);
    if (dashboardBloc.currentFilters.isNotEmpty && mounted) {
      setState(() {});
    }
  }
}
