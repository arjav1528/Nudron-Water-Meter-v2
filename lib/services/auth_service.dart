import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../utils/custom_exception.dart';
import '../utils/getDeviceID.dart';

/// Modern authentication service with proper error handling and separation of concerns
class AuthService {
  static const String _au1Url = 'https://api.nudron.com/prod/au1';
  static const String _au3Url = 'https://api.nudron.com/prod/au3';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _twoFactorKey = 'two_factor';
  static const String _biometricKey = 'biometric';
  static const String _themeModeKey = 'themeMode';
  
  // Token refresh optimization
  static Future<String?>? _tokenRefreshFuture;
  static DateTime? _lastTokenRefresh;
  static const Duration _tokenRefreshCooldown = Duration(minutes: 1);

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token == null) return false;
      
      return !_isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }

  /// Login with email and password
  static Future<AuthResult> login(String email, String password) async {
    try {
      if (ConfigurationCustom.skipAnyAuths) {
        return AuthResult.success();
      }

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.error('Please enter both email and password');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      // Encode password to base64
      final passwordBase64 = base64.encode(utf8.encode(password));
      final body = '02$email|$passwordBase64';

      final response = await _makeRequest(body, url: _au1Url);
      return _handleLoginResponse(response, email, password);

    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  /// Handle login response and determine next steps
  static Future<AuthResult> _handleLoginResponse(String response, String email, String password) async {
    if (response == '0') {
      return AuthResult.error('Incorrect email or password');
    } else if (response == '10' || response == '01' || response == '00') {
      return AuthResult.error('Email or phone number not verified');
    }

    final splitResponse = response.split('|');
    
    if (splitResponse.length == 2) {
      // Successful login with tokens
      await _storeTokens(splitResponse[0], splitResponse[1]);
      await _storeCredentials(email, password);
      await _setTwoFactorEnabled(false);
      return AuthResult.success();
    } else if (splitResponse.length == 1) {
      // Two-factor authentication required
      return AuthResult.twoFactorRequired(response);
    } else {
      return AuthResult.error('Unexpected response from server');
    }
  }

  /// Verify two-factor authentication code
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

  /// Get valid access token (refresh if needed)
  static Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token == null) return null;

      if (_isTokenExpired(token)) {
        return await _refreshAccessTokenOptimized();
      } else if (_isTokenExpiring(token)) {
        // Refresh token in background without blocking
        _refreshAccessTokenOptimized();
        return token;
      }
      
      return token;
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Optimized token refresh with deduplication and cooldown
  static Future<String?> _refreshAccessTokenOptimized() async {
    // Check if there's already a refresh in progress
    if (_tokenRefreshFuture != null) {
      return await _tokenRefreshFuture!;
    }
    
    // Check cooldown to prevent rapid refresh calls
    final now = DateTime.now();
    if (_lastTokenRefresh != null) {
      final timeSinceLastRefresh = now.difference(_lastTokenRefresh!);
      if (timeSinceLastRefresh < _tokenRefreshCooldown) {
        // Return current token if refresh was recent
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

  /// Refresh access token using refresh token
  static Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        await logout();
        return null;
      }

      final body = '04$refreshToken';
      final response = await _makeRequest(body, url: _au1Url);
      
      if (response == '0') {
        await logout();
        return null;
      }

      final splitResponse = response.split('|');
      if (splitResponse.length == 2) {
        await _storeTokens(splitResponse[0], splitResponse[1]);
        return splitResponse[0];
      } else {
        await logout();
        return null;
      }
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Get user information
  /// Optional timeout allows callers (e.g., initial auth check) to fail fast
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

  /// Forgot password
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

  /// Logout user
  static Future<void> logout() async {
    try {
      // Call logout API if we have a token
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null) {
        try {
          const body = '08';
          await _makeRequest(body, url: _au3Url);
        } catch (e) {
          // Ignore logout API errors
        }
      }
    } finally {
      // Always clear local data
      await _clearAuthData();
    }
  }

  /// Global logout (logout from all devices)
  static Future<void> globalLogout() async {
    try {
      const body = '09';
      await _makeRequest(body, url: _au3Url);
    } catch (e) {
    } finally {
      await _clearAuthData();
    }
  }

  /// Check if two-factor authentication is enabled
  static Future<bool> isTwoFactorEnabled() async {
    try {
      final value = await _secureStorage.read(key: _twoFactorKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable two-factor authentication
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

  /// Disable two-factor authentication
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

  /// Get stored email for biometric login
  static Future<String?> getStoredEmail() async {
    try {
      return await _secureStorage.read(key: _emailKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored password for biometric login
  static Future<String?> getStoredPassword() async {
    try {
      return await _secureStorage.read(key: _passwordKey);
    } catch (e) {
      return null;
    }
  }

  /// Store credentials for biometric login
  static Future<void> storeCredentialsForBiometric(String email, String password) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
    } catch (e) {
    }
  }

  /// Clear stored credentials
  static Future<void> clearStoredCredentials() async {
    try {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
    } catch (e) {
    }
  }

  // Private helper methods

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
      // Check if biometric is enabled
      final biometricEnabled = await _secureStorage.read(key: _biometricKey);
      final themeMode = await _secureStorage.read(key: _themeModeKey);
      
      if (biometricEnabled == 'true') {
        // Keep email, password, biometric, and theme settings
        final email = await _secureStorage.read(key: _emailKey);
        final password = await _secureStorage.read(key: _passwordKey);
        
        await _secureStorage.deleteAll();
        
        if (email != null) await _secureStorage.write(key: _emailKey, value: email);
        if (password != null) await _secureStorage.write(key: _passwordKey, value: password);
        await _secureStorage.write(key: _biometricKey, value: 'true');
      } else {
        await _secureStorage.deleteAll();
      }
      
      if (themeMode != null) {
        await _secureStorage.write(key: _themeModeKey, value: themeMode);
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
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw CustomException('No internet connection');
    }

    // Retry configuration
    const int maxRetries = 3;
    const Duration initialRetryDelay = Duration(seconds: 1);
    final effectiveTimeout = timeout ?? const Duration(seconds: 30);
    
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        final jwt = (url == _au3Url) ? await getAccessToken() : null;
        final userAgent = await DeviceInfoUtil.getUserAgent();

        final headers = {
          'User-Agent': userAgent,
          'medium': 'phone',
          'Content-Type': 'text/plain',
          if (jwt != null) 'Authorization': 'Bearer $jwt',
          if (url == _au1Url) 'tenantID': "d14b3819-5e90-4b1e-8821-9fcb72684627",
          if (url == _au1Url) 'clientID': "WaterMeteringMobile2",
        };

        final request = http.Request('POST', Uri.parse(url));
        request.body = body;
        request.headers.addAll(headers);

        // Send request with timeout
        final response = await request.send().timeout(effectiveTimeout);

        if (response.statusCode == 200) {
          // Read response body with timeout
          final responseBody = await response.stream.bytesToString().timeout(effectiveTimeout);
          return responseBody;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          await logout();
          throw CustomException('Session expired. Please login again.');
        } else {
          final responseBody = await response.stream.bytesToString().timeout(const Duration(seconds: 5));
          throw CustomException(responseBody.isNotEmpty ? responseBody : 'Server error');
        }
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        if (attempt < maxRetries) {
          // Exponential backoff: 1s, 2s, 4s
          final delay = Duration(seconds: initialRetryDelay.inSeconds * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
        throw CustomException('Request timed out after $maxRetries attempts');
      } on SocketException catch (e) {
        lastException = e;
        attempt++;
        if (attempt < maxRetries) {
          // Exponential backoff for connection errors
          final delay = Duration(seconds: initialRetryDelay.inSeconds * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
        throw CustomException('Network connection failed: ${e.message}');
      } catch (e) {
        // For non-retryable errors (like 401/403), throw immediately
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

/// Result class for authentication operations
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
