/// Base class for authentication events
abstract class AuthEvent {}

/// Check if user is currently logged in
class AuthCheckLoginStatus extends AuthEvent {}

/// Login with email and password
class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

/// Login with biometric authentication
class AuthLoginWithBiometric extends AuthEvent {}

/// Verify two-factor authentication code
class AuthVerifyTwoFactor extends AuthEvent {
  final String refCode;
  final String code;

  AuthVerifyTwoFactor({required this.refCode, required this.code});
}

/// Logout user
class AuthLogout extends AuthEvent {}

/// Global logout (logout from all devices)
class AuthGlobalLogout extends AuthEvent {}

/// Delete account
class AuthDeleteAccount extends AuthEvent {}

/// Forgot password
class AuthForgotPassword extends AuthEvent {
  final String email;

  AuthForgotPassword({required this.email});
}

/// Enable two-factor authentication
class AuthEnableTwoFactor extends AuthEvent {
  final int mode; // 2 for SMS, 10/11 for app

  AuthEnableTwoFactor({required this.mode});
}

/// Disable two-factor authentication
class AuthDisableTwoFactor extends AuthEvent {}

/// Refresh access token
class AuthRefreshToken extends AuthEvent {}
