import '../../domain/entities/employee_details.dart';
import '../../domain/repositories/employee_gateway.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../infrastructure/network/api_exception.dart';
import '../../infrastructure/network/jamore_api_client.dart';
import '../mappers/api_profile_mappers.dart';

class ApiEmployeeRepository implements EmployeeGateway {
  ApiEmployeeRepository(this._apiClient);

  final JamoreApiClient _apiClient;

  @override
  Future<EmployeeDetails> getEmployee(String employeeId) async {
    try {
      final response = await _apiClient.get(
        'Employee/Get/${Uri.encodeComponent(employeeId.trim())}',
      );
      return ApiProfileMappers.employee(response);
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }
}
