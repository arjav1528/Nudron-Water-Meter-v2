
abstract class AuthEvent {}

class AuthCheckLoginStatus extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

class AuthLoginWithBiometric extends AuthEvent {}

class AuthVerifyTwoFactor extends AuthEvent {
  final String refCode;
  final String code;

  AuthVerifyTwoFactor({required this.refCode, required this.code});
}

class AuthLogout extends AuthEvent {}

class AuthGlobalLogout extends AuthEvent {}

class AuthDeleteAccount extends AuthEvent {}

class AuthForgotPassword extends AuthEvent {
  final String email;

  AuthForgotPassword({required this.email});
}

class AuthEnableTwoFactor extends AuthEvent {
  final int mode; 

  AuthEnableTwoFactor({required this.mode});
}

class AuthDisableTwoFactor extends AuthEvent {}

class AuthRefreshToken extends AuthEvent {}
