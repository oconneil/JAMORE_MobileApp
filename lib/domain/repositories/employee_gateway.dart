import '../entities/employee_details.dart';

abstract interface class EmployeeGateway {
  Future<EmployeeDetails> getEmployee(String employeeId);
}
