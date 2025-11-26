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
import '../../utils/custom_page_routes.dart';
import '../../widgets/custom_multiple_selector_horizontal.dart';
import 'trends_chart.dart';
import 'trends_table.dart';
import 'project_selection_screen.dart';

class TrendsChartCombined extends StatefulWidget {
  const TrendsChartCombined({super.key});

  @override
  State<TrendsChartCombined> createState() => _TrendsChartCombinedState();
}

class _TrendsChartCombinedState extends State<TrendsChartCombined> {
  String? _lastProject;
  late final GlobalKey _repaintBoundaryKey;

  @override
  void initState() {
    super.initState();
    _repaintBoundaryKey = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
        
        
        if (dashboardBloc.screenIndex == 0) {
          dashboardBloc.changeKey(_repaintBoundaryKey);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          current is RefreshDashboard || 
          current is ChangeDashBoardNav ||
          current is ChangeScreen,
      listener: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first
            : null;

        
        if (state is ChangeScreen && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && dashboardBloc.screenIndex == 0) {
              dashboardBloc.changeKey(_repaintBoundaryKey);
            }
          });
        }

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

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Flexible(
                  flex: 1,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Column(
                      children: [
                          Container(
                            height: UIConfig.accentLineHeight,
                            color: UIConfig.accentColorYellow,
                          ),
                          Container(
                            height: UIConfig.headerSectionHeight,
                            color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                            padding: EdgeInsets.only(
                                left: UIConfig.spacingLarge.w,
                                right: (UIConfig.spacingExtraLarge - 1).w),
                            child: Row(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        SlideLeftToRightRoute(page: const ProjectSelectionPage()),
                                      );
                                    },
                                    child: Container(
                                      height: UIConfig.backButtonHeight,
                                      
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
                                Expanded(
                                  child: Text(
                                    currentProject.toUpperCase(),
                                    style: TextStyle(
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .basicAdvanceTextColor,
                                        fontFamily: GoogleFonts.robotoMono().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        fontSize: UIConfig.fontSizeMediumResponsive,
                                        letterSpacing: UIConfig.letterSpacingSp),
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                  ),
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
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
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

  @override
  void dispose() {
    
    
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
    if (dashboardBloc.repaintBoundaryKey == _repaintBoundaryKey && dashboardBloc.screenIndex == 0) {
      dashboardBloc.repaintBoundaryKey = GlobalKey();
    }
    super.dispose();
  }
}
