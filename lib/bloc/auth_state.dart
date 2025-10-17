/// Base class for authentication states
abstract class AuthState {}

/// Initial authentication state
class AuthInitial extends AuthState {}

/// Authentication loading state
class AuthLoading extends AuthState {}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final Map<String, dynamic>? userInfo;
  final bool isTwoFactorEnabled;

  AuthAuthenticated({
    this.userInfo,
    this.isTwoFactorEnabled = false,
  });
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {}

/// Two-factor authentication required
class AuthTwoFactorRequired extends AuthState {
  final String refCode;

  AuthTwoFactorRequired({required this.refCode});
}

/// Authentication error
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

/// Forgot password email sent
class AuthForgotPasswordSent extends AuthState {
  final String message;

  AuthForgotPasswordSent({required this.message});
}

/// Two-factor authentication enabled
class AuthTwoFactorEnabled extends AuthState {
  final String message;
  final Map<String, dynamic>? data;

  AuthTwoFactorEnabled({required this.message, this.data});
}

/// Two-factor authentication disabled
class AuthTwoFactorDisabled extends AuthState {
  final String message;

  AuthTwoFactorDisabled({required this.message});
}
