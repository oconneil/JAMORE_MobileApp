import 'package:flutter/material.dart';

import '../application/hr/hr_workspace.dart';
import '../application/session/session_coordinator.dart';
import '../domain/entities/employee_details.dart';
import '../domain/entities/hr_models.dart';
import '../domain/entities/user_details.dart';

/// Presentation state only. Business rules and external orchestration live in
/// application modules injected through the composition root.
class AppState extends ChangeNotifier {
  AppState(this._workspace, this._sessionCoordinator);

  final HrWorkspace _workspace;
  final SessionCoordinator _sessionCoordinator;

  UserDetails? currentUser;
  EmployeeDetails? currentEmployee;
  bool initialized = false;
  String location = '/login';
  String? loginError;

  DemoData get data => _workspace.data;
  Locale get locale => Locale(data.localeCode);
  bool get isAuthenticated => data.sessionActive;

  String employeeDisplayName({required bool isThai}) {
    final employeeName = currentEmployee?.displayName(isThai: isThai);
    if (employeeName != null) return employeeName;
    final user = currentUser;
    final preferred = isThai ? user?.userNameThai : user?.userNameEng;
    final fallback = isThai ? user?.userNameEng : user?.userNameThai;
    return preferred ?? fallback ?? user?.userName ?? '';
  }

  String? employeePositionName({required bool isThai}) =>
      currentEmployee?.displayPositionName(isThai: isThai);

  Future<void> initialize() async {
    await _workspace.initialize();
    final session = data.rememberMe
        ? await _sessionCoordinator.restoreSession()
        : null;
    await _workspace.updateSession(sessionActive: session != null);
    location = isAuthenticated ? '/dashboard' : '/login';
    initialized = true;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
    required String companyId,
    required bool rememberMe,
  }) async {
    loginError = null;
    _clearProfile();
    try {
      final session = await _sessionCoordinator.signIn(
        username: username,
        password: password,
        companyId: companyId,
        rememberMe: rememberMe,
      );
      currentUser = session.user;
      currentEmployee = session.employee;
      await _workspace.updateSession(
        localeCode: _languageCode(
          session.user.defaultLanguage ?? session.auth.defaultLanguage,
        ),
        hasLoggedIn: true,
        rememberMe: rememberMe,
        sessionActive: true,
      );
      location = session.auth.passwordExpired
          ? '/soon/change-password'
          : '/dashboard';
      notifyListeners();
      return true;
    } on SessionFailure catch (error) {
      loginError = error.message;
    }
    notifyListeners();
    return false;
  }

  Future<bool> biometricLogin() async {
    if (!data.hasLoggedIn || !_sessionCoordinator.hasActiveToken) return false;
    await _workspace.updateSession(sessionActive: true);
    location = '/dashboard';
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _sessionCoordinator.signOut();
    _clearProfile();
    await _workspace.updateSession(sessionActive: false);
    location = '/login';
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (code == data.localeCode) return;
    await _workspace.setLocale(code);
    notifyListeners();
  }

  void navigate(String next) {
    if (location == next) return;
    location = next;
    notifyListeners();
  }

  void acceptExternalRoute(String next) {
    final normalized = next.isEmpty || next == '/' ? '/dashboard' : next;
    location = isAuthenticated
        ? (normalized == '/login' ? '/dashboard' : normalized)
        : '/login';
    notifyListeners();
  }

  LeaveBalance balanceFor(LeaveKind kind) => _workspace.balanceFor(kind);

  double workingDays(DateTime start, DateTime end, {bool halfDay = false}) =>
      _workspace.workingDays(start, end, halfDay: halfDay);

  Future<LeaveRequest> submitLeave({
    required LeaveKind kind,
    required DateTime start,
    required DateTime end,
    required double days,
    required String reason,
    AttachmentMeta? attachment,
  }) async {
    final request = await _workspace.submitLeave(
      kind: kind,
      start: start,
      end: end,
      days: days,
      reason: reason,
      attachment: attachment,
    );
    notifyListeners();
    return request;
  }

  Future<void> cancelLeave(String id) async {
    await _workspace.cancelLeave(id);
    notifyListeners();
  }

  Future<void> decideApproval(String id, bool approve, {String? reason}) async {
    await _workspace.decideApproval(id, approve, reason: reason);
    notifyListeners();
  }

  Future<OvertimeRequest> submitOvertime({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required double rate,
    required String reason,
  }) async {
    final request = await _workspace.submitOvertime(
      date: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      rate: rate,
      reason: reason,
    );
    notifyListeners();
    return request;
  }

  Future<void> cancelOvertime(String id) async {
    await _workspace.cancelOvertime(id);
    notifyListeners();
  }

  WorkLog? get todayLog => _workspace.todayLog;

  Future<void> recordTime() async {
    await _workspace.recordTime();
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    await _workspace.reset(authenticated: isAuthenticated);
    notifyListeners();
  }

  void _clearProfile() {
    currentUser = null;
    currentEmployee = null;
  }

  static bool sameDay(DateTime a, DateTime b) => HrWorkspace.sameDay(a, b);

  static String? _languageCode(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null) return null;
    if (normalized == 'th' || normalized.startsWith('thai')) return 'th';
    if (normalized == 'en' || normalized.startsWith('eng')) return 'en';
    return null;
  }
}
