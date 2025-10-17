import 'package:flutter/services.dart';

class MobileInit {
  static Future<void> initialize() async {
    // Mobile-specific initialization
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}
