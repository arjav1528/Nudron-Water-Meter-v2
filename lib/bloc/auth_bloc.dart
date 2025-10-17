import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../utils/biometric_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication Bloc for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckLoginStatus>(_onCheckLoginStatus);
    on<AuthLogin>(_onLogin);
    on<AuthLoginWithBiometric>(_onLoginWithBiometric);
    on<AuthVerifyTwoFactor>(_onVerifyTwoFactor);
    on<AuthLogout>(_onLogout);
    on<AuthGlobalLogout>(_onGlobalLogout);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthEnableTwoFactor>(_onEnableTwoFactor);
    on<AuthDisableTwoFactor>(_onDisableTwoFactor);
    on<AuthRefreshToken>(_onRefreshToken);
  }

  /// Check if user is currently logged in
  Future<void> _onCheckLoginStatus(AuthCheckLoginStatus event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userInfo = await AuthService.getUserInfo();
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      if (kDebugMode) print('Error checking login status: $e');
      emit(AuthError('Failed to check login status: ${e.toString()}'));
    }
  }

  /// Login with email and password
  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.login(event.email, event.password);
      
      if (result.success) {
        final userInfo = await AuthService.getUserInfo();
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else if (result.isTwoFactorRequired) {
        emit(AuthTwoFactorRequired(refCode: result.twoFactorRefCode!));
      } else {
        emit(AuthError(result.error ?? 'Login failed'));
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  /// Login with biometric authentication
  Future<void> _onLoginWithBiometric(AuthLoginWithBiometric event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Check if biometric is available
      final biometricHelper = BiometricHelper();
      if (!await biometricHelper.isBiometricSetup()) {
        emit(AuthError('Biometric authentication not available. Please enable biometrics on your device first.'));
        return;
      }

      // Verify biometric
      final isCorrectBiometric = await biometricHelper.isCorrectBiometric();
      if (!isCorrectBiometric) {
        emit(AuthError('Biometric authentication failed'));
        return;
      }

      // Get stored credentials
      final email = await AuthService.getStoredEmail();
      final password = await AuthService.getStoredPassword();
      
      if (email == null || password == null) {
        emit(AuthError('No biometric data saved. Please enable in the profile section on login'));
        return;
      }

      // Login with stored credentials
      final result = await AuthService.login(email, password);
      
      if (result.success) {
        final userInfo = await AuthService.getUserInfo();
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else if (result.isTwoFactorRequired) {
        emit(AuthTwoFactorRequired(refCode: result.twoFactorRefCode!));
      } else {
        emit(AuthError(result.error ?? 'Biometric login failed'));
      }
    } catch (e) {
      if (kDebugMode) print('Biometric login error: $e');
      emit(AuthError('Biometric login failed: ${e.toString()}'));
    }
  }

  /// Verify two-factor authentication code
  Future<void> _onVerifyTwoFactor(AuthVerifyTwoFactor event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.verifyTwoFactor(event.refCode, event.code);
      
      if (result.success) {
        final userInfo = await AuthService.getUserInfo();
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else {
        emit(AuthError(result.error ?? 'Two-factor verification failed'));
      }
    } catch (e) {
      if (kDebugMode) print('Two-factor verification error: $e');
      emit(AuthError('Two-factor verification failed: ${e.toString()}'));
    }
  }

  /// Logout user
  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await AuthService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      if (kDebugMode) print('Logout error: $e');
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  /// Global logout (logout from all devices)
  Future<void> _onGlobalLogout(AuthGlobalLogout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await AuthService.globalLogout();
      emit(AuthUnauthenticated());
    } catch (e) {
      if (kDebugMode) print('Global logout error: $e');
      emit(AuthError('Global logout failed: ${e.toString()}'));
    }
  }

  /// Forgot password
  Future<void> _onForgotPassword(AuthForgotPassword event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.forgotPassword(event.email);
      
      if (result.success) {
        emit(AuthForgotPasswordSent(message: result.message ?? 'Password reset email sent'));
      } else {
        emit(AuthError(result.error ?? 'Failed to send password reset email'));
      }
    } catch (e) {
      if (kDebugMode) print('Forgot password error: $e');
      emit(AuthError('Failed to send password reset email: ${e.toString()}'));
    }
  }

  /// Enable two-factor authentication
  Future<void> _onEnableTwoFactor(AuthEnableTwoFactor event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.enableTwoFactor(event.mode);
      
      if (result.success) {
        emit(AuthTwoFactorEnabled(
          message: result.message ?? 'Two-factor authentication enabled',
          data: result.data,
        ));
      } else {
        emit(AuthError(result.error ?? 'Failed to enable two-factor authentication'));
      }
    } catch (e) {
      if (kDebugMode) print('Enable two-factor error: $e');
      emit(AuthError('Failed to enable two-factor authentication: ${e.toString()}'));
    }
  }

  /// Disable two-factor authentication
  Future<void> _onDisableTwoFactor(AuthDisableTwoFactor event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.disableTwoFactor();
      
      if (result.success) {
        emit(AuthTwoFactorDisabled(message: result.message ?? 'Two-factor authentication disabled'));
      } else {
        emit(AuthError(result.error ?? 'Failed to disable two-factor authentication'));
      }
    } catch (e) {
      if (kDebugMode) print('Disable two-factor error: $e');
      emit(AuthError('Failed to disable two-factor authentication: ${e.toString()}'));
    }
  }

  /// Refresh access token
  Future<void> _onRefreshToken(AuthRefreshToken event, Emitter<AuthState> emit) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        // Token refreshed successfully, emit current state
        final userInfo = await AuthService.getUserInfo();
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else {
        // Token refresh failed, logout user
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      if (kDebugMode) print('Token refresh error: $e');
      emit(AuthUnauthenticated());
    }
  }
}
