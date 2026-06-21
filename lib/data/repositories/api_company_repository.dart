import '../../domain/entities/company_details.dart';
import '../../domain/repositories/company_gateway.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../infrastructure/network/api_client.dart';
import '../../infrastructure/network/api_exception.dart';
import '../mappers/api_profile_mappers.dart';

class ApiCompanyRepository implements CompanyGateway {
  ApiCompanyRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CompanyDetails> getCompany(String companyId) async {
    final normalized = companyId.trim();
    try {
      final response = await _apiClient.get(
        'Company/Get/${Uri.encodeComponent(normalized)}',
        headers: {'x-companyid': normalized},
      );
      return ApiProfileMappers.company(response);
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }
}
