import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'application/hr/hr_workspace.dart';
import 'application/ports/attachment_picker.dart';
import 'application/session/session_coordinator.dart';
import 'data/repositories/api_auth_repository.dart';
import 'data/repositories/api_company_repository.dart';
import 'data/repositories/api_employee_repository.dart';
import 'data/repositories/api_user_repository.dart';
import 'data/repositories/local_app_data_repository.dart';
import 'infrastructure/network/api_client.dart';
import 'infrastructure/network/jamore_api_client.dart';
import 'infrastructure/platform/platform_attachment_picker.dart';
import 'infrastructure/storage/local_store.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final ApiAuthRepository authRepository;
  final apiClient = ApiClient(
    accessTokenProvider: () => authRepository.accessToken,
  );
  authRepository = ApiAuthRepository(apiClient);
  final companyRepository = ApiCompanyRepository(apiClient);
  final jamoreApiConnection = JamoreApiConnection();
  final jamoreApiClient = JamoreApiClient(connection: jamoreApiConnection);
  final userRepository = ApiUserRepository(jamoreApiClient);
  final employeeRepository = ApiEmployeeRepository(jamoreApiClient);
  final sessionCoordinator = SessionCoordinator(
    authGateway: authRepository,
    companyGateway: companyRepository,
    userGateway: userRepository,
    employeeGateway: employeeRepository,
    customerApiSession: jamoreApiConnection,
  );
  final workspace = HrWorkspace(LocalAppDataRepository(createLocalStore()));
  final state = AppState(workspace, sessionCoordinator);
  await state.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<AttachmentPicker>.value(
          value: const PlatformAttachmentPicker(),
        ),
        ChangeNotifierProvider.value(value: state),
      ],
      child: const JamoreApp(),
    ),
  );
}
