import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/auth/auth_models.dart';
import 'package:jamore/auth/auth_repository.dart';
import 'package:jamore/network/api_client.dart';

void main() {
  test('posts LoginModel and maps the AuthenticateMobile response', () async {
    late http.Request captured;
    final expiry = DateTime.now().toUtc().add(const Duration(days: 1));
    final tokenUniverse = _fakeJwt(expiry);
    final repository = AuthRepository(
      ApiClient(
        baseUri: Uri.parse('https://example.com/api/'),
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'Status': 'Success',
              'Message': '',
              'Value': {
                'UserName': 'employee',
                'CompanyID': 7,
                'TokenJamore': 'jamore-token',
                'TokenUniverse': tokenUniverse,
                'DefaultLanguage': 'en',
                'IsAdmin': true,
              },
            }),
            200,
          );
        }),
      ),
    );

    final session = await repository.login(
      userName: 'employee',
      password: 'secret',
      companyId: 'JAMORE-TH',
      rememberMe: true,
    );

    expect(captured.url.path, '/api/AuthenticateMobile/Login');
    expect(jsonDecode(captured.body), {
      'UserName': 'employee',
      'Password': 'secret',
      'CompanyID': 'JAMORE-TH',
    });
    expect(session.token, tokenUniverse);
    expect(session.companyId, 7);
    expect(session.defaultLanguage, 'en');
    expect(session.isAdmin, isTrue);
    expect(session.isExpired, isFalse);
    expect(
      session.expiration.millisecondsSinceEpoch ~/ 1000,
      expiry.millisecondsSinceEpoch ~/ 1000,
    );
    expect(repository.accessToken, tokenUniverse);
  });

  test('uses the backend message when Result.Value is null', () async {
    final repository = AuthRepository(
      ApiClient(
        baseUri: Uri.parse('https://example.com/api/'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'status': 'Failed',
              'message': 'User name or password invalid.',
              'value': null,
            }),
            200,
          ),
        ),
      ),
    );

    expect(
      () =>
          repository.login(userName: 'bad', password: 'bad', rememberMe: false),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'User name or password invalid.',
        ),
      ),
    );
  });
}

// Builds an unsigned JWT carrying only an `exp` claim, for expiry parsing.
String _fakeJwt(DateTime expiry) {
  String seg(Map<String, Object?> claims) =>
      base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');
  final header = seg({'alg': 'HS256', 'typ': 'JWT'});
  final payload = seg({'exp': expiry.millisecondsSinceEpoch ~/ 1000});
  return '$header.$payload.signature';
}
