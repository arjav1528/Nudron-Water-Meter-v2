import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watermeter2/bloc/dashboard_bloc.dart';
import 'package:watermeter2/utils/excel_helpers.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/services/mobile/mobile_init.dart';
import 'package:watermeter2/services/desktop/desktop_init.dart';
import 'package:watermeter2/constants/theme2.dart';
import 'package:watermeter2/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/constants/app_config.dart';
import 'package:watermeter2/api/auth_service.dart';
import 'package:watermeter2/screens/auth/login_screen.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Platform-specific initialization
  if (PlatformUtils.isDesktop) {
    await DesktopInit.initialize();
  } else if (PlatformUtils.isMobile) {
    await MobileInit.initialize();
  }
  
  try {
    await ExcelHelper.deleteOldExportFiles();
  } catch (e) {
    print('Warning: Could not delete old export files: $e');
  }
  final themeProvider = ThemeNotifier();
  await themeProvider.readThemeMode();
  
  runApp(
    BlocProvider<DashboardBloc>(
      create: (context) => DashboardBloc(),
      child: ChangeNotifierProvider(
        create: (_) => themeProvider,
        child: const MyApp(),
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
  checkLogin() async {
    await LoginPostRequests.checkLogin();
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Determine design size based on platform
    Size designSize;
    if (PlatformUtils.isMobile) {
      designSize = const Size(430, 881.55); // Mobile
    } else {
      designSize = const Size(1920, 1080); // Desktop
    }

    return ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Meter Config',
            debugShowCheckedModeBanner: false,
            navigatorKey: mainNavigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            builder: (context, child) {
              return MediaQuery(
                child: child!,
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
              );
            },
            routes: {
              '/': (context) {
                if (ConfigurationCustom.isTest) {
                  return ConfigurationCustom.testScreen;
                }
                if (LoginPostRequests.isLoggedIn) {
                  return const DashboardPage();
                } else {
                  return const LoginPage();
                }
              },
              '/login': (context) => const LoginPage(),
              '/homePage': (context) => const DashboardPage(),
            },
            initialRoute: "/",
          );
        });
  }
}