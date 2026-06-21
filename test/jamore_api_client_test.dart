import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/infrastructure/network/api_exception.dart';
import 'package:jamore/infrastructure/network/jamore_api_client.dart';

void main() {
  test('uses customer server api path and TokenJamore', () async {
    late http.Request captured;
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final client = JamoreApiClient(
      connection: connection,
      client: MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    await client.get('Employee/Get');

    expect(
      captured.url.toString(),
      'https://customer.example.com/api/Employee/Get',
    );
    expect(captured.headers['Authorization'], 'Bearer jamore-token');
    expect(captured.headers['x-companyid'], 'JAMORE-TH');
  });

  test('cannot call customer API before company connection is configured', () {
    final client = JamoreApiClient(connection: JamoreApiConnection());

    expect(() => client.get('Employee/Get'), throwsA(isA<ApiException>()));
  });
}
