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
import '../main.dart';
import '../services/app_state_service.dart';
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
      String? twoFactorEnabled = await secureStorage.read(key: 'two_factor');
      NudronRandomStuff.isAuthEnabled.value = twoFactorEnabled == 'true';

      String? biometricEnabled = await secureStorage.read(key: 'biometric');
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

    // Return the expiry time as a DateTime object
    return DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000);
  }

  static bool isTokenExpired(String accessToken) {
    DateTime expiryDateTime = getExpiryTime(accessToken);
    DateTime now = DateTime.now(); // use UTC time for comparisons
    // return now.add(const Duration(seconds: 30)).isAfter(expiryDateTime);

    return now.add(const Duration(seconds: 0)).isAfter(expiryDateTime);
  }

  static bool isTokenExpiring(String accessToken) {
    // return true;
    DateTime expiryDateTime = getExpiryTime(accessToken);
    DateTime now = DateTime.now(); // use UTC time for comparisons
    return now.add(const Duration(minutes: 30)).isAfter(expiryDateTime);
  }

  static Future<String?> getRefreshToken() async {
    String? refreshToken = await secureStorage.read(key: 'refresh_token');
    return refreshToken;
  }

  /// signUp function
  /// Returns: timestamp if successful, otherwise throws an CustomException
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

  /// contactVerification function
  /// Returns: timestamp if successful, otherwise throws an CustomException
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

  /// login function
  /// Stores access_token and refresh_token using Flutter Secure Storage if successful,
  /// otherwise throws an CustomException

  static Future<String?> login(String email, String password) async {
    if (ConfigurationCustom.skipAnyAuths) {
      return null;
    }
    //convert password to base64
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

  // static Future<void> acceptTwoFactorCode(String twoFactorCode)
  // {
  //
  // }

  /// sendTwoFactorCode function
  /// Stores access_token and refresh_token using Flutter Secure Storage if successful,
  /// otherwise throws an CustomException
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

  /// getNewAccessToken function
  /// Stores new access_token and refresh_token using Flutter Secure Storage if successful,
  /// otherwise throws an CustomException
  static Future<String> getNewAccessToken() async {
    String? refToken = await getRefreshToken();
    if (refToken == null) {
      // If refresh token is missing, force logout
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
      // Always save both tokens after refresh
      await secureStorage.write(key: 'access_token', value: splitResponse[0]);
      await secureStorage.write(key: 'refresh_token', value: splitResponse[1]);
      DashboardBloc.toUpdateProfile.notifyListeners();
      return splitResponse[0];
    } else {
      await deleteDataAndLogout();
      throw CustomException('Unexpected response. Please login again.');
    }
  }

  /// forgotPassword function
  /// Returns: timestamp if successful, otherwise throws an CustomException
  static Future<int> forgotPassword(String email) async {
    final body = '05$email';
    final response = await _makeRequest(body);
    if (response == '0') {
      throw CustomException('Error processing request');
    }
    return int.parse(response);
  }

  /// updateInfo function
  /// Returns: timestamp if successful, otherwise throws an CustomException
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

  /// verifyEmailPhone function
  /// Returns: a string representing the verification status (00, 01, 02, or 10),
  ///  (0-incorrect code, 1-correct, 2-expired)
  /// otherwise throws an CustomException

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

  /// enableTwoFactorAuth function
  /// Returns: a Base64-encoded PNG image string (for app) or timestamp (for SMS) if successful,
  /// otherwise throws an CustomException
  /// mode: 2 for SMS, 10(light)/11(dark) for app
  static Future<List<String?>> enableTwoFactorAuth(int mode) async {
    final body = '02$mode';
    final response = await _makeRequest(body, url: au3Url);

    if (response == '0') {
      throw CustomException('Error processing request');
    }
    twoFAToggleVal(true);

    if (mode == 2) {
      return [null, null]; // Return null values if mode is 0
    }

    // Split the response by '|' and return the resulting list. first is the base64 image, second is the clickable url
    List<String?> responseValues = response.split('|');
    
    return responseValues;
  }

  /// disableTwoFactorAuth function
  /// Returns: void, throws an CustomException if there's an issue with the request
  static Future<void> disableTwoFactorAuth() async {
    const body = '03';
    await _makeRequest(body, url: au3Url);
    twoFAToggleVal(false);
  }

  static deleteStoredData() async {
    isLoggedIn = false;
    //check if biometric is enabled
    String? biometricEnabled = await secureStorage.read(key: 'biometric');
    String? themeMode = await secureStorage.read(key: 'themeMode');
    if (biometricEnabled == 'true') {
      //read key user and pwd
      String? email = await secureStorage.read(key: 'email');
      String? password = await secureStorage.read(key: 'password');
      //delete all except these 3 keys
      await secureStorage.deleteAll();
      //write back email and password
      await secureStorage.write(key: 'email', value: email);
      await secureStorage.write(key: 'password', value: password);
      await secureStorage.write(key: 'biometric', value: 'true');
    } else {
      await secureStorage.deleteAll();
    }
    if (themeMode != null) {
      await secureStorage.write(key: 'themeMode', value: themeMode);
    }
  }

  static Future<void> deleteDataAndLogout() async {
    await deleteStoredData();
    mainNavigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// logout function
  /// Returns: timestamp if successful, otherwise throws an CustomException
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

  /// globalLogout function
  /// Returns: timestamp if successful, otherwise throws an CustomException
  static Future<int> globalLogout() async {
    const body = '09';
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
    final jwt = (url == au3Url) ? await getAccessToken2() : null;
    String userAgent = await DeviceInfoUtil.getUserAgent();

    final headers = {
      'User-Agent': userAgent,
      'medium': 'phone',
      'Content-Type': 'text/plain',
      if (jwt != null) 'Authorization': 'Bearer $jwt',
      if (url == au1Url) 'tenantID': "d14b3819-5e90-4b1e-8821-9fcb72684627",
      if (url == au1Url) 'clientID': "WaterMeteringMobile2",
    };
    var request = http.Request('POST', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);
    if (kDebugMode) {
    }
    try {
      if (kDebugMode) {
      }
      http.StreamedResponse response =
          await request.send().timeout(timeout ?? const Duration(seconds: 10));


      if (kDebugMode) {
      }
      if (kDebugMode) {
      }
      if (response.statusCode == 200) {
        var resp = await response.stream.bytesToString();
        if (kDebugMode) {
        }
        return resp;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await deleteDataAndLogout();
        throw CustomException('Redirecting to login page.. Please login again');
      } else {
        String responseBody = await response.stream.bytesToString();
        throw CustomException(responseBody);
      }
    } on TimeoutException {
      throw CustomException('Request timed out');
    } catch (e) {
      if (kDebugMode) {
      }
      throw CustomException('Network error: ${e.toString()}');
    }
  }
}