enum RequestStatus { approved, pending, rejected, cancelled }

enum LeaveKind { annual, sick, personal, maternity }

enum QuickActionId {
  leave,
  overtime,
  shift,
  payslip,
  teamCalendar,
  holidays,
  expense,
  announcements,
}

class QuickActionPreference {
  const QuickActionPreference({
    required this.id,
    required this.visible,
    required this.deleted,
  });

  final QuickActionId id;
  final bool visible;
  final bool deleted;

  QuickActionPreference copyWith({bool? visible, bool? deleted}) =>
      QuickActionPreference(
        id: id,
        visible: visible ?? this.visible,
        deleted: deleted ?? this.deleted,
      );
}

const defaultQuickActionPreferences = <QuickActionPreference>[
  QuickActionPreference(id: QuickActionId.leave, visible: true, deleted: false),
  QuickActionPreference(
    id: QuickActionId.overtime,
    visible: true,
    deleted: false,
  ),
  QuickActionPreference(id: QuickActionId.shift, visible: true, deleted: false),
  QuickActionPreference(
    id: QuickActionId.payslip,
    visible: true,
    deleted: false,
  ),
  QuickActionPreference(
    id: QuickActionId.teamCalendar,
    visible: false,
    deleted: false,
  ),
  QuickActionPreference(
    id: QuickActionId.holidays,
    visible: false,
    deleted: false,
  ),
  QuickActionPreference(
    id: QuickActionId.expense,
    visible: false,
    deleted: false,
  ),
  QuickActionPreference(
    id: QuickActionId.announcements,
    visible: false,
    deleted: false,
  ),
];

class AttachmentMeta {
  const AttachmentMeta({
    required this.name,
    required this.mime,
    required this.bytes,
  });

  final String name;
  final String mime;
  final int bytes;
}

class LeaveBalance {
  const LeaveBalance({
    required this.kind,
    required this.used,
    required this.total,
  });

  final LeaveKind kind;
  final double used;
  final double total;

  double get remaining => total - used;

  LeaveBalance copyWith({double? used}) =>
      LeaveBalance(kind: kind, used: used ?? this.used, total: total);
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.kind,
    required this.start,
    required this.end,
    required this.days,
    required this.status,
    required this.reason,
    required this.submittedAt,
    this.attachment,
    this.decisionReason,
    this.decidedAt,
  });

  final String id;
  final LeaveKind kind;
  final DateTime start;
  final DateTime end;
  final double days;
  final RequestStatus status;
  final String reason;
  final DateTime submittedAt;
  final AttachmentMeta? attachment;
  final String? decisionReason;
  final DateTime? decidedAt;

  LeaveRequest copyWith({
    RequestStatus? status,
    String? decisionReason,
    DateTime? decidedAt,
  }) => LeaveRequest(
    id: id,
    kind: kind,
    start: start,
    end: end,
    days: days,
    status: status ?? this.status,
    reason: reason,
    submittedAt: submittedAt,
    attachment: attachment,
    decisionReason: decisionReason ?? this.decisionReason,
    decidedAt: decidedAt ?? this.decidedAt,
  );
}

class OvertimeRequest {
  const OvertimeRequest({
    required this.id,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.rate,
    required this.hourlyWage,
    required this.status,
    required this.reason,
    required this.submittedAt,
  });

  final String id;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final double rate;
  final double hourlyWage;
  final RequestStatus status;
  final String reason;
  final DateTime submittedAt;

  double get hours => (endMinutes - startMinutes) / 60;
  int get amount => (hours * hourlyWage * rate).round();

  OvertimeRequest copyWith({RequestStatus? status}) => OvertimeRequest(
    id: id,
    date: date,
    startMinutes: startMinutes,
    endMinutes: endMinutes,
    rate: rate,
    hourlyWage: hourlyWage,
    status: status ?? this.status,
    reason: reason,
    submittedAt: submittedAt,
  );
}

class TeamApproval {
  const TeamApproval({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.kind,
    required this.start,
    required this.end,
    required this.days,
    required this.reasonTh,
    required this.reasonEn,
    required this.status,
    this.decisionReason,
    this.decidedAt,
  });

  final String id;
  final String nameTh;
  final String nameEn;
  final LeaveKind kind;
  final DateTime start;
  final DateTime end;
  final double days;
  final String reasonTh;
  final String reasonEn;
  final RequestStatus status;
  final String? decisionReason;
  final DateTime? decidedAt;

  TeamApproval copyWith({
    RequestStatus? status,
    String? decisionReason,
    DateTime? decidedAt,
  }) => TeamApproval(
    id: id,
    nameTh: nameTh,
    nameEn: nameEn,
    kind: kind,
    start: start,
    end: end,
    days: days,
    reasonTh: reasonTh,
    reasonEn: reasonEn,
    status: status ?? this.status,
    decisionReason: decisionReason ?? this.decisionReason,
    decidedAt: decidedAt ?? this.decidedAt,
  );
}

class WorkLog {
  const WorkLog({required this.date, this.clockIn, this.clockOut});

  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;

  bool get isWorking => clockIn != null && clockOut == null;
  Duration get duration => clockIn == null
      ? Duration.zero
      : (clockOut ?? DateTime.now()).difference(clockIn!);

  WorkLog copyWith({DateTime? clockIn, DateTime? clockOut}) => WorkLog(
    date: date,
    clockIn: clockIn ?? this.clockIn,
    clockOut: clockOut ?? this.clockOut,
  );
}

class DemoData {
  const DemoData({
    required this.localeCode,
    required this.rememberMe,
    required this.hasLoggedIn,
    required this.sessionActive,
    required this.leaveBalances,
    required this.leaveRequests,
    required this.overtimeRequests,
    required this.teamApprovals,
    required this.workLogs,
    required this.quickActions,
  });

  final String localeCode;
  final bool rememberMe;
  final bool hasLoggedIn;
  final bool sessionActive;
  final List<LeaveBalance> leaveBalances;
  final List<LeaveRequest> leaveRequests;
  final List<OvertimeRequest> overtimeRequests;
  final List<TeamApproval> teamApprovals;
  final List<WorkLog> workLogs;
  final List<QuickActionPreference> quickActions;

  DemoData copyWith({
    String? localeCode,
    bool? rememberMe,
    bool? hasLoggedIn,
    bool? sessionActive,
    List<LeaveBalance>? leaveBalances,
    List<LeaveRequest>? leaveRequests,
    List<OvertimeRequest>? overtimeRequests,
    List<TeamApproval>? teamApprovals,
    List<WorkLog>? workLogs,
    List<QuickActionPreference>? quickActions,
  }) => DemoData(
    localeCode: localeCode ?? this.localeCode,
    rememberMe: rememberMe ?? this.rememberMe,
    hasLoggedIn: hasLoggedIn ?? this.hasLoggedIn,
    sessionActive: sessionActive ?? this.sessionActive,
    leaveBalances: leaveBalances ?? this.leaveBalances,
    leaveRequests: leaveRequests ?? this.leaveRequests,
    overtimeRequests: overtimeRequests ?? this.overtimeRequests,
    teamApprovals: teamApprovals ?? this.teamApprovals,
    workLogs: workLogs ?? this.workLogs,
    quickActions: quickActions ?? this.quickActions,
  );
}
