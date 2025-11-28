import 'package:flutter/cupertino.dart';

import '../api/auth_service.dart';

enum TwoFactorMethod { authenticator, sms }

class NudronRandomStuff {
  static ValueNotifier<bool> isAuthEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<bool> isBiometricEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<TwoFactorMethod?> twoFactorMethod =
      ValueNotifier<TwoFactorMethod?>(null);
  static ValueNotifier<String> dropDownValueForSortBy = ValueNotifier("Dues");
  static ValueNotifier<bool> isSignIn = ValueNotifier(true);

  static Future<void> logout() async {
    await LoginPostRequests.logout();
  }
}
