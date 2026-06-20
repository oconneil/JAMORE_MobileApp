import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/employee/employee_repository.dart';
import 'package:jamore/network/jamore_api_client.dart';

void main() {
  test('calls customer Employee/Get with TokenJamore', () async {
    late http.Request captured;
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
      );
    final repository = EmployeeRepository(
      JamoreApiClient(
        connection: connection,
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'status': 'Success',
              'message': '',
              'value': {
                'employee': {
                  'employeeID': 'E2022-084',
                  'employeeNameThai': 'กชวรรณ',
                  'employeeNameEng': 'Kotchawan',
                  'employeeLastnameThai': 'เอนกลาภ',
                  'employeeLastnameEng': 'Aneklap',
                  'fullNameThai': 'กชวรรณ  เอนกลาภ',
                  'fullNameEng': 'Kotchawan  Aneklap',
                  'imgFile': 'E2022-084.jpg',
                  'positionID': 'SE-DEL',
                  'departmentID': 'SE',
                },
                'display': {
                  'positionNameThai': 'หัวหน้าวิศวกรพัฒนาซอฟต์แวร์',
                  'positionNameEng': 'Software Development Engineer Leader',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );

    final employee = await repository.getEmployee('E2022 084');

    expect(
      captured.url.toString(),
      'https://customer.example.com/api/Employee/Get/E2022%20084',
    );
    expect(captured.headers['Authorization'], 'Bearer jamore-token');
    expect(employee.employeeId, 'E2022-084');
    expect(employee.displayName(isThai: true), 'กชวรรณ เอนกลาภ');
    expect(employee.displayName(isThai: false), 'Kotchawan Aneklap');
    expect(employee.positionNameEng, 'Software Development Engineer Leader');
  });
}
