enum RequestStatus { approved, pending, rejected, cancelled }

enum LeaveKind { annual, sick, personal, maternity }

class AttachmentMeta {
  const AttachmentMeta({
    required this.name,
    required this.mime,
    required this.bytes,
  });

  final String name;
  final String mime;
  final int bytes;

  Map<String, Object?> toJson() => {'name': name, 'mime': mime, 'bytes': bytes};

  factory AttachmentMeta.fromJson(Map<String, Object?> json) => AttachmentMeta(
    name: json['name']! as String,
    mime: json['mime']! as String,
    bytes: json['bytes']! as int,
  );
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

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'used': used,
    'total': total,
  };

  factory LeaveBalance.fromJson(Map<String, Object?> json) => LeaveBalance(
    kind: LeaveKind.values.byName(json['kind']! as String),
    used: (json['used']! as num).toDouble(),
    total: (json['total']! as num).toDouble(),
  );
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

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'days': days,
    'status': status.name,
    'reason': reason,
    'submittedAt': submittedAt.toIso8601String(),
    'attachment': attachment?.toJson(),
    'decisionReason': decisionReason,
    'decidedAt': decidedAt?.toIso8601String(),
  };

  factory LeaveRequest.fromJson(Map<String, Object?> json) => LeaveRequest(
    id: json['id']! as String,
    kind: LeaveKind.values.byName(json['kind']! as String),
    start: DateTime.parse(json['start']! as String),
    end: DateTime.parse(json['end']! as String),
    days: (json['days']! as num).toDouble(),
    status: RequestStatus.values.byName(json['status']! as String),
    reason: json['reason']! as String,
    submittedAt: DateTime.parse(json['submittedAt']! as String),
    attachment: json['attachment'] == null
        ? null
        : AttachmentMeta.fromJson(
            Map<String, Object?>.from(json['attachment']! as Map),
          ),
    decisionReason: json['decisionReason'] as String?,
    decidedAt: json['decidedAt'] == null
        ? null
        : DateTime.parse(json['decidedAt']! as String),
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

  Map<String, Object?> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'rate': rate,
    'hourlyWage': hourlyWage,
    'status': status.name,
    'reason': reason,
    'submittedAt': submittedAt.toIso8601String(),
  };

  factory OvertimeRequest.fromJson(Map<String, Object?> json) =>
      OvertimeRequest(
        id: json['id']! as String,
        date: DateTime.parse(json['date']! as String),
        startMinutes: json['startMinutes']! as int,
        endMinutes: json['endMinutes']! as int,
        rate: (json['rate']! as num).toDouble(),
        hourlyWage: (json['hourlyWage']! as num).toDouble(),
        status: RequestStatus.values.byName(json['status']! as String),
        reason: json['reason']! as String,
        submittedAt: DateTime.parse(json['submittedAt']! as String),
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

  Map<String, Object?> toJson() => {
    'id': id,
    'nameTh': nameTh,
    'nameEn': nameEn,
    'kind': kind.name,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'days': days,
    'reasonTh': reasonTh,
    'reasonEn': reasonEn,
    'status': status.name,
    'decisionReason': decisionReason,
    'decidedAt': decidedAt?.toIso8601String(),
  };

  factory TeamApproval.fromJson(Map<String, Object?> json) => TeamApproval(
    id: json['id']! as String,
    nameTh: json['nameTh']! as String,
    nameEn: json['nameEn']! as String,
    kind: LeaveKind.values.byName(json['kind']! as String),
    start: DateTime.parse(json['start']! as String),
    end: DateTime.parse(json['end']! as String),
    days: (json['days']! as num).toDouble(),
    reasonTh: json['reasonTh']! as String,
    reasonEn: json['reasonEn']! as String,
    status: RequestStatus.values.byName(json['status']! as String),
    decisionReason: json['decisionReason'] as String?,
    decidedAt: json['decidedAt'] == null
        ? null
        : DateTime.parse(json['decidedAt']! as String),
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

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'clockIn': clockIn?.toIso8601String(),
    'clockOut': clockOut?.toIso8601String(),
  };

  factory WorkLog.fromJson(Map<String, Object?> json) => WorkLog(
    date: DateTime.parse(json['date']! as String),
    clockIn: json['clockIn'] == null
        ? null
        : DateTime.parse(json['clockIn']! as String),
    clockOut: json['clockOut'] == null
        ? null
        : DateTime.parse(json['clockOut']! as String),
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
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'localeCode': localeCode,
    'rememberMe': rememberMe,
    'hasLoggedIn': hasLoggedIn,
    'sessionActive': sessionActive,
    'leaveBalances': leaveBalances.map((e) => e.toJson()).toList(),
    'leaveRequests': leaveRequests.map((e) => e.toJson()).toList(),
    'overtimeRequests': overtimeRequests.map((e) => e.toJson()).toList(),
    'teamApprovals': teamApprovals.map((e) => e.toJson()).toList(),
    'workLogs': workLogs.map((e) => e.toJson()).toList(),
  };

  factory DemoData.fromJson(Map<String, Object?> json) => DemoData(
    localeCode: json['localeCode'] as String? ?? 'th',
    rememberMe: json['rememberMe'] as bool? ?? true,
    hasLoggedIn: json['hasLoggedIn'] as bool? ?? false,
    sessionActive: json['sessionActive'] as bool? ?? false,
    leaveBalances: _list(json['leaveBalances'], LeaveBalance.fromJson),
    leaveRequests: _list(json['leaveRequests'], LeaveRequest.fromJson),
    overtimeRequests: _list(json['overtimeRequests'], OvertimeRequest.fromJson),
    teamApprovals: _list(json['teamApprovals'], TeamApproval.fromJson),
    workLogs: _list(json['workLogs'], WorkLog.fromJson),
  );

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, Object?>) fromJson,
  ) => (value! as List)
      .map((e) => fromJson(Map<String, Object?>.from(e as Map)))
      .toList();
}
