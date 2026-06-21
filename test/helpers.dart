import 'package:jamore/application/hr/hr_workspace.dart';
import 'package:jamore/application/ports/customer_api_session.dart';
import 'package:jamore/application/session/session_coordinator.dart';
import 'package:jamore/data/repositories/local_app_data_repository.dart';
import 'package:jamore/domain/entities/auth_session.dart';
import 'package:jamore/domain/entities/company_details.dart';
import 'package:jamore/domain/entities/employee_details.dart';
import 'package:jamore/domain/entities/user_details.dart';
import 'package:jamore/domain/repositories/auth_gateway.dart';
import 'package:jamore/domain/repositories/company_gateway.dart';
import 'package:jamore/domain/repositories/employee_gateway.dart';
import 'package:jamore/domain/repositories/repository_failure.dart';
import 'package:jamore/domain/repositories/user_gateway.dart';
import 'package:jamore/infrastructure/storage/local_store.dart';
import 'package:jamore/state/app_state.dart';

class MemoryStore implements LocalStore {
  Map<String, Object?>? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<Map<String, Object?>?> read() async => value;

  @override
  Future<void> write(Map<String, Object?> data) async => value = data;
}

class FakeCompanyGateway implements CompanyGateway {
  @override
  Future<CompanyDetails> getCompany(String companyId) async {
    return CompanyDetails(
      companyId: companyId,
      jamoreApiServer: 'https://customer.example.com/',
    );
  }
}

class FakeUserGateway implements UserGateway {
  FakeUserGateway({this.employeeId = 'E2022-084'});

  final String? employeeId;
  String? requestedUserName;

  @override
  Future<UserDetails> getUser(String userName) async {
    requestedUserName = userName;
    return UserDetails(
      id: 'user-id',
      userName: userName,
      employeeId: employeeId,
      defaultLanguage: 'Thai',
      companyId: 'JAMORE-TH',
    );
  }
}

class FakeEmployeeGateway implements EmployeeGateway {
  FakeEmployeeGateway({this.positionId = 'SE-DEL'});

  final String? positionId;
  String? requestedEmployeeId;

  @override
  Future<EmployeeDetails> getEmployee(String employeeId) async {
    requestedEmployeeId = employeeId;
    return EmployeeDetails(
      employeeId: employeeId,
      fullNameThai: 'กชวรรณ  เอนกลาภ',
      fullNameEng: 'Kotchawan  Aneklap',
      positionId: positionId,
      positionNameThai: 'หัวหน้าวิศวกรพัฒนาซอฟต์แวร์',
      positionNameEng: 'Software Development Engineer Leader',
    );
  }
}

Future<AppState> createTestState({
  DateTime Function()? clock,
  MemoryStore? store,
  FakeAuthGateway? authGateway,
  UserGateway? userGateway,
  EmployeeGateway? employeeGateway,
}) async {
  final resolvedClock = clock ?? () => DateTime(2026, 6, 20, 8, 30);
  final resolvedAuth = authGateway ?? FakeAuthGateway(clock: resolvedClock);
  final workspace = HrWorkspace(
    LocalAppDataRepository(store ?? MemoryStore(), clock: resolvedClock),
    clock: resolvedClock,
  );
  final state = AppState(
    workspace,
    SessionCoordinator(
      authGateway: resolvedAuth,
      companyGateway: FakeCompanyGateway(),
      userGateway: userGateway ?? FakeUserGateway(),
      employeeGateway: employeeGateway ?? FakeEmployeeGateway(),
      customerApiSession: FakeCustomerApiSession(),
    ),
  );
  await state.initialize();
  return state;
}

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  AuthSession? session;

  @override
  String? get accessToken => session?.token;

  @override
  Future<AuthSession> login({
    required String userName,
    required String password,
    String? companyId,
    required bool rememberMe,
  }) async {
    if (userName != 'nattawut.c' || password != 'jamore123') {
      throw const RepositoryFailure('Invalid credentials');
    }
    return session = AuthSession(
      userName: userName,
      companyId: companyId,
      token: 'test-token',
      jamoreToken: 'test-jamore-token',
      expiration: _clock().toUtc().add(const Duration(days: 1)),
      firstLogin: false,
      passwordExpired: false,
      defaultLanguage: 'th',
      isAdmin: false,
    );
  }

  @override
  Future<void> logout() async => session = null;

  @override
  Future<AuthSession?> restoreSession() async => session;
}

class FakeCustomerApiSession implements CustomerApiSession {
  @override
  void clear() {}

  @override
  void configure({
    required String apiServer,
    required String accessToken,
    required String companyId,
  }) {}
}

Future<bool> login(AppState state) => state.login(
  username: 'nattawut.c',
  password: 'jamore123',
  companyId: 'JAMORE-TH',
  rememberMe: true,
);
