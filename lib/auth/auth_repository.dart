import 'dart:convert';

import '../network/api_client.dart';
import 'auth_models.dart';

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

class AuthRepository implements AuthGateway {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;
  AuthSession? _session;

  @override
  String? get accessToken {
    final session = _session;
    return session == null || session.isExpired ? null : session.token;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final session = _session;
    return session == null || session.isExpired ? null : session;
  }

  @override
  Future<AuthSession> login({
    required String userName,
    required String password,
    String? companyId,
    required bool rememberMe,
  }) async {
    // AuthenticateMobile/Login requires CompanyID; always send it (trimmed).
    final response = await _apiClient.post(
      'AuthenticateMobile/Login',
      body: {
        'UserName': userName.trim(),
        'Password': password,
        'CompanyID': companyId?.trim() ?? '',
      },
    );
    if (response is! Map) {
      throw const AuthException('Invalid login response.');
    }

    final result = Map<String, Object?>.from(response);
    final message = _field(result, 'message')?.toString() ?? 'Login failed.';
    final rawValue = _field(result, 'value');
    if (rawValue is! Map) throw AuthException(message);

    final value = Map<String, Object?>.from(rawValue);
    // The session JWT for this backend is returned as `TokenUniverse`
    // (fall back to `token` for compatibility with the legacy endpoint).
    final token = (_field(value, 'tokenUniverse') ?? _field(value, 'token'))
        ?.toString();
    if (token == null || token.isEmpty) throw AuthException(message);
    final jamoreToken = _field(value, 'tokenJamore')?.toString();
    if (jamoreToken == null || jamoreToken.isEmpty) {
      throw const AuthException('TokenJamore is missing.');
    }

    // This endpoint does not return an explicit expiration; derive it from the
    // JWT `exp` claim, falling back to the backend default of one day.
    final expiration =
        _expiryFromJwt(token) ??
        DateTime.now().toUtc().add(const Duration(days: 1));

    final session = AuthSession(
      userName: _field(value, 'userName')?.toString() ?? userName.trim(),
      companyId: _field(value, 'companyID'),
      token: token,
      jamoreToken: jamoreToken,
      expiration: expiration,
      firstLogin: _bool(_field(value, 'firstLogin')),
      passwordExpired: _bool(_field(value, 'passwordExpired')),
      defaultLanguage: _field(value, 'defaultLanguage')?.toString(),
      isAdmin: _bool(_field(value, 'isAdmin')),
    );
    _session = session;
    return session;
  }

  // Reads the `exp` claim (seconds since epoch) from a JWT without verifying
  // the signature. Returns null if the token is malformed or has no expiry.
  static DateTime? _expiryFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is Map && payload['exp'] is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          (payload['exp'] as num).toInt() * 1000,
          isUtc: true,
        );
      }
    } on Object {
      return null;
    }
    return null;
  }

  @override
  Future<void> logout() async => _session = null;

  static Object? _field(Map<String, Object?> map, String name) {
    final normalized = name.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return null;
  }

  static bool _bool(Object? value) => switch (value) {
    bool result => result,
    num result => result != 0,
    String result => result.toLowerCase() == 'true' || result == '1',
    _ => false,
  };
}
