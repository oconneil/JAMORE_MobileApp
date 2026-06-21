import 'dart:typed_data';

import '../entities/employee_details.dart';

abstract interface class EmployeeGateway {
  Future<EmployeeDetails> getEmployee(String employeeId);

  Future<Uint8List> getEmployeeImage(String employeeId);
}
