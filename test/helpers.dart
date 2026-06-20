import 'package:jamore/auth/auth_models.dart';
import 'package:jamore/auth/auth_repository.dart';
import 'package:jamore/data/app_repository.dart';
import 'package:jamore/data/local_store.dart';
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

Future<AppState> createTestState({
  DateTime Function()? clock,
  MemoryStore? store,
  FakeAuthGateway? authGateway,
}) async {
  final resolvedClock = clock ?? () => DateTime(2026, 6, 20, 8, 30);
  final state = AppState(
    AppRepository(store ?? MemoryStore(), clock: resolvedClock),
    authGateway ?? FakeAuthGateway(clock: resolvedClock),
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
