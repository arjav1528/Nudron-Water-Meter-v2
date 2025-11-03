/// Base class for authentication states
abstract class AuthState {}

/// Initial authentication state
class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial';
}

/// Authentication loading state
class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final Map<String, dynamic>? userInfo;
  final bool isTwoFactorEnabled;

  AuthAuthenticated({
    this.userInfo,
    this.isTwoFactorEnabled = false,
  });

  @override
  String toString() => 'AuthAuthenticated(isTwoFactorEnabled: $isTwoFactorEnabled)';
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  @override
  String toString() => 'AuthUnauthenticated';
}

/// Two-factor authentication required
class AuthTwoFactorRequired extends AuthState {
  final String refCode;

  AuthTwoFactorRequired({required this.refCode});

  @override
  String toString() => 'AuthTwoFactorRequired(refCode: $refCode)';
}

/// Authentication error
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  String toString() => 'AuthError(message: $message)';
}

/// Forgot password email sent
class AuthForgotPasswordSent extends AuthState {
  final String message;

  AuthForgotPasswordSent({required this.message});

  @override
  String toString() => 'AuthForgotPasswordSent(message: $message)';
}

/// Two-factor authentication enabled
class AuthTwoFactorEnabled extends AuthState {
  final String message;
  final Map<String, dynamic>? data;

  AuthTwoFactorEnabled({required this.message, this.data});

  @override
  String toString() => 'AuthTwoFactorEnabled(message: $message)';
}

/// Two-factor authentication disabled
class AuthTwoFactorDisabled extends AuthState {
  final String message;

  AuthTwoFactorDisabled({required this.message});

  @override
  String toString() => 'AuthTwoFactorDisabled(message: $message)';
}
