import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/data/repositories/api_user_repository.dart';
import 'package:jamore/infrastructure/network/jamore_api_client.dart';

void main() {
  test('calls customer GetUser with TokenJamore', () async {
    late http.Request captured;
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final repository = ApiUserRepository(
      JamoreApiClient(
        connection: connection,
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'status': 'Success',
              'message': '',
              'value': {
                'id': '5baaf848-3e72-45f3-9bcd-fb21f449bd76',
                'userName': 'Kotchawan.A',
                'email': 'kotchawan.a@jamour.co.th',
                'userNameThai': 'กชวรรณ เอนกลาภ',
                'userNameEng': 'Kotchawan Aneklap',
                'employeeID': 'E2022-084',
                'inactive': false,
                'userGroupType': 'Employee',
                'defaultLanguage': 'Thai',
                'companyID': 'JCORP',
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );

    final user = await repository.getUser('employee name');

    expect(
      captured.url.toString(),
      'https://customer.example.com/api/User/GetUser/employee%20name',
    );
    expect(captured.headers['Authorization'], 'Bearer jamore-token');
    expect(user.userName, 'Kotchawan.A');
    expect(user.employeeId, 'E2022-084');
    expect(user.defaultLanguage, 'Thai');
    expect(user.inactive, isFalse);
  });
}
