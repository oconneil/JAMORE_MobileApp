import '../entities/company_details.dart';

abstract interface class CompanyGateway {
  Future<CompanyDetails> getCompany(String companyId);
}
