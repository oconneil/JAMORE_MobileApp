import '../../domain/entities/hr_models.dart';

abstract final class DemoDataMapper {
  static const schemaVersion = 1;

  static Map<String, Object?> toJson(DemoData data) => {
    'schemaVersion': schemaVersion,
    'localeCode': data.localeCode,
    'rememberMe': data.rememberMe,
    'hasLoggedIn': data.hasLoggedIn,
    'sessionActive': data.sessionActive,
    'leaveBalances': data.leaveBalances.map(_leaveBalanceToJson).toList(),
    'leaveRequests': data.leaveRequests.map(_leaveRequestToJson).toList(),
    'overtimeRequests': data.overtimeRequests.map(_overtimeToJson).toList(),
    'teamApprovals': data.teamApprovals.map(_approvalToJson).toList(),
    'workLogs': data.workLogs.map(_workLogToJson).toList(),
  };

  static DemoData fromJson(Map<String, Object?> json) => DemoData(
    localeCode: json['localeCode'] as String? ?? 'th',
    rememberMe: json['rememberMe'] as bool? ?? true,
    hasLoggedIn: json['hasLoggedIn'] as bool? ?? false,
    sessionActive: json['sessionActive'] as bool? ?? false,
    leaveBalances: _list(json['leaveBalances'], _leaveBalanceFromJson),
    leaveRequests: _list(json['leaveRequests'], _leaveRequestFromJson),
    overtimeRequests: _list(json['overtimeRequests'], _overtimeFromJson),
    teamApprovals: _list(json['teamApprovals'], _approvalFromJson),
    workLogs: _list(json['workLogs'], _workLogFromJson),
  );

  static Map<String, Object?> _attachmentToJson(AttachmentMeta value) => {
    'name': value.name,
    'mime': value.mime,
    'bytes': value.bytes,
  };

  static AttachmentMeta _attachmentFromJson(Map<String, Object?> json) =>
      AttachmentMeta(
        name: json['name']! as String,
        mime: json['mime']! as String,
        bytes: json['bytes']! as int,
      );

  static Map<String, Object?> _leaveBalanceToJson(LeaveBalance value) => {
    'kind': value.kind.name,
    'used': value.used,
    'total': value.total,
  };

  static LeaveBalance _leaveBalanceFromJson(Map<String, Object?> json) =>
      LeaveBalance(
        kind: LeaveKind.values.byName(json['kind']! as String),
        used: (json['used']! as num).toDouble(),
        total: (json['total']! as num).toDouble(),
      );

  static Map<String, Object?> _leaveRequestToJson(LeaveRequest value) => {
    'id': value.id,
    'kind': value.kind.name,
    'start': value.start.toIso8601String(),
    'end': value.end.toIso8601String(),
    'days': value.days,
    'status': value.status.name,
    'reason': value.reason,
    'submittedAt': value.submittedAt.toIso8601String(),
    'attachment': value.attachment == null
        ? null
        : _attachmentToJson(value.attachment!),
    'decisionReason': value.decisionReason,
    'decidedAt': value.decidedAt?.toIso8601String(),
  };

  static LeaveRequest _leaveRequestFromJson(Map<String, Object?> json) =>
      LeaveRequest(
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
            : _attachmentFromJson(_map(json['attachment'])),
        decisionReason: json['decisionReason'] as String?,
        decidedAt: json['decidedAt'] == null
            ? null
            : DateTime.parse(json['decidedAt']! as String),
      );

  static Map<String, Object?> _overtimeToJson(OvertimeRequest value) => {
    'id': value.id,
    'date': value.date.toIso8601String(),
    'startMinutes': value.startMinutes,
    'endMinutes': value.endMinutes,
    'rate': value.rate,
    'hourlyWage': value.hourlyWage,
    'status': value.status.name,
    'reason': value.reason,
    'submittedAt': value.submittedAt.toIso8601String(),
  };

  static OvertimeRequest _overtimeFromJson(Map<String, Object?> json) =>
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

  static Map<String, Object?> _approvalToJson(TeamApproval value) => {
    'id': value.id,
    'nameTh': value.nameTh,
    'nameEn': value.nameEn,
    'kind': value.kind.name,
    'start': value.start.toIso8601String(),
    'end': value.end.toIso8601String(),
    'days': value.days,
    'reasonTh': value.reasonTh,
    'reasonEn': value.reasonEn,
    'status': value.status.name,
    'decisionReason': value.decisionReason,
    'decidedAt': value.decidedAt?.toIso8601String(),
  };

  static TeamApproval _approvalFromJson(Map<String, Object?> json) =>
      TeamApproval(
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

  static Map<String, Object?> _workLogToJson(WorkLog value) => {
    'date': value.date.toIso8601String(),
    'clockIn': value.clockIn?.toIso8601String(),
    'clockOut': value.clockOut?.toIso8601String(),
  };

  static WorkLog _workLogFromJson(Map<String, Object?> json) => WorkLog(
    date: DateTime.parse(json['date']! as String),
    clockIn: json['clockIn'] == null
        ? null
        : DateTime.parse(json['clockIn']! as String),
    clockOut: json['clockOut'] == null
        ? null
        : DateTime.parse(json['clockOut']! as String),
  );

  static Map<String, Object?> _map(Object? value) =>
      Map<String, Object?>.from(value! as Map);

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, Object?>) fromJson,
  ) => (value! as List).map((item) => fromJson(_map(item))).toList();
}
