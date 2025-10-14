import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'theme.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeNotifier();
  await themeProvider.readThemeMode();
 
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Size? size;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    super.initState();
    setState(() {
      if (Platform.isAndroid || Platform.isIOS) {
        size = Size(430, 881.55);
      } else {
        size = Size(1920, 1080);
      }
    });
    

  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: size!,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          home: child,
        );
      },
      child: MaterialApp(
        title: "Meter Config",
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        

      ),
      
      
    );
  }
}