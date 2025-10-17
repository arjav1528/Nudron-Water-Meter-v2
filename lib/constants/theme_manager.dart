// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   ThemeMode themeMode = ThemeMode.system;
//   List<double> scaleFactorRow = [1, 30];
//   String dropDownValueForTextSize = "Small";
//
//   bool get isDarkMode {
//     if (themeMode == ThemeMode.system) {
//       final brightness = SchedulerBinding.instance.window.platformBrightness;
//       return brightness == Brightness.dark;
//     } else {
//       return themeMode == ThemeMode.dark;
//     }
//   }
//
//   storeThemeMode() {
//     FlutterSecureStorage().write(key: 'themeMode', value: themeMode.toString());
//   }
//
//   readThemeMode() async {
//     try {
//       String? themeModeString =
//           await FlutterSecureStorage().read(key: 'themeMode');
//       if (themeModeString != null) {
//         themeMode = themeModeString == 'ThemeMode.dark'
//             ? ThemeMode.dark
//             : ThemeMode.light;
//       } else {
//         themeMode = ThemeMode.system;
//       }
//     } catch (e) {
//       themeMode = ThemeMode.system;
//     }
//   }
//
//   void setScaleFactor(double factor, double rowSize) {
//     if (kDebugMode) {
//       print("Factor :- $factor");
//     }
//     scaleFactorRow = [factor, rowSize];
//     notifyListeners();
//   }
//
//   void toggleTheme(bool isOn) {
//     themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     storeThemeMode();
//     notifyListeners();
//   }
//
//   void setDropDownByTextSize(String dropDownForSize) {
//     // print(label);
//     dropDownValueForTextSize = dropDownForSize;
//     notifyListeners();
//   }
// }
//
// class MyThemes {
//   static const red = Color(0xffff5b5b);
//   static const green = Color(0xff00bc8a);
//   static const blue = Color(0xff45b4d9);
//
//   static final darkTheme = ThemeData(
//     scaffoldBackgroundColor: const Color(0xff25282c),
//     primaryColor: Colors.black,
//     dialogBackgroundColor: const Color(0xff373c4a),
//     iconTheme: const IconThemeData(
//       color: Color(0xffced4da),
//     ),
//     drawerTheme: const DrawerThemeData(backgroundColor: Color(0xff373b4a)),
//     textSelectionTheme: const TextSelectionThemeData(
//       cursorColor: Color(0xfff9fafb),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(2),
//         ),
//         elevation: 0,
//         backgroundColor: const Color(0xff19647e),
//         padding: EdgeInsets.zero,
//         splashFactory: InkRipple.splashFactory, // This adds a ripple effect
//       ).copyWith(
//         overlayColor: MaterialStateProperty.resolveWith<Color?>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.pressed)) {
//               return Colors.white.withOpacity(0.3); // Custom splash color
//             }
//             return null; // Use default splash color for other states
//           },
//         ),
//       ),
//     ),
//     textTheme: const TextTheme(
//       titleSmall: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffaab8c5),
//           fontSize: 14,
//           fontWeight: FontWeight.bold),
//       titleLarge: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffaab8c5),
//           fontSize: 18,
//           fontWeight: FontWeight.bold),
//       bodyLarge: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffaab8c5),
//           fontSize: 16,
//           decoration: TextDecoration.none),
//       bodyMedium: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffaab8c5),
//           fontSize: 14,
//           decoration: TextDecoration.none),
//       titleMedium: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffaab8c5),
//           fontSize: 18,
//           decoration: TextDecoration.none),
//       bodySmall: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xff8391a2),
//           fontSize: 8,
//           decoration: TextDecoration.none),
//       labelLarge: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xffffffff),
//           fontSize: 10,
//           decoration: TextDecoration.none),
//     ),
//     colorScheme: const ColorScheme.dark(
//       primaryContainer: Color(0xff323741),
//       onPrimaryContainer: Color(0xff464c5b),
//       onSecondaryContainer: Color(0xff2b2f37),
//       tertiaryContainer: Color(0xff373c4a),
//       onTertiary: Color(0xffaab8c5),
//       onBackground: Color(0xff323a46),
//       secondaryContainer: Color(0xff675835),
//       onTertiaryContainer: Color(0xff1a5c50),
//       onSurfaceVariant: Color(0xff7d8691),
//       onSecondary: Colors.white,
//       onPrimary: Color(0xff3d3c4f),
//     ).copyWith(background: const Color(0xff25282c)),
//   );
//
//   static final lightTheme = ThemeData(
//     scaffoldBackgroundColor: const Color(0xffe4ecf1),
//     primaryColor: Colors.white,
//     dialogBackgroundColor: const Color(0xfff1f3fa),
//     drawerTheme: const DrawerThemeData(backgroundColor: Color(0xfff9fafb)),
//     iconTheme: const IconThemeData(
//       color: Color(0xff323a46),
//     ),
//     textSelectionTheme: const TextSelectionThemeData(
//       cursorColor: Color(0xff323a46),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(2),
//           ),
//           elevation: 0,
//           backgroundColor: const Color(0xff19647e),
//           padding: EdgeInsets.zero),
//     ),
//     textTheme: const TextTheme(
//       titleSmall: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xff323a46),
//           fontSize: 14,
//           fontWeight: FontWeight.bold),
//       titleLarge: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xff323a46),
//           fontSize: 18,
//           fontWeight: FontWeight.bold),
//       bodyLarge: TextStyle(
//           fontFamily: 'Roboto',
//           color: Color(0xff323a46),
//           fontSize: 16,
//           fontWeight: FontWeight.w400),
//       labelLarge: TextStyle(
//           fontFamily: 'Roboto', color: Color(0xff323a46), fontSize: 10),
//       bodyMedium: TextStyle(
//           fontFamily: 'Roboto', color: Color(0xff323a46), fontSize: 14),
//       titleMedium: TextStyle(
//           fontFamily: 'Roboto', color: Color(0xff323a46), fontSize: 18),
//       bodySmall: TextStyle(
//           fontFamily: 'Roboto', color: Color(0xff98a6ad), fontSize: 8),
//     ),
//     colorScheme: const ColorScheme.light(
//             primaryContainer: Color(0xffffffff),
//             onPrimaryContainer: Color(0xffdee2e6),
//             onSecondaryContainer: Color(0xfff2f2f2),
//             tertiaryContainer: Color(0xfff1f3fa),
//             onTertiary: Color(0xff323a46),
//             onBackground: Color(0xfff1f3fa),
//             secondaryContainer: Color(0xffe8d4a7),
//             onTertiaryContainer: Color(0xff91d8c5),
//             onSurfaceVariant: Color(0xff7d8691),
//             onSecondary: Color(0xff6c7179),
//             onPrimary: Color(0xfff3eafd))
//         .copyWith(background: const Color(0xffe4ecf1)),
//   );
// }
