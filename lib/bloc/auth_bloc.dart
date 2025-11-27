import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/auth_service.dart';
import '../services/auth_service.dart';
import '../utils/biometric_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

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
    
    AuthService.onLoggedOut = () {
      add(AuthLogout());
    };
  }

  Future<void> _onCheckLoginStatus(AuthCheckLoginStatus event, Emitter<AuthState> emit) async {
    try {
      
      final isLoggedIn = await AuthService.isLoggedIn().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          return false;
        },
      );
      
      if (!isLoggedIn) {
        emit(AuthUnauthenticated());
        return;
      }
      
      try {
        
        await LoginPostRequests.refreshListeners().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
          },
        );
      } catch (e) {
      }
      
      Map<String, dynamic>? userInfo;
      bool isTwoFactorEnabled = false;
      
      try {
        userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 3));
        isTwoFactorEnabled = await AuthService.isTwoFactorEnabled().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            return false;
          },
        );
      } catch (e) {
        
      }
      
      emit(AuthAuthenticated(
        userInfo: userInfo,
        isTwoFactorEnabled: isTwoFactorEnabled,
      ));
      
    } catch (e) {
      
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.login(event.email, event.password).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Login request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          
          await LoginPostRequests.refreshListeners().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
            },
          );
          
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          
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

  Future<void> _onLoginWithBiometric(AuthLoginWithBiometric event, Emitter<AuthState> emit) async {
    try {
      
      final biometricHelper = BiometricHelper();
      final isBiometricSetup = await biometricHelper.isBiometricSetup().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
      
      if (!isBiometricSetup) {
        emit(AuthError('Biometric authentication not available. Please enable biometrics on your device first.'));
        return;
      }

      final isCorrectBiometric = await biometricHelper.isCorrectBiometric().timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
      
      if (!isCorrectBiometric) {
        emit(AuthError('Biometric authentication failed'));
        return;
      }

      
      emit(AuthLoading());

      final email = await AuthService.getStoredEmail();
      final password = await AuthService.getStoredPassword();
      
      if (email == null || password == null) {
        emit(AuthError('No biometric data saved. Please enable in the profile section on login'));
        return;
      }

      final result = await AuthService.login(email, password).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Login request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          
          await LoginPostRequests.refreshListeners().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
            },
          );
          
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          
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

  Future<void> _onVerifyTwoFactor(AuthVerifyTwoFactor event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final result = await AuthService.verifyTwoFactor(event.refCode, event.code).timeout(
        const Duration(seconds: 30),
        onTimeout: () => AuthResult.error('Verification request timed out. Please check your internet connection.'),
      );
      
      if (result.success) {
        try {
          
          await LoginPostRequests.refreshListeners().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
            },
          );
          
          final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
          final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
          
          emit(AuthAuthenticated(
            userInfo: userInfo,
            isTwoFactorEnabled: isTwoFactorEnabled,
          ));
        } catch (e) {
          
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

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await AuthService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onGlobalLogout(AuthGlobalLogout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await AuthService.globalLogout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Global logout failed: ${e.toString()}'));
    }
  }

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

  Future<void> _onRefreshToken(AuthRefreshToken event, Emitter<AuthState> emit) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        
        final userInfo = await AuthService.getUserInfo(timeout: const Duration(seconds: 5));
        final isTwoFactorEnabled = await AuthService.isTwoFactorEnabled();
        
        emit(AuthAuthenticated(
          userInfo: userInfo,
          isTwoFactorEnabled: isTwoFactorEnabled,
        ));
      } else {
        
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
  
  @override
  Future<void> close() {
    
    AuthService.onLoggedOut = null;
    return super.close();
  }
}
