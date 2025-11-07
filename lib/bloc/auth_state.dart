
abstract class AuthState {}

class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial';
}

class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}

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

class AuthUnauthenticated extends AuthState {
  @override
  String toString() => 'AuthUnauthenticated';
}

class AuthTwoFactorRequired extends AuthState {
  final String refCode;

  AuthTwoFactorRequired({required this.refCode});

  @override
  String toString() => 'AuthTwoFactorRequired(refCode: $refCode)';
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  String toString() => 'AuthError(message: $message)';
}

class AuthForgotPasswordSent extends AuthState {
  final String message;

  AuthForgotPasswordSent({required this.message});

  @override
  String toString() => 'AuthForgotPasswordSent(message: $message)';
}

class AuthTwoFactorEnabled extends AuthState {
  final String message;
  final Map<String, dynamic>? data;

  AuthTwoFactorEnabled({required this.message, this.data});

  @override
  String toString() => 'AuthTwoFactorEnabled(message: $message)';
}

class AuthTwoFactorDisabled extends AuthState {
  final String message;

  AuthTwoFactorDisabled({required this.message});

  @override
  String toString() => 'AuthTwoFactorDisabled(message: $message)';
}
