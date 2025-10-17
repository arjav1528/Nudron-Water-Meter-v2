import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DesktopInit {
  static Future<void> initialize() async {
    try {
      // Desktop-specific initialization
      // Try to load certificate file if it exists
      try {
        final data = await PlatformAssetBundle().load("assets/ca/AmazonRootCA1.pem");
        SecurityContext.defaultContext
            .setTrustedCertificatesBytes(data.buffer.asUint8List());
      } catch (e) {
        print('Warning: Could not load certificate file: $e');
      }
      
      // Initialize window manager
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      print('Warning: Desktop initialization failed: $e');
    }
    
    // Desktop allows all orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
