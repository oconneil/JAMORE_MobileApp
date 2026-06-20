import '../network/jamore_api_client.dart';
import 'employee_models.dart';

abstract interface class EmployeeGateway {
  Future<EmployeeDetails> getEmployee(String employeeId);
}

class EmployeeRepository implements EmployeeGateway {
  EmployeeRepository(this._apiClient);

  final JamoreApiClient _apiClient;

  @override
  Future<EmployeeDetails> getEmployee(String employeeId) async {
    final encodedEmployeeId = Uri.encodeComponent(employeeId.trim());

    final response = await _apiClient.get('Employee/Get/$encodedEmployeeId');
    return EmployeeDetails.fromApiResponse(response);
  }
}
