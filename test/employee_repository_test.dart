import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamore/data/repositories/api_employee_repository.dart';
import 'package:jamore/infrastructure/network/jamore_api_client.dart';

void main() {
  test('calls customer Employee/Get with TokenJamore', () async {
    late http.Request captured;
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final repository = ApiEmployeeRepository(
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
                  'startDate': '2022-04-18',
                  'positionID': 'SE-DEL',
                  'departmentID': 'SE',
                },
                'display': {
                  'positionNameThai': 'หัวหน้าวิศวกรพัฒนาซอฟต์แวร์',
                  'positionNameEng': 'Software Development Engineer Leader',
                  'departmentNameThai': 'วิศวกรรมซอฟต์แวร์',
                  'departmentNameEng': 'Software Engineering',
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
    expect(employee.departmentNameThai, 'วิศวกรรมซอฟต์แวร์');
    expect(employee.departmentNameEng, 'Software Engineering');
    expect(employee.startDate, DateTime(2022, 4, 18));
  });

  test('loads employee image bytes from authenticated customer API', () async {
    late http.Request captured;
    final expected = Uint8List.fromList([1, 2, 3, 4]);
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final repository = ApiEmployeeRepository(
      JamoreApiClient(
        connection: connection,
        client: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            expected,
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }),
      ),
    );

    final result = await repository.getEmployeeImage('E2022 084');

    expect(result, expected);
    expect(
      captured.url.toString(),
      'https://customer.example.com/api/Employee/GetEmployeeImage/E2022%20084',
    );
    expect(captured.headers['Authorization'], 'Bearer jamore-token');
    expect(captured.headers['x-companyid'], 'JAMORE-TH');
    expect(captured.headers['Accept'], 'image/*');
  });

  test('decodes base64 image from Jamore JSON envelope', () async {
    final expected = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
    final connection = JamoreApiConnection()
      ..configure(
        apiServer: 'https://customer.example.com/',
        accessToken: 'jamore-token',
        companyId: 'JAMORE-TH',
      );
    final repository = ApiEmployeeRepository(
      JamoreApiClient(
        connection: connection,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'status': 'Success',
              'message': '',
              'value': base64Encode(expected),
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      ),
    );

    final result = await repository.getEmployeeImage('E2022-084');

    expect(result, expected);
  });
}
