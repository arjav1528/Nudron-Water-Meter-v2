import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watermeter2/bloc/dashboard_bloc.dart';
import 'package:watermeter2/bloc/dashboard_state.dart';
import 'package:watermeter2/bloc/auth_bloc.dart';
import 'package:watermeter2/bloc/auth_state.dart';
import 'package:watermeter2/bloc/auth_event.dart';
import 'package:watermeter2/utils/excel_helpers.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/services/mobile/mobile_init.dart';
import 'package:watermeter2/services/desktop/desktop_init.dart';
import 'package:watermeter2/constants/theme2.dart';
import 'package:watermeter2/screens/dashboard/dashboard_screen.dart';
import 'package:watermeter2/screens/dashboard/project_selection_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/constants/app_config.dart';
import 'package:watermeter2/screens/auth/login_screen.dart';
import 'package:watermeter2/screens/auth/two_factor_screen.dart';
import 'package:watermeter2/utils/loader.dart';
import 'package:watermeter2/widgets/custom_safe_area.dart';

import 'utils/alert_message.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if(Platform.isIOS){
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    debugPrint('Running on ${iosInfo.utsname.machine}');
  }
  if(Platform.isAndroid){
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final model = androidInfo.model.toLowerCase();
    final features = androidInfo.systemFeatures.join(',');

    final likelyTablet = !features.contains('android.hardware.telephony');

    if (likelyTablet || model.contains('tablet') || model.startsWith('sm-x')) {
      debugPrint('Running on Android tablet');
    } else {
      debugPrint('Running on Android phone');
  }
  }

  if (PlatformUtils.isDesktop) {
    await DesktopInit.initialize();
  } else if (PlatformUtils.isMobile) {
    await MobileInit.initialize();
  }
  debugPrint('here');
  try {
    await ExcelHelper.deleteOldExportFiles();
  } catch (e) {
    debugPrint('Error deleting old export files: $e');
    CustomAlert.showCustomScaffoldMessenger(
      mainNavigatorKey.currentContext!,
      "Error deleting old export files: $e",
      AlertType.error,
    );
  }
  final themeProvider = ThemeNotifier();
  await themeProvider.readThemeMode();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => themeProvider,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
        authBloc.add(AuthCheckLoginStatus());
      } catch (e) {
        debugPrint('Error triggering auth check: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size designSize;
    if (PlatformUtils.isMobile) {
      designSize = const Size(430, 881.55);
    } else {
      designSize = const Size(1920, 1080);
    }
    debugPrint('designSize: $designSize');
    return ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          debugPrint('context: $context');
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
              
              if (state is AuthUnauthenticated) {
                
                dashboardBloc.currentFilters.clear();
                dashboardBloc.projects.clear();
                dashboardBloc.filterData = null;
                dashboardBloc.summaryData = null;
                dashboardBloc.devicesData = null;
                dashboardBloc.nudronChartData = null;
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = mainNavigatorKey.currentState;
                  if (navigator != null) {
                    
                    final currentRoute = ModalRoute.of(navigator.context)?.settings.name;
                    
                    if (currentRoute != '/') {
                      try {
                        navigator.pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              if (ConfigurationCustom.isTest) {
                                return ConfigurationCustom.testScreen;
                              }
                              return BlocBuilder<AuthBloc, AuthState>(
                                buildWhen: (previous, current) => true,
                                builder: (context, authState) {
                                  if (authState is AuthAuthenticated) {
                                    return BlocBuilder<DashboardBloc, DashboardState>(
                                      buildWhen: (previous, current) {
                                        return current is DashboardPageLoaded ||
                                               current is DashboardPageInitial ||
                                               current is DashboardPageError;
                                      },
                                      builder: (context, dashboardState) {
                                        final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
                                        
                                        if (dashboardState is DashboardPageInitial) {
                                          return const Scaffold(
                                            body: CustomSafeArea(child: Center(child: CustomLoader())),
                                          );
                                        }
                                        
                                        if (dashboardState is DashboardPageError) {
                                          if (dashboardBloc.projects.isNotEmpty) {
                                            return const ProjectSelectionPage();
                                          }
                                          return const Scaffold(
                                            body: CustomSafeArea(child: Center(child: CustomLoader())),
                                          );
                                        }
                                        
                                        if (dashboardBloc.currentFilters.isNotEmpty && dashboardBloc.projects.isNotEmpty) {
                                          return const MainDashboardPage();
                                        } else if (dashboardBloc.projects.isNotEmpty) {
                                          return const ProjectSelectionPage();
                                        } else {
                                          return const Scaffold(
                                            body: CustomSafeArea(child: Center(child: CustomLoader())),
                                          );
                                        }
                                      },
                                    );
                                  } else if (authState is AuthInitial || authState is AuthLoading) {
                                    return const Scaffold(
                                      body: CustomSafeArea(child: Center(child: CustomLoader())),
                                    );
                                  } else {
                                    return const LoginPage();
                                  }
                                },
                              );
                            },
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        debugPrint('Navigation error during logout: $e');
                      }
                    }
                    
                  }
                });
              } else if (state is AuthAuthenticated) {
                
                dashboardBloc.loadInitialData();
                
                // Show success message after navigation completes
                // Using postFrameCallback ensures the message displays after route changes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final context = mainNavigatorKey.currentContext;
                  if (context != null && scaffoldMessengerKey.currentState != null) {
                    CustomAlert.showCustomScaffoldMessenger(
                      context,
                      "Successfully logged in!",
                      AlertType.success,
                    );
                  }
                });
              } else if (state is AuthTwoFactorRequired) {
                // Handle 2FA navigation at app level to ensure it works properly
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = mainNavigatorKey.currentState;
                  if (navigator != null) {
                    final navigatorContext = navigator.context;
                    CustomAlert.showCustomScaffoldMessenger(
                        navigatorContext,
                        "Please enter the code sent to your authenticator app/sms",
                        AlertType.info);
                    navigator.push(MaterialPageRoute(
                        builder: (context) => EnterTwoFacCode(
                              referenceCode: state.refCode,
                            )));
                  }
                });
              }
            },
            child: MaterialApp(
              title: 'Meter Config',
              debugShowCheckedModeBanner: false,
              navigatorKey: mainNavigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            routes: {
              '/': (context) {
                if (ConfigurationCustom.isTest) {
                  return ConfigurationCustom.testScreen;
                }
                return BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) {
                    
                    return true;
                  },
                  builder: (context, authState) {
                    debugPrint('Auth state changed: $authState');
                    
                    if (authState is AuthAuthenticated) {
                      
                      return BlocBuilder<DashboardBloc, DashboardState>(
                        buildWhen: (previous, current) {
                          
                          return current is DashboardPageLoaded ||
                                 current is DashboardPageInitial ||
                                 current is DashboardPageError;
                        },
                        builder: (context, dashboardState) {
                          final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
                          
                          debugPrint('Dashboard state: $dashboardState, projects: ${dashboardBloc.projects.length}, filters: ${dashboardBloc.currentFilters.length}');
                          
                          if (dashboardState is DashboardPageInitial) {
                            return const Scaffold(
                              body: CustomSafeArea(
                                child: Center(
                                  child: CustomLoader(),
                                ),
                              ),
                            );
                          }
                          
                          if (dashboardState is DashboardPageError) {
                            
                            if (dashboardBloc.projects.isNotEmpty) {
                              return const ProjectSelectionPage();
                            }
                            
                            return const Scaffold(
                              body: CustomSafeArea(
                                child: Center(
                                  child: CustomLoader(),
                                ),
                              ),
                            );
                          }
                          
                          if (dashboardBloc.currentFilters.isNotEmpty && dashboardBloc.projects.isNotEmpty) {
                            
                            return const MainDashboardPage();
                          } else if (dashboardBloc.projects.isNotEmpty) {
                            
                            return const ProjectSelectionPage();
                          } else {
                            
                            return const Scaffold(
                              body: CustomSafeArea(
                                child: Center(
                                  child: CustomLoader(),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else if (authState is AuthInitial) {
                      
                      return const Scaffold(
                        body: CustomSafeArea(
                          child: Center(
                            child: CustomLoader(),
                          ),
                        ),
                      );
                    } else if (authState is AuthLoading) {
                      
                      return const Scaffold(
                        body: CustomSafeArea(
                          child: Center(
                            child: CustomLoader(),
                          ),
                        ),
                      );
                    } else if (authState is AuthTwoFactorRequired) {
                      // Show LoginPage - the 2FA screen will be pushed on top via navigation
                      return const LoginPage();
                    } else {
                      
                      return const LoginPage();
                    }
                  },
                );
              },
              '/login': (context) => const LoginPage(),
              '/homePage': (context) => const MainDashboardPage(),
              '/projectSelection': (context) => const ProjectSelectionPage(),
            },
            initialRoute: "/",
            ),
          );
        });
  }
}