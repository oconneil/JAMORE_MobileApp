import 'package:jamore/auth/auth_models.dart';
import 'package:jamore/auth/auth_repository.dart';
import 'package:jamore/company/company_repository.dart';
import 'package:jamore/company/company_models.dart';
import 'package:jamore/data/app_repository.dart';
import 'package:jamore/data/local_store.dart';
import 'package:jamore/employee/employee_repository.dart';
import 'package:jamore/employee/employee_models.dart';
import 'package:jamore/state/app_state.dart';
import 'package:jamore/user/user_models.dart';
import 'package:jamore/user/user_repository.dart';

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
  String? requestedUserName;

  @override
  Future<Object?> getUserCompany(String userName) async {
    requestedUserName = userName;

    return {'status': 'Success', 'value': []};
  }

  @override
  Future<CompanyDetails> getCompany(String companyId) async {
    return CompanyDetails(
      companyId: companyId,
      jamoreApiServer: 'https://customer.example.com/',
      raw: {
        'companyID': companyId,
        'companyNameThai': 'บริษัททดสอบ',
        'companyNameEng': 'Test Company',
        'jamoreAPIServer': 'https://customer.example.com/',
      },
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
      raw: {'userName': userName, 'employeeID': employeeId},
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
      raw: {'employeeID': employeeId},
      displayRaw: const {},
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
  final state = AppState(
    AppRepository(store ?? MemoryStore(), clock: resolvedClock),
    authGateway ?? FakeAuthGateway(clock: resolvedClock),
    FakeCompanyGateway(),
    userGateway ?? FakeUserGateway(),
    employeeGateway ?? FakeEmployeeGateway(),
    clock: resolvedClock,
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
      throw const AuthException('Invalid credentials');
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

Future<bool> login(AppState state) => state.login(
  username: 'nattawut.c',
  password: 'jamore123',
  companyId: 'JAMORE-TH',
  rememberMe: true,
);
