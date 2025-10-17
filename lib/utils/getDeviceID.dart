import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceInfoUtil {
  static String _deviceName = 'WaterMeteringMobile2';
  static String _deviceVersion = 'Unknown';

  // A private method to get device info, only called on first-time access
  static Future<void> _initDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;

        _deviceVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.name;
        _deviceVersion = 'iOS ${iosInfo.systemVersion}';
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        _deviceName = windowsInfo.computerName;
        _deviceVersion = windowsInfo.editionId; // Customize as needed
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        _deviceName = macInfo.model;
        _deviceVersion = macInfo.osRelease;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        _deviceName = linuxInfo.prettyName;
        _deviceVersion = linuxInfo.id;
      } else if (Platform.isFuchsia) {
        _deviceName = 'Fuchsia Device';
        _deviceVersion = 'Fuchsia';
      }
    } catch (e) {
      // If any error occurs, keep the default values
      _deviceName = 'WaterMeteringMobile2';
      _deviceVersion = 'Unknown';
    }
  }

  // Static method to get device name
  static Future<String> getUserAgent() async {
    if (_deviceName == 'WaterMeteringMobile2' || _deviceName == 'Unknown') {
      await _initDeviceInfo();
    }
    return '${_deviceName}\/$_deviceVersion';
  }
}
