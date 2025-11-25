import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../utils/custom_exception.dart';
import '../utils/getDeviceID.dart';
import 'platform_utils.dart';

class AuthService {
  static const String _au1Url = 'https://api.nudron.com/prod/au1';
  static const String _au3Url = 'https://api.nudron.com/prod/au3';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _twoFactorKey = 'two_factor';
  static const String _biometricKey = 'biometric';
  static const String _themeModeKey = 'themeMode';
  
  static Future<String?>? _tokenRefreshFuture;
  static DateTime? _lastTokenRefresh;
  static const Duration _tokenRefreshCooldown = Duration(minutes: 1);
  
  static bool _isLoggingOut = false;
  
  static void Function()? onLoggedOut;

  static Future<bool> isLoggedIn() async {
    try {
      
      final token = await _secureStorage.read(key: _accessTokenKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
      if (token == null) return false;
      
      return !_isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }

  static Future<AuthResult> login(String email, String password) async {
    try {
      if (ConfigurationCustom.skipAnyAuths) {
        return AuthResult.success();
      }

      if (email.isEmpty || password.isEmpty) {
        return AuthResult.error('Please enter both email and password');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      final passwordBase64 = base64.encode(utf8.encode(password));
      final body = '02$email|$passwordBase64';

      final response = await _makeRequest(body, url: _au1Url);
      return _handleLoginResponse(response, email, password);

    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<AuthResult> _handleLoginResponse(String response, String email, String password) async {
    if (response == '0') {
      return AuthResult.error('Incorrect email or password');
    } else if (response == '10' || response == '01' || response == '00') {
      return AuthResult.error('Email or phone number not verified');
    }

    final splitResponse = response.split('|');
    
    if (splitResponse.length == 2) {
      
      await _storeTokens(splitResponse[0], splitResponse[1]);
      await _storeCredentials(email, password);
      await _setTwoFactorEnabled(false);
      return AuthResult.success();
    } else if (splitResponse.length == 1) {
      
      return AuthResult.twoFactorRequired(response);
    } else {
      return AuthResult.error('Unexpected response from server');
    }
  }

  static Future<AuthResult> verifyTwoFactor(String refCode, String code) async {
    try {
      final body = '03$refCode|$code';
      final response = await _makeRequest(body, url: _au1Url);
      
      if (response == '0') {
        return AuthResult.error('Incorrect verification code');
      } else if (response == '1') {
        return AuthResult.error('Verification code has expired');
      }

      final splitResponse = response.split('|');
      if (splitResponse.length == 2) {
        await _storeTokens(splitResponse[0], splitResponse[1]);
        await _setTwoFactorEnabled(true);
        return AuthResult.success();
      } else {
        return AuthResult.error('Unexpected response from server');
      }
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      
      final token = await _secureStorage.read(key: _accessTokenKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
      if (token == null) return null;

      if (_isTokenExpired(token)) {
        return await _refreshAccessTokenOptimized();
      } else if (_isTokenExpiring(token)) {
        
        _refreshAccessTokenOptimized().catchError((e) {
          return null;
        });
        return token;
      }
      
      return token;
    } catch (e) {
      
      if (!_isLoggingOut) {
        logout().catchError((e) {
        });
      }
      return null;
    }
  }

  static Future<String?> _refreshAccessTokenOptimized() async {
    
    if (_tokenRefreshFuture != null) {
      return await _tokenRefreshFuture!;
    }
    
    final now = DateTime.now();
    if (_lastTokenRefresh != null) {
      final timeSinceLastRefresh = now.difference(_lastTokenRefresh!);
      if (timeSinceLastRefresh < _tokenRefreshCooldown) {
        
        return await _secureStorage.read(key: _accessTokenKey);
      }
    }
    
    _lastTokenRefresh = now;
    _tokenRefreshFuture = _refreshAccessToken();
    
    try {
      final result = await _tokenRefreshFuture!;
      return result;
    } finally {
      _tokenRefreshFuture = null;
    }
  }

  static Future<String?> _refreshAccessToken() async {
    
    if (_isLoggingOut) {
      return null;
    }
    
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      
      if (refreshToken == null) {
        if (!_isLoggingOut) {
          logout().catchError((e) => null);
        }
        return null;
      }

      final body = '04$refreshToken';
      final response = await _makeRequest(body, url: _au1Url, timeout: const Duration(seconds: 10));
      
      if (response == '0') {
        if (!_isLoggingOut) {
          logout().catchError((e) => null);
        }
        return null;
      }

      final splitResponse = response.split('|');
      if (splitResponse.length == 2) {
        await _storeTokens(splitResponse[0], splitResponse[1]);
        return splitResponse[0];
      } else {
        if (!_isLoggingOut) {
          logout().catchError((e) => null);
        }
        return null;
      }
    } catch (e) {
      if (!_isLoggingOut && e.toString().contains('Session expired')) {
        logout().catchError((e) => null);
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo({Duration? timeout}) async {
    try {
      if (ConfigurationCustom.skipAnyAuths) {
        return {
          "email": "johndoe@email.com",
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
      final response = await _makeRequest(body, url: _au3Url, timeout: timeout);
      
      return jsonDecode(response);
    } catch (e) {
      return null;
    }
  }

  static Future<AuthResult> forgotPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      final body = '05$email';
      final response = await _makeRequest(body, url: _au1Url);
      
      if (response == '0') {
        return AuthResult.error('Error processing request');
      }
      
      return AuthResult.success(message: 'Password reset email sent');
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<void> logout({bool notifyListeners = false}) async {
    
    if (_isLoggingOut) {
      return;
    }
    
    try {
      _isLoggingOut = true;
      
      final token = await _secureStorage.read(key: _accessTokenKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      
      if (token != null) {
        try {
          const body = '08';
          
          await _makeRequest(body, url: _au3Url, timeout: const Duration(seconds: 5));
        } catch (e) {
          
        }
      }
    } finally {
      
      await _clearAuthData();
      _isLoggingOut = false;
      
      if (notifyListeners && onLoggedOut != null) {
        onLoggedOut!();
      }
    }
  }

  static Future<void> globalLogout({bool notifyListeners = false}) async {
    
    if (_isLoggingOut) {
      return;
    }
    
    try {
      _isLoggingOut = true;
      
      const body = '09';
      await _makeRequest(body, url: _au3Url, timeout: const Duration(seconds: 5));
    } catch (e) {
    } finally {
      await _clearAuthData();
      _isLoggingOut = false;
      
      if (notifyListeners && onLoggedOut != null) {
        onLoggedOut!();
      }
    }
  }

  static Future<AuthResult> deleteAccount() async {
    try {
      const body = '05';
      final response = await _makeRequest(body, url: _au3Url);
      
      if (response == '0') {
        return AuthResult.error('Error processing request');
      }
      
      await _clearAuthData();
      return AuthResult.success(message: 'Account deleted successfully');
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<bool> isTwoFactorEnabled() async {
    try {
      
      final value = await _secureStorage.read(key: _twoFactorKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  static Future<AuthResult> enableTwoFactor(int mode) async {
    try {
      final body = '02$mode';
      final response = await _makeRequest(body, url: _au3Url);
      
      if (response == '0') {
        return AuthResult.error('Error processing request');
      }

      await _setTwoFactorEnabled(true);

      if (mode == 2) {
        return AuthResult.success(message: 'SMS two-factor authentication enabled');
      }

      final responseValues = response.split('|');
      return AuthResult.success(data: {
        'qrCode': responseValues[0],
        'url': responseValues.length > 1 ? responseValues[1] : null,
      });
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<AuthResult> disableTwoFactor() async {
    try {
      const body = '03';
      await _makeRequest(body, url: _au3Url);
      await _setTwoFactorEnabled(false);
      return AuthResult.success(message: 'Two-factor authentication disabled');
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  static Future<String?> getStoredEmail() async {
    try {
      
      return await _secureStorage.read(key: _emailKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getStoredPassword() async {
    try {
      
      return await _secureStorage.read(key: _passwordKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeCredentialsForBiometric(String email, String password) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
    } catch (e) {
    }
  }

  static Future<void> clearStoredCredentials() async {
    try {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
    } catch (e) {
    }
  }

  static Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> _storeCredentials(String email, String password) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  static Future<void> _setTwoFactorEnabled(bool enabled) async {
    await _secureStorage.write(key: _twoFactorKey, value: enabled.toString());
  }

  static Future<void> _clearAuthData() async {
    try {
      
      final biometricEnabled = await _secureStorage.read(key: _biometricKey);
      final themeMode = await _secureStorage.read(key: _themeModeKey);
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      
      final shouldPreserveBiometric = biometricEnabled == 'true';
      
      final allKeys = {
        _accessTokenKey,
        _refreshTokenKey,
        _twoFactorKey,
      };
      
      for (final key in allKeys) {
        try {
          await _secureStorage.delete(key: key);
        } catch (e) {
          
        }
      }
      
      if (!shouldPreserveBiometric) {
        try {
          await _secureStorage.delete(key: _emailKey);
          await _secureStorage.delete(key: _passwordKey);
          await _secureStorage.delete(key: _biometricKey);
        } catch (e) {
          
        }
      } else {
        
        if (email != null && password != null) {
          try {
            await _secureStorage.write(key: _emailKey, value: email);
            await _secureStorage.write(key: _passwordKey, value: password);
            await _secureStorage.write(key: _biometricKey, value: 'true');
          } catch (e) {
            
          }
        }
      }
      
      if (themeMode != null) {
        try {
          await _secureStorage.write(key: _themeModeKey, value: themeMode);
        } catch (e) {
          
        }
      }
    } catch (e) {
      
    }
  }

  static bool _isTokenExpired(String token) {
    try {
      final expiryTime = _getTokenExpiryTime(token);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true;
    }
  }

  static bool _isTokenExpiring(String token) {
    try {
      final expiryTime = _getTokenExpiryTime(token);
      final thirtyMinutesFromNow = DateTime.now().add(const Duration(minutes: 30));
      return thirtyMinutesFromNow.isAfter(expiryTime);
    } catch (e) {
      return true;
    }
  }

  static DateTime _getTokenExpiryTime(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token format');
      
      final payloadBase64 = parts[1];
      final normalizedBase64 = base64.normalize(payloadBase64);
      final decodedToken = utf8.decode(base64.decode(normalizedBase64));
      final tokenData = json.decode(decodedToken);
      
      final expiryTime = tokenData['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000);
    } catch (e) {
      return DateTime.now().subtract(const Duration(hours: 1));
    }
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String _getErrorMessage(dynamic error) {
    if (error is CustomException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'Request timed out. Please check your internet connection.';
    } else if (error.toString().contains('No internet connection')) {
      return 'No internet connection. Please check your network settings.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static Future<String> _makeRequest(String body, {String url = _au1Url, Duration? timeout}) async {
    
    try {
      final connectivityResult = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return [ConnectivityResult.wifi]; 
        },
      );
      
      if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
        throw CustomException('No internet connection');
      }
    } catch (e) {
      
    }

    const int maxRetries = 3;
    const Duration initialRetryDelay = Duration(seconds: 1);
    const Duration totalTimeout = Duration(seconds: 5);
    final effectiveTimeout = timeout ?? Duration(milliseconds: (totalTimeout.inMilliseconds / maxRetries).round());
    
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        attempt++;
        
        final jwt = (url == _au3Url) 
            ? await getAccessToken().timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  return null;
                },
              )
            : null;
        
        final userAgent = await DeviceInfoUtil.getUserAgent().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            return 'WaterMeteringApp/1.0';
          },
        );

        final headers = {
          'User-Agent': userAgent,
          'medium': PlatformUtils.isDesktop ? 'desktop' : 'phone',
          'Content-Type': 'text/plain',
          if (jwt != null) 'Authorization': 'Bearer $jwt',
          if (url == _au1Url) 'tenantID': "d14b3819-5e90-4b1e-8821-9fcb72684627",
          if (url == _au1Url) 'clientID': PlatformUtils.isDesktop ? 'WaterMeteringDesktop' : 'WaterMeteringMobile2',
        };

        final request = http.Request('POST', Uri.parse(url));
        request.body = body;
        request.headers.addAll(headers);

        final response = await request.send().timeout(effectiveTimeout);

        
        if (response.statusCode == 200) {
          
          final responseBody = await response.stream.bytesToString().timeout(effectiveTimeout);
          return responseBody;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          
          if (!_isLoggingOut) {
            
            logout(notifyListeners: true).catchError((e) {
            });
          }
          throw CustomException('Session expired. Please login again.');
        } else {
          final responseBody = await response.stream.bytesToString().timeout(const Duration(seconds: 5));
          throw CustomException(responseBody.isNotEmpty ? responseBody : 'Server error');
        }
      } on TimeoutException catch (e) {
        lastException = e;
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

class AuthResult {
  final bool success;
  final String? message;
  final String? error;
  final Map<String, dynamic>? data;
  final String? twoFactorRefCode;

  const AuthResult._({
    required this.success,
    this.message,
    this.error,
    this.data,
    this.twoFactorRefCode,
  });

  factory AuthResult.success({String? message, Map<String, dynamic>? data}) {
    return AuthResult._(success: true, message: message, data: data);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }

  factory AuthResult.twoFactorRequired(String refCode) {
    return AuthResult._(success: false, twoFactorRefCode: refCode);
  }

  bool get isTwoFactorRequired => twoFactorRefCode != null;
}
