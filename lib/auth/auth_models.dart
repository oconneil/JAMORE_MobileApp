class AuthSession {
  const AuthSession({
    required this.userName,
    required this.token,
    required this.expiration,
    required this.firstLogin,
    required this.passwordExpired,
    required this.isAdmin,
    this.companyId,
    this.defaultLanguage,
  });

  final String userName;
  final Object? companyId;
  final String token;
  final DateTime expiration;
  final bool firstLogin;
  final bool passwordExpired;
  final String? defaultLanguage;
  final bool isAdmin;

  bool get isExpired => !expiration.isAfter(DateTime.now().toUtc());
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
