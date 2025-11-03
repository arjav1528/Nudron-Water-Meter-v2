
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../services/app_state_service.dart';
import '../api/auth_service.dart';

class BiometricHelper {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Function to check if the device supports biometric authentication
  Future<bool> isBiometricSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Function to check if biometric authentication is set up on the device
  Future<bool> isBiometricSetup() async {
    try {
      bool canCheckBiometrics = await isBiometricSupported();
      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics =
            await _localAuth.getAvailableBiometrics();
        return availableBiometrics.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> getPassword() async {
    return await const FlutterSecureStorage().read(key: 'password') ?? '';
  }

  // Function to authenticate the user using biometrics
  Future<bool> authenticateWithBiometrics(
      {String reason = 'Authenticate to proceed'}) async {
    try {
      bool isSetup = await isBiometricSetup();
      if (!isSetup) return false;

      bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // Function to check if biometric authentication was successful
  Future<bool> isCorrectBiometric() async {
    try {
      return await authenticateWithBiometrics(
          reason: 'Authenticate to confirm your identity');
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleBiometric(bool value) async {
    NudronRandomStuff.isBiometricEnabled.value = value;
    await const FlutterSecureStorage()
        .write(key: 'biometric', value: value.toString());
  }

  static Future<String?> isBiometricEnabled() async {
    String? biometric = await const FlutterSecureStorage().read(key: 'biometric');
    String? email = await const FlutterSecureStorage().read(key: 'email');
    if (biometric != null && email != null && biometric == 'true' && LoginPostRequests.isLoggedIn==false) {
      return email;
    }
    return null;
  }

  static checkAndStoreBiometric(String email, String password) async {
    String? emailst = await const FlutterSecureStorage().read(key: 'email');
    if ((emailst != null && emailst != email) || emailst == null) {
      await const FlutterSecureStorage().delete(key: 'biometric');
    }
    await const FlutterSecureStorage().write(key: 'email', value: email);
    await const FlutterSecureStorage().write(key: 'password', value: password);
  }
}
