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
  
  if (PlatformUtils.isDesktop) {
    await DesktopInit.initialize();
  } else if (PlatformUtils.isMobile) {
    await MobileInit.initialize();
  }
  
  try {
    await ExcelHelper.deleteOldExportFiles();
  } catch (e) {
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
  @override
  void initState() {
    super.initState();
    // Trigger initial authentication check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
      authBloc.add(AuthCheckLoginStatus());
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
                    if (state is AuthAuthenticated) {
                      return const DashboardPage();
                    } else if (state is AuthLoading) {
                      // Show loading screen while checking authentication
                      return const Scaffold(
                        body: Center(
                          child: CustomLoader(),
                        ),
                      );
                    } else {
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