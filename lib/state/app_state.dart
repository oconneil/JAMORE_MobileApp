import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../auth/auth_repository.dart';
import '../data/app_repository.dart';
import '../company/company_repository.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../employee/employee_repository.dart';
import '../employee/employee_models.dart';
import '../network/api_exception.dart';
import '../network/jamore_api_client.dart';
import '../user/user_models.dart';
import '../user/user_repository.dart';

class AppState extends ChangeNotifier {
  AppState(
    this._repository,
    this._authGateway,
    this._companyGateway,
    this._userGateway,
    this._employeeGateway, {
    JamoreApiConnection? jamoreApiConnection,
    DateTime Function()? clock,
  }) : _jamoreApiConnection = jamoreApiConnection ?? JamoreApiConnection(),
       _clock = clock ?? DateTime.now;

  final AppRepository _repository;
  final AuthGateway _authGateway;
  final CompanyGateway _companyGateway;
  final UserGateway _userGateway;
  final EmployeeGateway _employeeGateway;
  final JamoreApiConnection _jamoreApiConnection;
  final DateTime Function() _clock;

  Object? userCompanyResponse;
  Object? currentUserResponse;
  UserDetails? currentUser;
  Object? currentEmployeeResponse;
  EmployeeDetails? currentEmployee;
  late DemoData data;
  bool initialized = false;
  String location = '/login';
  String? loginError;

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
    data = await _repository.load();
    final session = data.rememberMe
        ? await _authGateway.restoreSession()
        : null;
    data = data.copyWith(sessionActive: session != null);
    location = data.sessionActive ? '/dashboard' : '/login';
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
    _jamoreApiConnection.clear();
    userCompanyResponse = null;
    currentUserResponse = null;
    currentUser = null;
    currentEmployeeResponse = null;
    currentEmployee = null;
    try {
      final session = await _authGateway.login(
        userName: username,
        password: password,
        companyId: companyId,
        rememberMe: rememberMe,
      );
      final sessionCompanyId = session.companyId?.toString().trim();
      if (sessionCompanyId == null || sessionCompanyId.isEmpty) {
        throw const AuthException('Company ID is missing.');
      }
      final company = await _companyGateway.getCompany(sessionCompanyId);
      _jamoreApiConnection.configure(
        apiServer: company.jamoreApiServer,
        accessToken: session.jamoreToken,
      );
      userCompanyResponse = company.raw;
      final user = await _userGateway.getUser(session.userName);
      currentUser = user;
      currentUserResponse = user.raw;
      final employeeId = user.employeeId;
      if (employeeId != null) {
        final employee = await _employeeGateway.getEmployee(employeeId);
        currentEmployee = employee;
        currentEmployeeResponse = employee.raw;
      }
      final language = _languageCode(
        user.defaultLanguage ?? session.defaultLanguage,
      );
      data = data.copyWith(
        localeCode: language ?? data.localeCode,
        hasLoggedIn: true,
        rememberMe: rememberMe,
        sessionActive: true,
      );
      location = session.passwordExpired
          ? '/soon/change-password'
          : '/dashboard';
      await _persist();
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      loginError = error.message;
    } on ApiException catch (error) {
      loginError = error.message;
    } on Object {
      loginError = 'Unable to sign in.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> biometricLogin() async {
    if (!data.hasLoggedIn || _authGateway.accessToken == null) return false;
    data = data.copyWith(sessionActive: true);
    location = '/dashboard';
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _authGateway.logout();
    _jamoreApiConnection.clear();
    userCompanyResponse = null;
    currentUserResponse = null;
    currentUser = null;
    currentEmployeeResponse = null;
    currentEmployee = null;
    data = data.copyWith(sessionActive: false);
    location = '/login';
    await _persist();
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (code == data.localeCode) return;
    data = data.copyWith(localeCode: code);
    await _persist();
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

  LeaveBalance balanceFor(LeaveKind kind) =>
      data.leaveBalances.firstWhere((item) => item.kind == kind);

  double workingDays(DateTime start, DateTime end, {bool halfDay = false}) {
    if (end.isBefore(start)) return 0;
    var value = 0.0;
    var cursor = day(start);
    final last = day(end);
    while (!cursor.isAfter(last)) {
      if (cursor.weekday <= DateTime.friday && !_isHoliday(cursor)) value += 1;
      cursor = cursor.add(const Duration(days: 1));
    }
    if (halfDay && value == 1) return .5;
    return value;
  }

  bool _isHoliday(DateTime date) {
    final current = _clock();
    final holidays = <DateTime>[
      day(current, 20),
      day(current, 45),
      day(current, 90),
    ];
    return holidays.any((h) => _sameDay(h, date));
  }

  Future<LeaveRequest> submitLeave({
    required LeaveKind kind,
    required DateTime start,
    required DateTime end,
    required double days,
    required String reason,
    AttachmentMeta? attachment,
  }) async {
    final request = LeaveRequest(
      id: 'L-${(data.leaveRequests.length + 43).toString().padLeft(4, '0')}',
      kind: kind,
      start: start,
      end: end,
      days: days,
      status: RequestStatus.pending,
      reason: reason.trim(),
      submittedAt: _clock(),
      attachment: attachment,
    );
    data = data.copyWith(leaveRequests: [request, ...data.leaveRequests]);
    await _persistAndNotify();
    return request;
  }

  Future<void> cancelLeave(String id) async {
    data = data.copyWith(
      leaveRequests: data.leaveRequests
          .map(
            (item) => item.id == id && item.status == RequestStatus.pending
                ? item.copyWith(
                    status: RequestStatus.cancelled,
                    decidedAt: _clock(),
                  )
                : item,
          )
          .toList(),
    );
    await _persistAndNotify();
  }

  Future<void> decideApproval(String id, bool approve, {String? reason}) async {
    data = data.copyWith(
      teamApprovals: data.teamApprovals
          .map(
            (item) => item.id == id
                ? item.copyWith(
                    status: approve
                        ? RequestStatus.approved
                        : RequestStatus.rejected,
                    decisionReason: reason,
                    decidedAt: _clock(),
                  )
                : item,
          )
          .toList(),
    );
    await _persistAndNotify();
  }

  Future<OvertimeRequest> submitOvertime({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required double rate,
    required String reason,
  }) async {
    final item = OvertimeRequest(
      id: 'OT-${(data.overtimeRequests.length + 92).toString().padLeft(4, '0')}',
      date: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      rate: rate,
      hourlyWage: 250,
      status: RequestStatus.pending,
      reason: reason.trim(),
      submittedAt: _clock(),
    );
    data = data.copyWith(overtimeRequests: [item, ...data.overtimeRequests]);
    await _persistAndNotify();
    return item;
  }

  Future<void> cancelOvertime(String id) async {
    data = data.copyWith(
      overtimeRequests: data.overtimeRequests
          .map(
            (item) => item.id == id && item.status == RequestStatus.pending
                ? item.copyWith(status: RequestStatus.cancelled)
                : item,
          )
          .toList(),
    );
    await _persistAndNotify();
  }

  WorkLog? get todayLog {
    final now = _clock();
    for (final log in data.workLogs) {
      if (_sameDay(log.date, now)) return log;
    }
    return null;
  }

  Future<void> recordTime() async {
    final now = _clock();
    final current = todayLog;
    late final List<WorkLog> logs;
    if (current == null) {
      logs = [WorkLog(date: day(now), clockIn: now), ...data.workLogs];
    } else if (current.isWorking) {
      logs = data.workLogs
          .map(
            (log) =>
                identical(log, current) ? log.copyWith(clockOut: now) : log,
          )
          .toList();
    } else {
      return;
    }
    data = data.copyWith(workLogs: logs);
    await _persistAndNotify();
  }

  Future<void> resetDemoData() async {
    final code = data.localeCode;
    final authenticated = isAuthenticated;
    data = await _repository.reset(localeCode: code);
    data = data.copyWith(
      hasLoggedIn: authenticated,
      sessionActive: authenticated,
      rememberMe: authenticated,
    );
    await _persistAndNotify();
  }

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _repository.save(data);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool sameDay(DateTime a, DateTime b) => _sameDay(a, b);

  static String? _languageCode(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null) return null;
    if (normalized == 'th' || normalized.startsWith('thai')) return 'th';
    if (normalized == 'en' || normalized.startsWith('eng')) return 'en';
    return null;
  }
}
