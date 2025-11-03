import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/auth_service.dart';
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
    on<AuthDeleteAccount>(_onDeleteAccount);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthEnableTwoFactor>(_onEnableTwoFactor);
    on<AuthDisableTwoFactor>(_onDisableTwoFactor);
    on<AuthRefreshToken>(_onRefreshToken);
  }

  /// Check if user is currently logged in
  Future<void> _onCheckLoginStatus(AuthCheckLoginStatus event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final isLoggedIn = await AuthService.isLoggedIn().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
      
      if (isLoggedIn) {
        try {
          // Refresh listeners to load biometric and 2FA state from secure storage
          await LoginPostRequests.refreshListeners();
          
          // Fail fast on profile load to avoid hanging the app on slow networks
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          // If we can't get user info, but we're logged in, still proceed
          // The app can try to fetch it later
          emit(AuthAuthenticated(
            userInfo: null,
            isTwoFactorEnabled: false,
          ));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // On any error during login check, default to unauthenticated
      // This prevents the app from hanging
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.login(event.email, event.password).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Login request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          // Refresh listeners to load biometric and 2FA state from secure storage
          await LoginPostRequests.refreshListeners();
          
          // Don't block on user info; time out quickly
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          // If we can't get user info but login succeeded, still authenticate
          emit(AuthAuthenticated(
            userInfo: null,
            isTwoFactorEnabled: false,
          ));
        }
      } else if (result.isTwoFactorRequired) {
        emit(AuthTwoFactorRequired(refCode: result.twoFactorRefCode!));
      } else {
        emit(AuthError(result.error ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  /// Login with biometric authentication
  Future<void> _onLoginWithBiometric(AuthLoginWithBiometric event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Check if biometric is available
      final biometricHelper = BiometricHelper();
      final isBiometricSetup = await biometricHelper.isBiometricSetup().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
      
      if (!isBiometricSetup) {
        emit(AuthError('Biometric authentication not available. Please enable biometrics on your device first.'));
        return;
      }

      // Verify biometric
      final isCorrectBiometric = await biometricHelper.isCorrectBiometric().timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
      
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
      final result = await AuthService.login(email, password).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Login request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          // Refresh listeners to load biometric and 2FA state from secure storage
          await LoginPostRequests.refreshListeners();
          
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          // If we can't get user info but login succeeded, still authenticate
          emit(AuthAuthenticated(
            userInfo: null,
            isTwoFactorEnabled: false,
          ));
        }
      } else if (result.isTwoFactorRequired) {
        emit(AuthTwoFactorRequired(refCode: result.twoFactorRefCode!));
      } else {
        emit(AuthError(result.error ?? 'Biometric login failed'));
      }
    } catch (e) {
      emit(AuthError('Biometric login failed: ${e.toString()}'));
    }
  }

  /// Verify two-factor authentication code
  Future<void> _onVerifyTwoFactor(AuthVerifyTwoFactor event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.verifyTwoFactor(event.refCode, event.code).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Verification request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          // Refresh listeners to load biometric and 2FA state from secure storage
          await LoginPostRequests.refreshListeners();
          
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          // If we can't get user info but verification succeeded, still authenticate
          emit(AuthAuthenticated(
            userInfo: null,
            isTwoFactorEnabled: true,
          ));
        }
      } else {
        emit(AuthError(result.error ?? 'Two-factor verification failed'));
      }
    } catch (e) {
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
      emit(AuthError('Global logout failed: ${e.toString()}'));
    }
  }

  /// Delete account
  Future<void> _onDeleteAccount(AuthDeleteAccount event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final result = await AuthService.deleteAccount();
      
      if (result.success) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthError(result.error ?? 'Failed to delete account'));
      }
    } catch (e) {
      emit(AuthError('Failed to delete account: ${e.toString()}'));
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
      emit(AuthError('Failed to disable two-factor authentication: ${e.toString()}'));
    }
  }

  /// Refresh access token
  Future<void> _onRefreshToken(AuthRefreshToken event, Emitter<AuthState> emit) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        // Token refreshed successfully, emit current state
        final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
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
      emit(AuthUnauthenticated());
    }
  }
}
