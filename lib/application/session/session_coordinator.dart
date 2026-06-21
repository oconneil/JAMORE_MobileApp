import '../../domain/entities/auth_session.dart';
import '../../domain/entities/employee_details.dart';
import '../../domain/entities/user_details.dart';
import '../../domain/repositories/auth_gateway.dart';
import '../../domain/repositories/company_gateway.dart';
import '../../domain/repositories/employee_gateway.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../domain/repositories/user_gateway.dart';
import '../ports/customer_api_session.dart';

class AuthenticatedSession {
  const AuthenticatedSession({
    required this.auth,
    required this.user,
    required this.employee,
  });

  final AuthSession auth;
  final UserDetails user;
  final EmployeeDetails? employee;
}

class SessionFailure implements Exception {
  const SessionFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}

class SessionCoordinator {
  factory SessionCoordinator({
    required AuthGateway authGateway,
    required CompanyGateway companyGateway,
    required UserGateway userGateway,
    required EmployeeGateway employeeGateway,
    required CustomerApiSession customerApiSession,
  }) => SessionCoordinator._(
    authGateway,
    companyGateway,
    userGateway,
    employeeGateway,
    customerApiSession,
  );

  SessionCoordinator._(
    this._authGateway,
    this._companyGateway,
    this._userGateway,
    this._employeeGateway,
    this._customerApiSession,
  );

  final AuthGateway _authGateway;
  final CompanyGateway _companyGateway;
  final UserGateway _userGateway;
  final EmployeeGateway _employeeGateway;
  final CustomerApiSession _customerApiSession;

  bool get hasActiveToken => _authGateway.accessToken != null;

  Future<AuthSession?> restoreSession() => _authGateway.restoreSession();

  Future<AuthenticatedSession> signIn({
    required String username,
    required String password,
    required String companyId,
    required bool rememberMe,
  }) async {
    _customerApiSession.clear();
    try {
      final auth = await _authGateway.login(
        userName: username,
        password: password,
        companyId: companyId,
        rememberMe: rememberMe,
      );
      final resolvedCompanyId = auth.companyId?.toString().trim();
      if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
        throw const SessionFailure('Company ID is missing.');
      }

      final company = await _companyGateway.getCompany(resolvedCompanyId);
      _customerApiSession.configure(
        apiServer: company.jamoreApiServer,
        accessToken: auth.jamoreToken,
      );

      final user = await _userGateway.getUser(auth.userName);
      final employee = user.employeeId == null
          ? null
          : await _employeeGateway.getEmployee(user.employeeId!);
      return AuthenticatedSession(auth: auth, user: user, employee: employee);
    } on SessionFailure {
      _customerApiSession.clear();
      rethrow;
    } on RepositoryFailure catch (error) {
      _customerApiSession.clear();
      throw SessionFailure(error.message, cause: error);
    } on Object catch (error) {
      _customerApiSession.clear();
      throw SessionFailure('Unable to sign in.', cause: error);
    }
  }

  Future<void> signOut() async {
    await _authGateway.logout();
    _customerApiSession.clear();
  }
}
