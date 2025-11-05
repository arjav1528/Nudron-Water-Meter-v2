import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watermeter2/bloc/dashboard_bloc.dart';
import 'package:watermeter2/bloc/auth_bloc.dart';
import 'package:watermeter2/bloc/auth_state.dart';
import 'package:watermeter2/bloc/auth_event.dart';
import 'package:watermeter2/utils/excel_helpers.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/services/mobile/mobile_init.dart';
import 'package:watermeter2/services/desktop/desktop_init.dart';
import 'package:watermeter2/constants/theme2.dart';
import 'package:watermeter2/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/constants/app_config.dart';
import 'package:watermeter2/screens/auth/login_screen.dart';
import 'package:watermeter2/utils/loader.dart';

import 'utils/alert_message.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPrint('PlatformUtils.isDesktop: ${PlatformUtils.isDesktop}');
  // debugPrint('PlatformUtils.isMobile: ${PlatformUtils.isMobile}');
  // debugPrint("Current os  : ${Platform.environment}");
  if(Platform.isIOS){
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    debugPrint('Running on ${iosInfo.utsname.machine}');
  }
  if(Platform.isAndroid){
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final model = androidInfo.model.toLowerCase();
    final features = androidInfo.systemFeatures.join(',');

    // Heuristic: tablets often have no telephony and larger screens
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
    // Trigger initial authentication check
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
          return MaterialApp(
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
                  builder: (context, state) {
                    debugPrint('Auth state: $state');
                    
                    if (state is AuthAuthenticated) {
                      // User is authenticated, show dashboard
                      return const DashboardPage();
                    } else if (state is AuthInitial) {
                      // Initial state - show a minimal loading indicator
                      // This should only appear for a split second
                      return const Scaffold(
                        body: Center(
                          child: CustomLoader(),
                        ),
                      );
                    } else if (state is AuthLoading) {
                      // Loading during login/logout operations
                      // Show loading screen
                      return const Scaffold(
                        body: Center(
                          child: CustomLoader(),
                        ),
                      );
                    } else {
                      // AuthUnauthenticated or any other state - show login
                      return const LoginPage();
                    }
                  },
                );
              },
              '/login': (context) => const LoginPage(),
              '/homePage': (context) => const DashboardPage(),
            },
            initialRoute: "/",
          );
        });
  }
}