import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../services/platform_utils.dart';
import '../../utils/alert_message.dart';
import '../../utils/loader.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_safe_area.dart';
import '../devices/devices_screen.dart';
import '../profile/profile_drawer.dart';
import 'background_chart_screen.dart';
import 'summary_table.dart';
import 'trends_chart_combined.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int drawerIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fullScreens = [
      MainDashboardPage(),
      BackgroundChart(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomSafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) {
          
          if ((current is DashboardPageInitial) ||
              (current is DashboardPageError ||
              current is DashboardPageLoaded ||
              current is ChangeScreen)) {
            return true;
          }
          return false;
        }, builder: (context, state) {
            if (state is DashboardPageLoaded || state is ChangeScreen) {
              return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: IndexedStack(
                    index: BlocProvider.of<DashboardBloc>(context).screenIndex,
                    children: fullScreens,
                  ));
            } else if (state is DashboardPageError) {
              return Scaffold(
                body: Center(
                  child: SizedBox(
                    height: UIConfig.dialogMaxHeight + 100.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("ERROR IN FETCHING DATA. REFRESH LATER",
                            style: GoogleFonts.roboto(
                              color: CommonColors.blue,
                              fontSize: UIConfig.fontSizeMediumResponsive,
                              fontWeight: FontWeight.w500,
                            )),
                        SizedBox(height: UIConfig.spacingExtraLarge),
                        CustomButton(
                          text: "REFRESH",
                          onPressed: () {
                            LoaderUtility.showLoader(
                                    context,
                                    BlocProvider.of<DashboardBloc>(context)
                                        .loadInitialData())
                                .then((s) {})
                                .catchError((e) {
                              CustomAlert.showCustomScaffoldMessenger(context,
                                  "Error in loading data", AlertType.error);
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          
          return const CustomLoader();
        }),
      ),
    );
  }
}

class MainDashboardPage extends StatefulWidget {
  static List<String> bottomNavTabs = [
    
    'trends',
    'billing',
    'activity',
  ];

  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int drawerIndex = 0;
  
  final double _drawerWidth = 230.0.w;
  final bool _isDrawerCollapsed = true;

  List<IconData> icons = [
    Icons.trending_up_sharp,
    Icons.summarize_outlined,
    Icons.person_outline_rounded,
  ];

  List<Color> selectedColor = [
    
    CommonColors.yellow,
    CommonColors.green,
    CommonColors.red,
  ];

  List<String> bottomNavTabIcons = [
    
    'trends',
    'billing',
    'activity',
  ];

  @override
  void initState() {
    super.initState();
    
  }

  void showProfileDrawer(BuildContext context) async {
    
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is! AuthAuthenticated) return;

    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: UIConfig.transitionDurationZero, 
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: dashboardBloc,
            child: Scaffold(
              body: ProfileDrawer(),
            ),
          );
        },
        
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; 
        },
      ),
    );
  }

  Widget _buildDesktopSideNav(BuildContext context, int currentNavPos, List<String> visibleTabs) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: _isDrawerCollapsed ? 130.0.w : _drawerWidth,
      decoration: BoxDecoration(
        color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: UIConfig.accentLineHeight,
            color: selectedColor[drawerIndex],
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: List.generate(
                visibleTabs.length,
                (index) => _buildNavItem(
                  visibleTabs: visibleTabs,
                  index: index,
                  isSelected: currentNavPos == index,
                  context: context,
                  isCollapsed: _isDrawerCollapsed,
                  currentIndex: currentNavPos,
                ),
              ),
            ),
          ),
          Container(
            height: UIConfig.accentLineHeight,
            color: selectedColor[drawerIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required bool isSelected,
    required BuildContext context,
    required bool isCollapsed,
    required int currentIndex,
    required List<String> visibleTabs,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          BlocProvider.of<DashboardBloc>(context).switchBottomNavPos(index);
        },
        child: Container(
          height: UIConfig.buttonHeight * 2.16,
          padding: EdgeInsets.zero,
          child: isCollapsed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/${bottomNavTabIcons[index]}.svg",
                      color: isSelected
                          ? selectedColor[index]
                          : Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .inactiveBottomNavbarIconColor,
                      width: UIConfig.iconSizeLarge + 20.w,
                      height: UIConfig.iconSizeLarge + 20.w,
                    ),
                    SizedBox(height: UIConfig.spacingXSmall),
                    Text(
                      MainDashboardPage.bottomNavTabs[index].toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        color: isSelected
                            ? selectedColor[index % selectedColor.length]
                            : Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .inactiveBottomNavbarIconColor,
                        fontSize: 20.minSp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                )
              : Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/${bottomNavTabIcons[index]}.svg",
                      color: isSelected
                          ? selectedColor[index]
                          : Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .inactiveBottomNavbarIconColor,
                      width: UIConfig.iconSizeLarge * 2.33,
                      height: UIConfig.iconSizeLarge * 2.33,
                    ),
                    UIConfig.spacingSizedBoxVerticalLarge,
                    Expanded(
                      child: Text(
                        MainDashboardPage.bottomNavTabs[index].toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          color: isSelected
                              ? selectedColor[index % selectedColor.length]
                              : Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .inactiveBottomNavbarIconColor,
                          fontSize: 16.responsiveSp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contentPages = [
      
      TrendsChartCombined(key: UniqueKey()),
      SummaryTable(key: UniqueKey()),
      DevicesPage(),
    ];

    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        final hasDataLoaded = dashboardBloc.currentFilters.isNotEmpty && 
                              dashboardBloc.filterData != null;
        
        return current is DashboardPageLoaded ||
               current is ChangeScreen ||
               current is DashboardPageError ||
               current is DashboardPageInitial ||
               current is ChangeDashBoardNav ||
               current is RefreshDashboard ||
               current is RefreshDashboard2 ||
               hasDataLoaded;
      },
      builder: (context, state) {
        final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
        
        final hasDataLoaded = dashboardBloc.currentFilters.isNotEmpty && 
                              dashboardBloc.filterData != null;
        
        if (state is DashboardPageLoaded || 
            state is ChangeScreen ||
            state is DashboardPageInitial ||
            state is ChangeDashBoardNav ||
            state is RefreshDashboard ||
            state is RefreshDashboard2 ||
            hasDataLoaded) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: IndexedStack(
              index: dashboardBloc.screenIndex,
              children: [
                
                WillPopScope(
                  onWillPop: () {
                    return Future.value(false);
                  },
                  child: PlatformUtils.isDesktop
                      ? _buildDesktopLayout(context, contentPages)
                      : _buildMobileLayout(context, contentPages),
                ),
                
                BackgroundChart(),
              ],
            ),
          );
        } else if (state is DashboardPageError) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                height: 600.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("ERROR IN FETCHING DATA. REFRESH LATER",
                        style: GoogleFonts.roboto(
                          color: CommonColors.blue,
                          fontSize: ThemeNotifier.medium.responsiveSp,
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(height: UIConfig.spacingExtraLarge),
                    CustomButton(
                      text: "REFRESH",
                      onPressed: () {
                        LoaderUtility.showLoader(
                                context,
                                BlocProvider.of<DashboardBloc>(context)
                                    .loadInitialData())
                            .then((s) {})
                            .catchError((e) {
                          CustomAlert.showCustomScaffoldMessenger(context,
                              "Error in loading data", AlertType.error);
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }
        
        return const CustomLoader();
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<Widget> contentPages) {
    return Focus(
      autofocus: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        appBar: CustomAppBar(
          choiceAction: (value) {
            showProfileDrawer(context);
          },
        ),
        body: CustomSafeArea(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<DashboardBloc, DashboardState>(
              buildWhen: (previous, current) => current is ChangeDashBoardNav || current is RefreshDashboard,
              builder: (context, state) {
                final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
                int currentNavPos = dashboardBloc.bottomNavPos.clamp(0, MainDashboardPage.bottomNavTabs.length - 1);
                
                List<String> visibleTabs = MainDashboardPage.bottomNavTabs;

                final clampedNavPos = currentNavPos.clamp(0, selectedColor.length - 1);
                if (drawerIndex != clampedNavPos) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      drawerIndex = clampedNavPos;
                    });
                  });
                }

                return _buildDesktopSideNav(context, currentNavPos, visibleTabs);
              },
            ),
            Container(
              width: UIConfig.sidebarWidth,
              color: selectedColor[BlocProvider.of<DashboardBloc>(context).bottomNavPos % selectedColor.length],
            ),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) => current is ChangeDashBoardNav,
                  builder: (context, state) {
                    int currentNavPos = BlocProvider.of<DashboardBloc>(context).bottomNavPos;
                    return IndexedStack(
                      index: currentNavPos,
                      children: contentPages,
                    );
                  }),
            ),
          ],
        ),
          ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Widget> contentPages) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: UIConfig.bottomNavBarHeight,
              color: Provider.of<ThemeNotifier>(context).currentTheme.bottomNavColor,
              child: BlocBuilder<DashboardBloc, DashboardState>(
                buildWhen: (previous, current) => current is ChangeDashBoardNav || current is RefreshDashboard,
                builder: (context, state) {
                  final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
                  int currentPositionOfBottomNav = dashboardBloc.bottomNavPos.clamp(0, MainDashboardPage.bottomNavTabs.length - 1);

                  List<String> visibleTabs = MainDashboardPage.bottomNavTabs;

                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      visibleTabs.length,
                      (index) {
                        
                        final safeIndex = index.clamp(0, bottomNavTabIcons.length - 1);
                        return GestureDetector(
                          child: Container(
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .bottomNavColor,
                            width: MediaQuery.of(context).size.width / visibleTabs.length,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/${bottomNavTabIcons[safeIndex]}.svg",
                                  color: currentPositionOfBottomNav == index
                                      ? selectedColor[safeIndex % selectedColor.length]
                                      : Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .inactiveBottomNavbarIconColor,
                                  width: UIConfig.iconSizeLarge + 15.responsiveSp,
                                  height: UIConfig.iconSizeLarge + 15.responsiveSp,
                                ),
                                Text(
                                  visibleTabs[index].toUpperCase(),
                                  style: GoogleFonts.robotoMono(
                                    color: currentPositionOfBottomNav == index
                                        ? selectedColor[safeIndex % selectedColor.length]
                                        : Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .inactiveBottomNavbarIconColor,
                                    fontSize: 16.responsiveSp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            dashboardBloc.switchBottomNavPos(index);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              height: bottomPadding,
              color: Colors.black,
            ),
          ],
        ),
      ),
      drawerEnableOpenDragGesture: false,
      key: _scaffoldKey,
      backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      drawerEdgeDragWidth: 0.0,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        choiceAction: (value) {
          showProfileDrawer(context);
        },
      ),
      body: CustomSafeArea(
        child: Row(
        children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    height: constraints.maxHeight,
                    child: BlocBuilder<DashboardBloc, DashboardState>(
                        buildWhen: (previous, current) =>
                            current is ChangeDashBoardNav,
                        builder: (context, state) {
                          int bottomNavPos =
                              BlocProvider.of<DashboardBloc>(context)
                                  .bottomNavPos;
                          return IndexedStack(
                            index: bottomNavPos,
                            children: contentPages,
                          );
                        }),
                  ),
                ],
              ),
            );
          })
        ],
        ),
      ),
    );
  }
}