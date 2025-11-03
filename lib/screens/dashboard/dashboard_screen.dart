import 'dart:math' as math;
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
import '../../services/platform_utils.dart';
import '../../utils/alert_message.dart';
import '../../utils/loader.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_app_bar.dart';
import '../devices/devices_screen.dart';
import '../profile/profile_drawer.dart';
import 'background_chart_screen.dart';
import 'project_selection_screen.dart';
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

    return MultiProvider(
      providers: [
        BlocProvider(create: (context) => DashboardBloc()),
      ],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: BlocBuilder<DashboardBloc, DashboardState>(
              buildWhen: (previous, current) {
            if ((current is DashboardPageError ||
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
                        SizedBox(height: 20.h),
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
      ),
    );
  }
}

class MainDashboardPage extends StatefulWidget {
  static List<String> bottomNavTabs = [
    'project', // Move project to 0th index
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
  
  // Desktop-specific properties
  final double _drawerWidth = 230.0.w;
  final bool _isDrawerCollapsed = true;

  List<IconData> icons = [
    Icons.trending_up_sharp,
    Icons.summarize_outlined,
    Icons.person_outline_rounded,
  ];

  List<Color> selectedColor = [
    CommonColors.blue,
    CommonColors.yellow,
    CommonColors.green,
    CommonColors.red,
  ];

  // Always use static tabs
  List<String> bottomNavTabIcons = [
    'project', // Move project to 0th index
    'trends',
    'billing',
    'activity',
  ];

  @override
  void initState() {
    super.initState();
    // Remove dynamic tab update
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) async {
    //     MainDashboardPage.bottomNavTabs =
    //         (await DashboardBloc.updateBottomNavTabs(
    //             project: BlocProvider.of<DashboardBloc>(context)
    //                 .currentFilters
    //                 .firstOrNull))!;
    //   },
    // );
  }

  void showProfileDrawer(BuildContext context) async {
    // Check if user is authenticated using AuthBloc
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is! AuthAuthenticated) return;

    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    // Simple push without animations to match the IndexedStack behavior
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero, // No animation
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: dashboardBloc,
            child: SafeArea(
              child: Scaffold(
                body: ProfileDrawer(),
              ),
            ),
          );
        },
        // No transition animations
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // Return the child directly without animation
        },
      ),
    );
  }

  // Desktop sidebar navigation
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
        crossAxisAlignment: _isDrawerCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            height: 3.h,
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
            height: 3.h,
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
          height: 100.h,
          padding: EdgeInsets.zero,
          child: isCollapsed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/${bottomNavTabIcons[index]}.svg",
                      color: isSelected
                          ? selectedColor[index]
                          : Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .inactiveBottomNavbarIconColor,
                      width: 50.w,
                      height: 50.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      MainDashboardPage.bottomNavTabs[index].toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        color: isSelected
                            ? selectedColor[index % selectedColor.length]
                            : Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .inactiveBottomNavbarIconColor,
                        fontSize: 20.responsiveSp,
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
                      width: 70.0.w,
                      height: 70.0.w,
                    ),
                    SizedBox(width: 16.w),
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
      ProjectSelectionPage(),
      TrendsChartCombined(key: UniqueKey()),
      SummaryTable(key: UniqueKey()),
      DevicesPage(),
    ];

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: PlatformUtils.isDesktop ? _buildDesktopLayout(context, contentPages) : _buildMobileLayout(context, contentPages),
    );
  }

  // Desktop layout with sidebar navigation
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
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<DashboardBloc, DashboardState>(
              buildWhen: (previous, current) => current is ChangeDashBoardNav || current is RefreshDashboard,
              builder: (context, state) {
                final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
                int currentNavPos = dashboardBloc.bottomNavPos;
                List<String> visibleTabs = currentNavPos == 0 ? [MainDashboardPage.bottomNavTabs.first] : MainDashboardPage.bottomNavTabs;

                // Ensure drawerIndex stays in sync with bloc state
                if (drawerIndex != currentNavPos) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      drawerIndex = currentNavPos;
                    });
                  });
                }

                return _buildDesktopSideNav(context, currentNavPos, visibleTabs);
              },
            ),
            Container(
              width: 3.responsiveSp,
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
    );
  }

  // Mobile layout with bottom navigation bar
  Widget _buildMobileLayout(BuildContext context, List<Widget> contentPages) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        key: UniqueKey(),
        height: 69.h,
        padding: EdgeInsets.all(0.w),
        color: Provider.of<ThemeNotifier>(context).currentTheme.bottomNavColor,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          buildWhen: (previous, current) => current is ChangeDashBoardNav || current is RefreshDashboard,
          builder: (context, state) {
            final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
            int currentPositionOfBottomNav = dashboardBloc.bottomNavPos;

            // If "Project" tab is selected, show only "Project" tab
            List<String> visibleTabs = currentPositionOfBottomNav == 0
                ? [MainDashboardPage.bottomNavTabs.first] // Only "project"
                : MainDashboardPage.bottomNavTabs;        // All tabs

            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                visibleTabs.length,
                (index) {
                  int actualTabIndex = MainDashboardPage.bottomNavTabs.indexOf(visibleTabs[index]);
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
                            "assets/icons/${bottomNavTabIcons[actualTabIndex]}.svg",
                            color: currentPositionOfBottomNav == actualTabIndex
                                ? selectedColor[actualTabIndex % selectedColor.length]
                                : Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .inactiveBottomNavbarIconColor,
                            width: 45.responsiveSp,
                            height: 45.responsiveSp,
                          ),
                          Text(
                            visibleTabs[index].toUpperCase(),
                            style: GoogleFonts.robotoMono(
                              color: currentPositionOfBottomNav == actualTabIndex
                                  ? selectedColor[actualTabIndex % selectedColor.length]
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
                      dashboardBloc.switchBottomNavPos(actualTabIndex);
                    },
                  );
                },
              ),
            );
          },
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
      body: Row(
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
    );
  }
}