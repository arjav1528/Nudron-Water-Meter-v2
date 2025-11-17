import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../widgets/custom_safe_area.dart';
import '../../widgets/data_grid_widget.dart';
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) => current is RefreshDashboard || current is ChangeDashBoardNav,
      listener: (context, state){
        if(mounted){
          setState(() {});
        }
      },
      builder: (context, state){
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        final currentProject = dashboardBloc.currentFilters.isNotEmpty
            ? dashboardBloc.currentFilters.first.toUpperCase()
            : "NO PROJECT SELECTED";

        final width = (MediaQuery.of(context).size.width * 1/3).clamp(400.0, 550.0);
        final responsiveFontSize = UIConfig.getResponsiveFontSize(
          context, 
          UIConfig.fontSizeLarge, 
          desktopWidth: width
        );

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
            
            body: CustomSafeArea(
              child: Column(
              children: [
                Container(
                  height: UIConfig.accentLineHeight,
                  color: UIConfig.accentColorRed,
                ),
                Container(
                  height: UIConfig.headerSectionHeight,
                  padding: EdgeInsets.only(left: UIConfig.spacingLarge.w, right: UIConfig.spacingExtraLarge.w),
                  child: Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
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
                                      UIConfig.accentColorRed,
                                      UIConfig.accentColorRed.withOpacity(UIConfig.opacityVeryHigh),
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
                ),
            
                Container(
                  height: UIConfig.accentLineHeight,
                  color: UIConfig.accentColorRed,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    
                    Expanded(
                      child: Material(
                        color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .dropDownColor,
                        child: Ink(
                          
                          child: InkWell(
                            splashFactory: InkRipple.splashFactory,
                            splashColor:
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .currentTheme
                                .splashColor,
                            child: Container(
                              height: UIConfig.headerWidgetHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: UIConfig.accentColorRed,
                                    width: UIConfig.headerWidgetBorderWidth,
                                  ),
                                ),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.only(right: UIConfig.spacingSmall.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(                         
                                          controller: _searchController,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: [
                                            UpperCaseTextFormatter(),
                                          ],
                                          style: GoogleFonts.robotoMono(
                                            fontSize: UIConfig.fontSizeMediumResponsive,
                                            color: Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor,
                                          ),
                                          decoration: InputDecoration(
                                          
                                            // filled: true,
                                            fillColor: UIConfig.colorTransparent,
                                            hintText:
                                            'SEARCH DEVICE LABEL OR SERIAL NO.',
                                            hintStyle: GoogleFonts.robotoMono(
                                              fontSize: UIConfig.fontSizeMediumResponsive,
                                              color: Provider.of<ThemeNotifier>(context)
                                                  .currentTheme
                                                  .noEntriesColor,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:EdgeInsets.only(left: UIConfig.spacingMedium.w, right: 1.w, bottom: PlatformUtils.isMobile ? 0.h : 5.h),
                                            isDense: true,
                                          ),
                                          textAlignVertical: TextAlignVertical.center,
                                          onChanged: (query) {
                                            // Cancel previous timer if it exists
                                            _searchDebounceTimer?.cancel();
                                            
                                            // Start a new timer that will trigger search after 0.5 seconds
                                            _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
                                              if (mounted) {
                                                dashboardBloc.filterDevices(_searchController.text);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      Icon(
                                        Icons.search,
                                        color:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .basicAdvanceTextColor,
                                        size: UIConfig.iconSizeLarge,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                   
                  ],
                ),
                Container(
                  height: UIConfig.accentLineHeight,
                  color: UIConfig.accentColorRed,
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
                      final Map<int, int> mobileJson = {
                        0: UIConfig.iconSizeLarge.toInt(),
                        3: UIConfig.scrollClampMin.toInt(),
                      };
                      final Map<int, int> desktopJson = {
                        3: UIConfig.scrollClampMin.toInt(),
                      };
                      final Map<int, int> json = PlatformUtils.isMobile ? mobileJson : desktopJson;
                      return DataGridWidget(
                        data: dashboardBloc.devicesData,
                        key: UniqueKey(), columnsToTakeHeaderWidthAndExtraPadding: json,
                        frozenColumns: 1,
                        devicesTable: true,
                        location: 'devices',
                      );
                    },
                  ),
                ),
                Container(
                  height: UIConfig.accentLineHeight,
                  color: UIConfig.accentColorRed,
                ),
              ],
            ),
              ),
          ),
        );
      },

    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}