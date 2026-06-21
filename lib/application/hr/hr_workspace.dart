import '../../domain/entities/hr_models.dart';
import '../../domain/repositories/app_data_repository.dart';

class HrWorkspace {
  HrWorkspace(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDataRepository _repository;
  final DateTime Function() _clock;

  late DemoData data;

  Future<void> initialize() async => data = await _repository.load();

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
    return halfDay && value == 1 ? .5 : value;
  }

  Future<void> updateSession({
    bool? hasLoggedIn,
    bool? rememberMe,
    required bool sessionActive,
    String? localeCode,
  }) async {
    data = data.copyWith(
      hasLoggedIn: hasLoggedIn,
      rememberMe: rememberMe,
      sessionActive: sessionActive,
      localeCode: localeCode,
    );
    await _persist();
  }

  Future<void> setLocale(String code) async {
    if (code == data.localeCode) return;
    data = data.copyWith(localeCode: code);
    await _persist();
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
    await _persist();
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
    await _persist();
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
    await _persist();
  }

  Future<OvertimeRequest> submitOvertime({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required double rate,
    required String reason,
  }) async {
    final request = OvertimeRequest(
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
    data = data.copyWith(overtimeRequests: [request, ...data.overtimeRequests]);
    await _persist();
    return request;
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
    await _persist();
  }

  WorkLog? get todayLog {
    final now = _clock();
    for (final log in data.workLogs) {
      if (sameDay(log.date, now)) return log;
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
    await _persist();
  }

  Future<void> reset({required bool authenticated}) async {
    final localeCode = data.localeCode;
    data = await _repository.reset(localeCode: localeCode);
    data = data.copyWith(
      hasLoggedIn: authenticated,
      sessionActive: authenticated,
      rememberMe: authenticated,
    );
    await _persist();
  }

  bool _isHoliday(DateTime date) {
    final current = _clock();
    return [
      day(current, 20),
      day(current, 45),
      day(current, 90),
    ].any((holiday) => sameDay(holiday, date));
  }

  Future<void> _persist() => _repository.save(data);

  static DateTime day(DateTime value, [int offset = 0]) =>
      DateTime(value.year, value.month, value.day).add(Duration(days: offset));

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
