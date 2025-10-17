import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ThemeType {
  Light,
  Dark,
}

class CustomThemeData {
  Color bgColor;
  Color gridLineColor;
  Color onSecondaryContainer;
  Color primaryContainer;
  Color profileChamferColor;
  Color loginTitleColor;
  Color dropDownColor;
  Color signInColor;
  Color pleaseSignInColor;
  Color gridHeadingColor;
  Color textFieldFillColor;
  Color textfieldTextColor;
  Color textfieldHintColor;
  Color textfieldCursorColor;
  Color bottomNavColor;
  Color headingColor;
  Color basicAdvanceTextColor;
  Color drawerHeadingColor;
  Color tableText;
  Color editIconColor;
  Color noEntriesColor;
  Color numberWheelSelectedBG;
  Color editIconBG;
  Color dialogBG;
  Color inactiveBottomNavbarIconColor;
  Color toggleColor;
  Color popupcolor;
  Color profileBorderColor;
  Color dropdownColor;
  Color textFieldBGProfile;
  Color calibrateTabBGColor;
  Color iconColor;
  Color splashColor;
  Color shadowColor; // Added shadow color property

  CustomThemeData(
      {required this.bgColor,
      required this.loginTitleColor,
      required this.signInColor,
      required this.tableText,
      required this.gridHeadingColor,
      required this.popupcolor,
      required this.noEntriesColor,
      required this.splashColor,
      required this.dropDownColor,
      required this.numberWheelSelectedBG,
      required this.toggleColor,
      required this.dialogBG,
      required this.dropdownColor,
      required this.bottomNavColor,
      required this.pleaseSignInColor,
      required this.iconColor,
      required this.profileChamferColor,
      required this.textFieldBGProfile,
      required this.editIconColor,
      required this.calibrateTabBGColor,
      required this.editIconBG,
      required this.textFieldFillColor,
      required this.onSecondaryContainer,
      required this.inactiveBottomNavbarIconColor,
      required this.primaryContainer,
      required this.drawerHeadingColor,
      required this.gridLineColor,
      required this.basicAdvanceTextColor,
      required this.textfieldTextColor,
      required this.profileBorderColor,
      required this.textfieldHintColor,
      required this.headingColor,
      required this.shadowColor,
      required this.textfieldCursorColor});
}

class CommonColors {
  // const Color(0xff45b4d9),
  // const Color(0xff00bc8a),
  // const Color(0xffe3b039),

  static const Color blue = Color(0xFF145166);
  static const Color red = Color(0xFFFF5353);
  static const Color green = Color(0xFF00bc8a);
  static const Color yellow = Color(0xFFDFAC46);
  static const Color blue2 = const Color(0xff45b4d9);
}

class ThemeNotifier with ChangeNotifier {
  CustomThemeData _currentTheme = _lightTheme;
  bool isDark = false;
  static double extrasmall = 14;
  static double small = 16;
  static double medium = 18;
  static double large = 20;

  static final CustomThemeData _lightTheme = CustomThemeData(
      bgColor: const Color(0XFFe5ebf0),
      bottomNavColor: const Color.fromRGBO(250, 250, 250, 1),
      textFieldFillColor: Colors.white,
      gridLineColor: const Color(0xff8C8C8C),
      loginTitleColor: const Color(0xff40434F),
      editIconColor: const Color(0xFF515151),
      editIconBG: const Color(0xFFCECECE),
      numberWheelSelectedBG: const Color(0xFFCECECE),
      tableText: const Color(0xff515151),
      dropdownColor: const Color(0xFFF5F5F5),
      primaryContainer: Colors.white,
      noEntriesColor: const Color(0xFFB0B0B0),
      dropDownColor: const Color(0xFFF5F5F5),
      onSecondaryContainer: const Color(0xffF2F2F2),
      dialogBG: const Color(0xFFF0F0F0),
      textFieldBGProfile: const Color(0xFFF2F2F2),
      popupcolor: const Color(0xFF2D2D2D),
      signInColor: const Color(0xFF515151),
      profileChamferColor: const Color(0XFFD4D4D4),
      calibrateTabBGColor: Colors.white,
      headingColor: const Color(0xFF525252),
      iconColor: const Color(0xFF5A5A5A),
      gridHeadingColor: const Color(0xFF383838),
      drawerHeadingColor: const Color(0xFF2D2D2D),
      profileBorderColor: const Color(0xFF747474),
      basicAdvanceTextColor: const Color(0xFF2D2D2D),
      inactiveBottomNavbarIconColor: const Color(0xFF4F4F4F),
      pleaseSignInColor: const Color(0xFF515151),
      toggleColor: const Color(0xFFCECACA),
      textfieldCursorColor: const Color(0xFFA9A9A9),
      splashColor: const Color(0x66c8c8c8).withOpacity(1),
      shadowColor: Colors.black.withOpacity(0.16), // Light theme shadow - subtle
      textfieldHintColor: const Color(0xFFAEAEAE),
      textfieldTextColor: const Color(0xFF646464));
      

  static final CustomThemeData _darkTheme = CustomThemeData(
      bottomNavColor: const Color(0xFF353535),
      tableText: const Color(0xFFEEE0CB),
      textFieldFillColor: const Color(0xff333742),
      bgColor: const Color(0xFF252525),
      headingColor: const Color(0xFFCFCFCF),
      dropdownColor: const Color(0xFF393939),
      editIconColor: const Color(0xFFEEE0CB),
      profileBorderColor: const Color(0xFF747474),
      textFieldBGProfile: const Color(0xFF373737),
      noEntriesColor: const Color(0XFF6B6B6B),
      popupcolor: const Color(0xFFB8B8B8),
      splashColor: const Color(0x66c8c8c8).withOpacity(0.1),
      editIconBG: const Color(0xFF595959),
      gridHeadingColor: const Color(0xFFDBDBDB),
      toggleColor: const Color(0xFF434343),
      dialogBG: Color(0xFF0A0A0A),
      loginTitleColor: const Color(0xffCCCDCD),
      inactiveBottomNavbarIconColor: const Color(0xFFDCDCDC),
      iconColor: const Color(0xFFA9A9A9),
      primaryContainer: const Color(0xFF2B2C2E),
      onSecondaryContainer: const Color(0xff3E4044).withOpacity(0.69),
      signInColor: const Color(0xFFEDEDED),
      profileChamferColor: const Color(0xFF3A3B3C),
      basicAdvanceTextColor: Colors.white,
      gridLineColor: const Color(0xFFB8B8B8),
      pleaseSignInColor: const Color(0xFFE7E7E7),
      calibrateTabBGColor: const Color(0xFF434343),
      drawerHeadingColor: const Color(0xFFCDCDCD),
      numberWheelSelectedBG: const Color(0xFF4F4F4F),
      textfieldCursorColor: const Color(0xFFA9A9A9),
      shadowColor: Colors.black.withOpacity(0.3), // Dark theme shadow - more pronounced
      textfieldHintColor: const Color(0xFFAEAEAE),
      dropDownColor: const Color(0xff393939),
      textfieldTextColor: Colors.white);

  storeThemeMode() {
    try {
      const FlutterSecureStorage()
          .write(key: 'themeMode', value: isDark.toString());
    } catch (e) {
      print(e);
    }
  }

  readThemeMode() async {
    // print("App Signature: ");
    // print(await SmsAutoFill().getAppSignature);

    try {
      String? themeModeString =
          await const FlutterSecureStorage().read(key: 'themeMode');
      if (themeModeString != null) {
        isDark = themeModeString == 'true';
      } else {
        if (ThemeMode.system == ThemeMode.dark) {
          isDark = true;
        }
      }
    } catch (e) {
      print(e);
    }

    setThemeMode();
  }

  setThemeMode() {
    if (isDark) {
      _currentTheme = _darkTheme;
    } else {
      _currentTheme = _lightTheme;
    }
    notifyListeners();
  }

  CustomThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    isDark = !isDark;
    storeThemeMode();
    setThemeMode();
  }
}
