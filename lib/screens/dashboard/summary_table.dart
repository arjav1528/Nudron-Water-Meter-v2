import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../widgets/billing_formula.dart';
import '../../widgets/custom_date_range_picker.dart';
import '../../widgets/custom_safe_area.dart';
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
        final width = (MediaQuery.of(context).size.width * 1/3).clamp(400.0, 550.0);
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first.toUpperCase()
            : "NO PROJECT SELECTED";

        return CustomSafeArea(
          child: Column(
            children: [
              Container(
                height: UIConfig.accentLineHeight,
                color: UIConfig.accentColorGreen,
              ),
            Container(
              height: UIConfig.headerSectionHeight,
              padding: UIConfig.paddingChartHorizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/projectSelection');
                        },
                        child: Container(
                          height: UIConfig.backButtonHeight,
                          width: UIConfig.backButtonWidth,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: UIConfig.borderRadiusCircularMedium,
                              color: UIConfig.colorTransparent,
                              border: GradientBoxBorder(
                                width: UIConfig.chartBorderWidth,
                                gradient: LinearGradient(
                                  colors: [
                                    UIConfig.accentColorGreen,
                                    UIConfig.accentColorGreen.withOpacity(UIConfig.opacityVeryHigh),
                                    Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              )
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/back_arrow.svg',
                              height: UIConfig.backButtonIconSize,
                              width: UIConfig.backButtonIconSize,
                              colorFilter: ColorFilter.mode(
                                Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      UIConfig.spacingSizedBoxMedium,
                      SvgPicture.asset('assets/icons/project.svg',
                        color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                        height: UIConfig.projectIconHeight,
                        width: UIConfig.projectIconWidth,
                      ),
                      UIConfig.spacingSizedBoxSmall,
                      Text(
                        currentProject.toUpperCase(),
                        style: TextStyle(
                            color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: UIConfig.fontSizeLargeResponsive,
                            letterSpacing: UIConfig.letterSpacingSp
                        ),
                      ),
                    ],
                  ),
                  const BillingFormula(),

                ],
              ),
            ),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorGreen,
            ),

            const CustomDateRangePicker(),
            Container(
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorGreen,
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
                        0: UIConfig.iconSizeLarge.toInt(),
                        1: UIConfig.spacingExtraLarge.responsiveSp.toInt(),
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
              height: UIConfig.accentLineHeight,
              color: UIConfig.accentColorGreen,
            ),
          ],
          ),
        );

      },
    );

  }
}