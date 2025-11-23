import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DesktopInit {
  static Future<void> initialize() async {
    try {
      
      try {
        final data = await PlatformAssetBundle().load("assets/ca/AmazonRootCA1.pem");
        SecurityContext.defaultContext
            .setTrustedCertificatesBytes(data.buffer.asUint8List());
      } catch (e) {
      }
      
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions;
      if (Platform.isMacOS) {
        
        windowOptions = const WindowOptions(
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
          windowButtonVisibility: true,
          alwaysOnTop: false,
          fullScreen: false,
          size: Size(1200, 800),
          minimumSize: Size(800, 600),
        );
      } else {
        
        windowOptions = const WindowOptions(
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
          size: Size(1200, 800),
          minimumSize: Size(800, 600),
        );
      }
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        try {
          await windowManager.show();
          if (Platform.isMacOS) {
            
            await Future.delayed(const Duration(milliseconds: 100));
          }
          await windowManager.focus();
        } catch (e) {
          
          await windowManager.show();
        }
      });
    } catch (e) {
      
      debugPrint('DesktopInit error: $e');
    }
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
