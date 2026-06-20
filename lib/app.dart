import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'state/app_state.dart';

class JamoreApp extends StatefulWidget {
  const JamoreApp({super.key});

  @override
  State<JamoreApp> createState() => _JamoreAppState();
}

class _JamoreAppState extends State<JamoreApp> {
  JamoreRouterDelegate? _delegate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _delegate ??= JamoreRouterDelegate(context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppState, Locale>((state) => state.locale);
    return MaterialApp.router(
      title: 'JAMORE',
      debugShowCheckedModeBanner: false,
      theme: JamoreTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routeInformationParser: const JamoreRouteParser(),
      routerDelegate: _delegate!,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}
