import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
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
            // body: Center(
            //   child: Container(
            //     child: Column(
            //       children: [
            //         Text("Devices Page Remaining"),
            //         Text("Devices Page Remaining"),
                   
            //       ],
            //     ),
            //   ),  
            // ),
            body: Column(
              children: [
                Container(
                  height: 3.responsiveSp,
                  color: CommonColors.red,
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
                            fontSize: 16.responsiveSp,
                            letterSpacing: 0.5.sp
                        ),
                      ),
                    ],
                  ),
                ),
            
                Container(
                  height: 3.responsiveSp,
                  color: CommonColors.red,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Container(
                    //   width: 16.responsiveSp,
                    //   color: CommonColors.red,
                    // ),
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
                              height: 46.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: CommonColors.red,
                                    width: 12.responsiveSp,
                                  ),
                                ),
                              ),
                              child: Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(12.w, 0.h, 0.w, 0.h),
                                  child: TextField(
                                    // textAlign: TextAlign
                                    //     .center, // Centers input text & hint horizontally
                                    controller: _searchController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                    ],
                                    style: GoogleFonts.robotoMono(
                                      fontSize: ThemeNotifier.small.responsiveSp,
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
                                        fontSize: ThemeNotifier.small.responsiveSp,
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .noEntriesColor,
                                      ),
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(
                                            right:
                                            8.w), // Adjust padding if needed
                                        child: Icon(
                                          Icons.search,
                                          color:
                                          Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .basicAdvanceTextColor,
                                          size: 30.responsiveSp,
                                        ),
                                      ),
                                      border: InputBorder
                                          .none, // Removesg default border
            
                                      // Key Fix for Vertical Centering
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        // horizontal: 4.0,
                                      ),
                                      isCollapsed:
                                      true, // Prevents excessive internal padding
                                    ),
                                    textAlignVertical: TextAlignVertical
                                        .center, // Ensures vertical centering
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
                  height: 3.responsiveSp,
                  color: CommonColors.red,
                ),
                // SizedBox(height: 16),
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
                        0: 30.responsiveSp.toInt(),
                        3: 0.responsiveSp.toInt(),
                      };
                      final Map<int, int> desktopJson = {
                        3: 0.responsiveSp.toInt(),
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
                  height: 3.h,
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