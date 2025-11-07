import 'package:flutter/services.dart';

class MobileInit {
  static Future<void> initialize() async {
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}
