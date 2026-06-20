import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'auth/auth_repository.dart';
import 'data/app_repository.dart';
import 'data/local_store.dart';
import 'network/api_client.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final AuthRepository authRepository;
  final apiClient = ApiClient(
    accessTokenProvider: () => authRepository.accessToken,
  );
  authRepository = AuthRepository(apiClient);
  final state = AppState(AppRepository(createLocalStore()), authRepository);
  await state.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthGateway>.value(value: authRepository),
        ChangeNotifierProvider.value(value: state),
      ],
      child: const JamoreApp(),
    ),
  );
}
