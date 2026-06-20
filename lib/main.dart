import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'auth/auth_repository.dart';
import 'data/app_repository.dart';
import 'data/local_store.dart';
import 'employee/employee_repository.dart';
import 'network/api_client.dart';
import 'network/jamore_api_client.dart';
import 'state/app_state.dart';
import 'company/company_repository.dart';
import 'user/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final AuthRepository authRepository;
  final apiClient = ApiClient(
    accessTokenProvider: () => authRepository.accessToken,
  );
  authRepository = AuthRepository(apiClient);
  final companyRepository = CompanyRepository(apiClient);
  final jamoreApiConnection = JamoreApiConnection();
  final jamoreApiClient = JamoreApiClient(connection: jamoreApiConnection);
  final userRepository = UserRepository(jamoreApiClient);
  final employeeRepository = EmployeeRepository(jamoreApiClient);
  final state = AppState(
    AppRepository(createLocalStore()),
    authRepository,
    companyRepository,
    userRepository,
    employeeRepository,
    jamoreApiConnection: jamoreApiConnection,
  );
  await state.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<JamoreApiClient>.value(value: jamoreApiClient),
        Provider<AuthGateway>.value(value: authRepository),
        Provider<UserGateway>.value(value: userRepository),
        Provider<EmployeeGateway>.value(value: employeeRepository),
        ChangeNotifierProvider.value(value: state),
      ],
      child: const JamoreApp(),
    ),
  );
}
