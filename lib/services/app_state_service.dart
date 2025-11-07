import 'package:flutter/cupertino.dart';

import '../api/auth_service.dart';

class NudronRandomStuff {
  static ValueNotifier<bool> isAuthEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<bool> isBiometricEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<String> dropDownValueForSortBy = ValueNotifier("Dues");
  static ValueNotifier<bool> isSignIn = ValueNotifier(true);

  static Future<void> logout() async {
    
      await LoginPostRequests.logout();
    
  }
}
