import 'package:flutter/material.dart';

import '../presentation/adaptive_shell.dart';
import '../presentation/login_screen.dart';
import '../state/app_state.dart';

class JamorePath {
  const JamorePath(this.location);
  final String location;
}

class JamoreRouteParser extends RouteInformationParser<JamorePath> {
  const JamoreRouteParser();

  @override
  Future<JamorePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    final path = uri.path.isEmpty ? '/' : uri.path;
    return JamorePath(path);
  }

  @override
  RouteInformation? restoreRouteInformation(JamorePath configuration) =>
      RouteInformation(uri: Uri.parse(configuration.location));
}

class JamoreRouterDelegate extends RouterDelegate<JamorePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<JamorePath> {
  JamoreRouterDelegate(this.state) {
    state.addListener(notifyListeners);
  }

  final AppState state;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  JamorePath get currentConfiguration => JamorePath(state.location);

  @override
  Widget build(BuildContext context) {
    final child = state.isAuthenticated
        ? AdaptiveShell(location: state.location)
        : const LoginScreen();
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: ValueKey(
            state.isAuthenticated ? 'app-${state.location}' : 'login',
          ),
          child: child,
        ),
      ],
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(JamorePath configuration) async {
    state.acceptExternalRoute(configuration.location);
  }

  @override
  Future<bool> popRoute() async {
    final parent = parentLocation(state.location);
    if (parent == state.location) return false;
    state.navigate(parent);
    return true;
  }

  @override
  void dispose() {
    state.removeListener(notifyListeners);
    super.dispose();
  }
}

String parentLocation(String location) {
  if (location.startsWith('/leave/') && location != '/leave') return '/leave';
  if (location.startsWith('/overtime/') && location != '/overtime') {
    return '/overtime';
  }
  if (location.startsWith('/worktime/') && location != '/worktime') {
    return '/worktime';
  }
  if (location.startsWith('/soon/')) return '/profile';
  return location;
}
