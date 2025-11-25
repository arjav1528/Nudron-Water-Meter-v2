import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:watermeter2/utils/upper_case_text_formatter.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
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
  final TextEditingController _billingSearchController =
      TextEditingController();
  Timer? _billingSearchDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
      final existingQuery = dashboardBloc.billingSearchQuery;
      if (existingQuery.isNotEmpty) {
        _billingSearchController.text = existingQuery;
      }
    });
  }

  @override
  void dispose() {
    _billingSearchDebounceTimer?.cancel();
    _billingSearchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc,DashboardState>(
      listenWhen: (previous, current) =>
      current is RefreshDashboard || current is ChangeDashBoardNav,
      listener: (context, state) {
        if (!mounted) return;
        try {
          final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
          final currentProject = dashboardBloc.currentFilters.isNotEmpty
              ? dashboardBloc.currentFilters.first
              : null;
          
          if (_lastProject != currentProject) {
            _lastProject = currentProject;
            _billingSearchController.clear();
            dashboardBloc.filterBillingData('');
            if (mounted) {
              setState(() {});
            }
          }
        } catch (e) {
          
        }
      },
      builder: (context, state){
        if (!mounted) {
          return const SizedBox.shrink();
        }
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first.toUpperCase()
            : "NO PROJECT SELECTED";

        return Column(
          children: [
              Container(
                height: UIConfig.accentLineHeight,
                color: UIConfig.accentColorGreen,
              ),
            Container(
              height: UIConfig.headerSectionHeight,
              padding: EdgeInsets.only(left: UIConfig.spacingLarge.w, right: (UIConfig.spacingSmall+1).w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [

                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed('/projectSelection');
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
                                height: UIConfig.projectIconHeight,
                                width: UIConfig.projectIconWidth,
                                colorFilter: ColorFilter.mode(
                                  Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                                  BlendMode.srcIn,
                                ),
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
                            fontWeight: FontWeight.w500,
                            fontSize: UIConfig.fontSizeMediumResponsive,
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
            _buildBillingSearchBar(context),
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
                  if (!mounted) {
                    return const SizedBox.shrink();
                  }
                  final data =
                      BlocProvider.of<DashboardBloc>(context).summaryData;
                  
                  final Map<int, int> desktopJson = {};
                      final Map<int, int> mobileJson = {
                        0: 0.responsiveSp.toInt(),
                        1: 0.responsiveSp.toInt(),
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
        );

      },
    );

  }

  Widget _buildBillingSearchBar(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    final theme = Provider.of<ThemeNotifier>(context);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: theme.currentTheme.dropDownColor,
            child: Ink(
              child: InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor:
                    theme.currentTheme.splashColor,
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
                    padding: EdgeInsets.only(right: UIConfig.spacingSmall + (PlatformUtils.isMobile ? 1.w : -1.w)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _billingSearchController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                            style: GoogleFonts.robotoMono(
                              fontSize: UIConfig.fontSizeMediumResponsive,
                              color: theme.currentTheme.basicAdvanceTextColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'SEARCH FILTER',
                              hintStyle: GoogleFonts.robotoMono(
                                fontSize: UIConfig.fontSizeMediumResponsive,
                                color: theme.currentTheme.noEntriesColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: UIConfig.spacingMedium.w,
                                  right: 1.w,
                                  bottom: PlatformUtils.isMobile ? 0.h : 5.h),
                              isDense: true,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (query) {
                              _billingSearchDebounceTimer?.cancel();
                              _billingSearchDebounceTimer =
                                  Timer(const Duration(milliseconds: 250), () {
                                if (!mounted) return;
                                dashboardBloc.filterBillingData(
                                    _billingSearchController.text);
                              });
                            },
                          ),
                        ),
                        Icon(
                          Icons.search,
                          color: theme.currentTheme.basicAdvanceTextColor,
                          size: UIConfig.iconSizeLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}