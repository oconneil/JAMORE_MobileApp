import '../network/api_client.dart';
import 'company_models.dart';

abstract interface class CompanyGateway {
  Future<Object?> getUserCompany(String userName);

  Future<CompanyDetails> getCompany(String companyId);
}

class CompanyRepository implements CompanyGateway {
  CompanyRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Object?> getUserCompany(String userName) {
    final encodedUserName = Uri.encodeComponent(userName.trim());

    return _apiClient.get('Company/GetUserCompany/$encodedUserName');
  }

  @override
  Future<CompanyDetails> getCompany(String companyId) async {
    final normalized = companyId.trim();
    final encodedCompanyId = Uri.encodeComponent(normalized);

    final response = await _apiClient.get(
      'Company/Get/$encodedCompanyId',
      headers: {'x-companyid': normalized},
    );
    return CompanyDetails.fromApiResponse(response);
  }
}
