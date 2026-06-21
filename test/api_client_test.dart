import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/infrastructure/network/api_client.dart';
import 'package:jamore/infrastructure/network/api_exception.dart';

void main() {
  test('keeps the API path prefix and adds standard headers', () async {
    late http.Request captured;
    final client = ApiClient(
      baseUri: Uri.parse('https://example.com/api/'),
      accessTokenProvider: () => 'token-123',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'ok': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final response = await client.get('/employees', query: {'page': 2});

    expect(captured.url.toString(), 'https://example.com/api/employees?page=2');
    expect(captured.headers['Authorization'], 'Bearer token-123');
    expect(response, {'ok': true});
  });

  test('maps non-success responses to ApiException', () async {
    final client = ApiClient(
      baseUri: Uri.parse('https://example.com/api/'),
      client: MockClient(
        (_) async => http.Response('{"message":"Denied"}', 403),
      ),
    );

    expect(
      () => client.get('private'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.message, 'message', 'Denied'),
      ),
    );
  });
}
