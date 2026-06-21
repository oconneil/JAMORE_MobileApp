import '../entities/auth_session.dart';

abstract interface class AuthGateway {
  String? get accessToken;

  Future<AuthSession?> restoreSession();

  Future<AuthSession> login({
    required String userName,
    required String password,
    String? companyId,
    required bool rememberMe,
  });

  Future<void> logout();
}
