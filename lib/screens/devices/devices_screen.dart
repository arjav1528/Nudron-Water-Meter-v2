import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../widgets/data_grid_widget.dart';
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
            
            body: Column(
              children: [
                Container(
                  height: UIConfig.accentLineHeightResponsive,
                  color: UIConfig.accentColorRed,
                ),
                Padding(
                  padding: UIConfig.paddingChartHorizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/projectSelection');
                        },
                        child: Container(
                          height: 35.h,
                          width: 45.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: UIConfig.borderRadiusCircularMedium,
                              color: Colors.transparent,
                              border: GradientBoxBorder(
                                width: UIConfig.chartBorderWidth,
                                gradient: LinearGradient(
                                  colors: [
                                    CommonColors.red,
                                    CommonColors.red.withOpacity(0.6),
                                    Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              )
                          ),
                          child: Center(
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
                      UIConfig.spacingSizedBoxMedium,
                      SvgPicture.asset('assets/icons/project.svg',
                        color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                        height: 30.h,
                      ),
                      UIConfig.spacingSizedBoxSmall,
                      Text(
                        currentProject.toUpperCase(),
                        style: TextStyle(
                            color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: UIConfig.fontSizeSmallResponsive,
                            letterSpacing: UIConfig.letterSpacingSp
                        ),
                      ),
                    ],
                  ),
                ),
            
                Container(
                  height: UIConfig.accentLineHeightResponsive,
                  color: UIConfig.accentColorRed,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .dropDownColor,
                          child: InkWell(
                            splashFactory: InkRipple.splashFactory,
                            splashColor:
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .currentTheme
                                .splashColor,
                            child: Container(
                              height: UIConfig.buttonHeight + 2.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: CommonColors.red,
                                    width: UIConfig.spacingMedium.responsiveSp,
                                  ),
                                ),
                              ),
                              child: Padding(
                                  padding:
                                  EdgeInsets.symmetric(vertical: UIConfig.spacingSmall.h, horizontal: UIConfig.spacingMedium.w),
                                  child: TextField(
                                    
                                    controller: _searchController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                    ],
                                    style: GoogleFonts.robotoMono(
                                      fontSize: UIConfig.fontSizeSmallResponsive,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .basicAdvanceTextColor,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      hintText:
                                      'SEARCH DEVICE LABEL OR SERIAL NO.',
                                      hintStyle: GoogleFonts.robotoMono(
                                        fontSize: UIConfig.fontSizeSmallResponsive,
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .noEntriesColor,
                                      ),
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(
                                            right:
                                            UIConfig.spacingSmall.w), 
                                        child: Icon(
                                          Icons.search,
                                          color:
                                          Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .basicAdvanceTextColor,
                                          size: UIConfig.iconSizeLarge,
                                        ),
                                      ),
                                      border: InputBorder
                                          .none, 
            
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        
                                      ),
                                      isCollapsed:
                                      true, 
                                    ),
                                    textAlignVertical: TextAlignVertical
                                        .center, 
                                    onChanged: (query) {
                                      dashboardBloc
                                          .filterDevices(_searchController.text);
                                    },
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                   
                  ],
                ),
                Container(
                  height: UIConfig.accentLineHeightResponsive,
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
                  color: CommonColors.red,
                ),
              ],
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