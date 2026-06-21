import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/data/repositories/api_user_repository.dart';
import 'package:jamore/domain/repositories/repository_failure.dart';
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

  test('posts the complete profile when updating default language', () async {
    final requests = <http.Request>[];
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final profile = <String, Object?>{
      'id': 'user/id',
      'userName': 'Kotchawan.A',
      'email': 'kotchawan.a@jamour.co.th',
      'employeeID': 'E2022-084',
      'roleID': 'Employee',
      'activeSalary': true,
      'defaultLanguage': 'Thai',
      'companyID': 'JCORP',
      'inactive': false,
    };
    final repository = ApiUserRepository(
      JamoreApiClient(
        connection: connection,
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'status': 'Success',
                'message': '',
                'value': profile,
              }),
              200,
            );
          }
          final body = Map<String, Object?>.from(
            jsonDecode(request.body) as Map,
          );
          return http.Response(
            jsonEncode({'status': 'Success', 'message': '', 'value': body}),
            200,
          );
        }),
      ),
    );

    final user = await repository.getUser('Kotchawan.A');
    final updated = await repository.updateDefaultLanguage(
      user: user,
      defaultLanguage: 'English',
    );

    final request = requests.last;
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(request.method, 'POST');
    expect(
      request.url.toString(),
      'https://customer.example.com/api/User/UpdateUserProfile/user%2Fid',
    );
    expect(body['defaultLanguage'], 'English');
    expect(body['roleID'], 'Employee');
    expect(body['activeSalary'], isTrue);
    expect(body['companyID'], 'JCORP');
    expect(updated.defaultLanguage, 'English');
  });

  test('rejects a failed profile update envelope', () async {
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
          final value = {
            'id': 'user-id',
            'userName': 'Kotchawan.A',
            'defaultLanguage': 'Thai',
            'companyID': 'JCORP',
          };
          return http.Response(
            jsonEncode({
              'status': request.method == 'GET' ? 'Success' : 'Failed',
              'message': request.method == 'GET' ? '' : 'Update failed.',
              'value': value,
            }),
            200,
          );
        }),
      ),
    );

    final user = await repository.getUser('Kotchawan.A');

    expect(
      repository.updateDefaultLanguage(user: user, defaultLanguage: 'English'),
      throwsA(
        isA<RepositoryFailure>().having(
          (error) => error.message,
          'message',
          'Update failed.',
        ),
      ),
    );
  });
}
