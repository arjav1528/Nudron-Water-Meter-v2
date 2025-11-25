import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../bloc/dashboard_bloc.dart';
import '../constants/app_config.dart';
import '../services/app_state_service.dart';
import '../services/platform_utils.dart';
import '../utils/biometric_helper.dart';
import '../utils/custom_exception.dart';
import '../utils/getDeviceID.dart';

class LoginPostRequests {
  static const String au1Url = 'https://api.nudron.com/prod/au1';
  static const String au3Url = 'https://api.nudron.com/prod/au3';
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static bool isLoggedIn = false;

  static Future<void> twoFAToggleVal(bool twoFAEnabled) async {
    await secureStorage.write(
        key: 'two_factor', value: twoFAEnabled.toString());
    NudronRandomStuff.isAuthEnabled.value = twoFAEnabled;
  }

  static Future<void> updateApp() async {
    if (Platform.isAndroid && kReleaseMode) {
      try {
        AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          try {
            AppUpdateResult result = await InAppUpdate.performImmediateUpdate();
            if (result == AppUpdateResult.inAppUpdateFailed) {
              await InAppUpdate.startFlexibleUpdate();
            }
          } catch (e) {
            rethrow;
          }
        }
      } catch (e) {
        await deleteDataAndLogout();
        throw CustomException(
            "Redirecting to login page.. Please update app and login again");
      }
    }
  }

  static Future<Map<dynamic, dynamic>> tokenCheck() async {
    if (ConfigurationCustom.skipAnyAuths) {
      return {
        "email": "johndoe@email..com",
        "emailVerified": true,
        "lastPassChange": "1720594664724",
        "lastUpdate": 1720967774113,
        "multiFactor": "0",
        "name": "John Doe",
        "phone": "+919845888888",
        "phoneVerified": true,
        "userID": "16170205-548a-487b-b9ee-4abdb624c550"
      };
    }
    const body = '07';

    final response = await _makeRequest(body, url: au3Url);
    return jsonDecode(response);
  }

  static Future<void> refreshListeners() async {
    try {
      
      String? twoFactorEnabled = await secureStorage.read(key: 'two_factor').timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
      NudronRandomStuff.isAuthEnabled.value = twoFactorEnabled == 'true';

      String? biometricEnabled = await secureStorage.read(key: 'biometric').timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
      NudronRandomStuff.isBiometricEnabled.value = biometricEnabled == 'true';
    } catch (e) {

    }
  }

  static Future<void> checkLogin() async {
    try {
      await getAccessToken2();
      await refreshListeners();
      isLoggedIn = true;
    } catch (e) {
      isLoggedIn = false;
    }
  }

  static Future<String?> getAccessToken2() async {
    
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null || isTokenExpired(accessToken)) {
        
        return getNewAccessToken();
      } else if (isTokenExpiring(accessToken)) {
        
        Future.delayed(const Duration(seconds: 10), () async {
          
          await getNewAccessToken();
        });
        
        return accessToken;
      }
      if (kDebugMode) {
      }
      return accessToken;
    } catch (e) {
      
      await deleteDataAndLogout();
      throw CustomException('Please login again');
    }
  }

  static DateTime getExpiryTime(String accessToken) {
    String payloadBase64 = accessToken.split('.')[1];
    String normalizedBase64 = base64.normalize(payloadBase64);

    String decodedToken = utf8.decode(base64.decode(normalizedBase64));
    Map<String, dynamic> tokenData = json.decode(decodedToken);
    int expiryTime = tokenData['exp'];

    return DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000);
  }

  static bool isTokenExpired(String accessToken) {
    DateTime expiryDateTime = getExpiryTime(accessToken);
    DateTime now = DateTime.now(); 
    
    return now.add(const Duration(seconds: 0)).isAfter(expiryDateTime);
  }

  static bool isTokenExpiring(String accessToken) {
    
    DateTime expiryDateTime = getExpiryTime(accessToken);
    DateTime now = DateTime.now(); 
    return now.add(const Duration(minutes: 30)).isAfter(expiryDateTime);
  }

  static Future<String?> getRefreshToken() async {
    String? refreshToken = await secureStorage.read(key: 'refresh_token');
    return refreshToken;
  }

  static Future<int> signUp(
      String actCode, String fullName, String email, String phone) async {
    final body = '00$actCode|$fullName|$email|$phone';
    final response = await _makeRequest(body);
    try {
      await SmsAutoFill().listenForCode();
    } catch (e) {
    }

    if (response == '0') {
      throw CustomException('Email already in use');
    }
    return int.parse(response);
  }

  static Future<String> contactVerification(
      String actCode, String pass, String emCode, String phCode) async {
    if (pass.length < 8) {
      throw CustomException('Password must be at least 8 characters');
    }
    final passwordBase64 = base64.encode(utf8.encode(pass));

    final body = '01$actCode|$passwordBase64|$emCode|$phCode';
    final response = await _makeRequest(body);
    if (response == '0') {
      throw CustomException('Incorrect email or phone code');
    }
    return response;
  }

  static Future<String?> login(String email, String password) async {
    if (ConfigurationCustom.skipAnyAuths) {
      return null;
    }
    
    final passwordBase64 = base64.encode(utf8.encode(password));

    final body = '02$email|$passwordBase64';

    final response = await _makeRequest(body);
    final splitResponse = response.split('|');
    if (response == '0') {
      throw CustomException('Incorrect email or password');
    } else if (response == '10' || response == '01' || response == '00') {
      throw CustomException('Email or phone unverified');
    } else if (splitResponse.length == 2) {
      await BiometricHelper.checkAndStoreBiometric(email, password);
      await secureStorage.write(key: 'access_token', value: splitResponse[0]);
      await secureStorage.write(key: 'refresh_token', value: splitResponse[1]);
      await secureStorage.write(key: 'email', value: email);
      await secureStorage.write(key: 'password', value: password);
      await twoFAToggleVal(false);
    } else if (splitResponse.length == 1) {
      try {
        await SmsAutoFill().listenForCode();
      } catch (e) {
      }
      await BiometricHelper.checkAndStoreBiometric(email, password);
      return response;
    } else {
      
      throw CustomException('Unexpected response');
    }
    return null;
  }

  static Future<void> sendTwoFactorCode(
      String refCode, String twoFactorCode) async {
    final body = '03$refCode|$twoFactorCode';
    
    final response = await _makeRequest(body);
    final splitResponse = response.split('|');
    if (response == '0') {
      throw CustomException('Incorrect code');
    } else if (response == '1') {
      throw CustomException('Code expired');
    } else if (splitResponse.length == 2) {
      await secureStorage.write(key: 'access_token', value: splitResponse[0]);
      await secureStorage.write(key: 'refresh_token', value: splitResponse[1]);
      await twoFAToggleVal(true);
    } else {
      throw CustomException('Unexpected response');
    }
  }

  static Future<String> getNewAccessToken() async {
    String? refToken = await getRefreshToken();
    if (refToken == null) {
      
      await deleteDataAndLogout();
      throw CustomException('Session expired. Please login again.');
    }

    final body = '04$refToken';
    final response = await _makeRequest(body);
    final splitResponse = response.split('|');
    if (response == '0') {
      await deleteDataAndLogout();
      throw CustomException('Session expired. Please login again.');
    } else if (splitResponse.length == 2) {
      
      await secureStorage.write(key: 'access_token', value: splitResponse[0]);
      await secureStorage.write(key: 'refresh_token', value: splitResponse[1]);
      DashboardBloc.toUpdateProfile.notifyListeners();
      return splitResponse[0];
    } else {
      await deleteDataAndLogout();
      throw CustomException('Unexpected response. Please login again.');
    }
  }

  static Future<int> forgotPassword(String email) async {
    final body = '05$email';
    final response = await _makeRequest(body);
    if (response == '0') {
      throw CustomException('Error processing request');
    }
    return int.parse(response);
  }

  static Future<String> updateInfo(String oldPass, String fullName,
      String email, String phone, String newPass) async {
    final oldPassB64 = base64.encode(utf8.encode(oldPass));
    final newPassB64 = base64.encode(utf8.encode(newPass));

    final body = '00$oldPassB64|$fullName|$email|$phone|$newPassB64';
    final response = await _makeRequest(body, url: au3Url);

    if (response == '0') {
      throw CustomException('Incorrect old password');
    } else if (response == '1') {
      throw CustomException('Email already in use');
    } else if (response == '2') {
      throw CustomException('Number already in use');
    } else {
      return "Success";
    }
  }

  static Future<String> addProject(String activationCode) async {
    final body = '04$activationCode';
    final response = await _makeRequest(body, url: au3Url);

    if (response == '0') {
      throw CustomException('Incorrect activation code. Please check again');
    } else {
      return response;
    }
  }

  static Future<String> verifyEmailPhone(String emCode, String phCode) async {
    final body = '10$emCode|$phCode';
    final response = await _makeRequest(body, url: au3Url);
    if (response == '00' ||
        response == '02' ||
        response == '10' ||
        response == '01') {
      if (emCode.isNotEmpty) responseHandler(response[0], "Email");
      if (phCode.isNotEmpty) responseHandler(response[1], "Phone");
      return "Email and Phone number verified!";
    } else {
      throw CustomException('Unexpected response');
    }
  }

  static String responseHandler(String response, String emailOrPhone) {
    if (response == '0') {
      throw CustomException('Incorrect code for $emailOrPhone');
    } else if (response == '2') {
      throw CustomException('The code is expired for $emailOrPhone');
    }
    return response;
  }

  static Future<List<String?>> enableTwoFactorAuth(int mode) async {
    final body = '02$mode';
    final response = await _makeRequest(body, url: au3Url);

    if (response == '0') {
      throw CustomException('Error processing request');
    }
    twoFAToggleVal(true);

    if (mode == 2) {
      return [null, null]; 
    }

    List<String?> responseValues = response.split('|');
    
    return responseValues;
  }

  static Future<void> disableTwoFactorAuth() async {
    const body = '03';
    await _makeRequest(body, url: au3Url);
    twoFAToggleVal(false);
  }

  static deleteStoredData() async {
    isLoggedIn = false;
    try {
      
      String? biometricEnabled = await secureStorage.read(key: 'biometric');
      String? themeMode = await secureStorage.read(key: 'themeMode');
      String? email = await secureStorage.read(key: 'email');
      String? password = await secureStorage.read(key: 'password');
      
      final shouldPreserveBiometric = biometricEnabled == 'true';
      
      final allKeys = {
        'access_token',
        'refresh_token',
        'two_factor',
      };
      
      for (final key in allKeys) {
        try {
          await secureStorage.delete(key: key);
        } catch (e) {
          
        }
      }
      
      if (!shouldPreserveBiometric) {
        try {
          await secureStorage.delete(key: 'email');
          await secureStorage.delete(key: 'password');
          await secureStorage.delete(key: 'biometric');
        } catch (e) {
          
        }
      } else {
        
        if (email != null && password != null) {
          try {
            await secureStorage.write(key: 'email', value: email);
            await secureStorage.write(key: 'password', value: password);
            await secureStorage.write(key: 'biometric', value: 'true');
          } catch (e) {
            
          }
        }
      }
      
      if (themeMode != null) {
        try {
          await secureStorage.write(key: 'themeMode', value: themeMode);
        } catch (e) {
          
        }
      }
    } catch (e) {
      
    }
  }

  static Future<void> deleteDataAndLogout() async {
    await deleteStoredData();
    
  }

  static Future<int> logout() async {
    const body = '08';
    if (kDebugMode) {
    }

    final response = await _makeRequest(body, url: au3Url);
    if (response == '0') {
      throw CustomException('Error processing request');
    }
    await deleteDataAndLogout();
    return int.parse(response);
  }

  static Future<int> globalLogout() async {
    const body = '09';
    final response = await _makeRequest(body, url: au3Url);
    if (response == '0') {
      throw CustomException('Error processing request');
    }
    await deleteDataAndLogout();
    return int.parse(response);
  }

  static Future<int> deleteAccount() async {
    const body = '05';
    final response = await _makeRequest(body, url: au3Url);
    if (response == '0') {
      throw CustomException('Error processing request');
    }
    await deleteDataAndLogout();
    return int.parse(response);
  }

  static Future<String> _makeRequest(String body,
      {String url = au1Url, Duration? timeout}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw CustomException('No internet connection');
    }
    
    const int maxRetries = 3;
    const Duration initialRetryDelay = Duration(seconds: 1);
    const Duration totalTimeout = Duration(seconds: 5);
    final effectiveTimeout = timeout ?? Duration(milliseconds: (totalTimeout.inMilliseconds / maxRetries).round());
    
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        final jwt = (url == au3Url) ? await getAccessToken2() : null;
        String userAgent = await DeviceInfoUtil.getUserAgent();

        final headers = {
          'User-Agent': userAgent,
          'medium': 'phone',
          'Content-Type': 'text/plain',
          if (jwt != null) 'Authorization': 'Bearer $jwt',
          if (url == au1Url) 'tenantID': "d14b3819-5e90-4b1e-8821-9fcb72684627",
          if (url == au1Url) 'clientID': PlatformUtils.isDesktop ? 'WaterMeteringDesktop' : 'WaterMeteringMobile2',
        };
        var request = http.Request('POST', Uri.parse(url));
        request.body = body;
        request.headers.addAll(headers);
        
        http.StreamedResponse response = 
            await request.send().timeout(effectiveTimeout);

        if (response.statusCode == 200) {
          
          var resp = await response.stream.bytesToString().timeout(effectiveTimeout);
          return resp;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          await deleteDataAndLogout();
          throw CustomException('Redirecting to login page.. Please login again');
        } else {
          String responseBody = await response.stream.bytesToString().timeout(const Duration(seconds: 5));
          throw CustomException(responseBody);
        }
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        if (attempt < maxRetries) {
          
          final delay = Duration(seconds: initialRetryDelay.inSeconds * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
        throw CustomException('Request timed out after $maxRetries attempts');
      } on SocketException catch (e) {
        lastException = e;
        attempt++;
        if (attempt < maxRetries) {
          
          final delay = Duration(seconds: initialRetryDelay.inSeconds * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
        throw CustomException('Network connection failed: ${e.message}');
      } catch (e) {
        
        if (e is CustomException && e.message.contains('login')) {
          rethrow;
        }
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;
        if (attempt < maxRetries) {
          final delay = Duration(seconds: initialRetryDelay.inSeconds * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
        throw CustomException('Network error: ${e.toString()}');
      }
    }
    
    throw CustomException('Network error after $maxRetries attempts: ${lastException?.toString()}');
  }
}