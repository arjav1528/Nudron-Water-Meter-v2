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
      }
      
      // Initialize window manager with platform-specific handling
      await windowManager.ensureInitialized();
      
      // Platform-specific window options
      WindowOptions windowOptions;
      if (Platform.isMacOS) {
        // macOS-specific configuration
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
        // Windows/Linux configuration
        windowOptions = const WindowOptions(
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
          size: Size(1200, 800),
          minimumSize: Size(800, 600),
        );
      }
      
      // Use a more robust approach for window management
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        try {
          await windowManager.show();
          if (Platform.isMacOS) {
            // Add a small delay for macOS to ensure proper window state
            await Future.delayed(const Duration(milliseconds: 100));
          }
          await windowManager.focus();
        } catch (e) {
          // Fallback: just show without focus if there's an issue
          await windowManager.show();
        }
      });
    } catch (e) {
      // Log error for debugging but don't crash the app
      debugPrint('DesktopInit error: $e');
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
