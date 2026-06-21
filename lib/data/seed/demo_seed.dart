import '../../domain/entities/hr_models.dart';

DateTime day(DateTime value, [int offset = 0]) =>
    DateTime(value.year, value.month, value.day).add(Duration(days: offset));

DemoData seedDemoData(DateTime now, {String localeCode = 'th'}) {
  final today = day(now);
  DateTime at(int offset, int hour, [int minute = 0]) =>
      day(today, offset).add(Duration(hours: hour, minutes: minute));

  return DemoData(
    localeCode: localeCode,
    rememberMe: true,
    hasLoggedIn: false,
    sessionActive: false,
    leaveBalances: const [
      LeaveBalance(kind: LeaveKind.annual, used: 4, total: 12),
      LeaveBalance(kind: LeaveKind.sick, used: 2, total: 30),
      LeaveBalance(kind: LeaveKind.personal, used: 1, total: 6),
      LeaveBalance(kind: LeaveKind.maternity, used: 0, total: 90),
    ],
    leaveRequests: [
      LeaveRequest(
        id: 'L-0042',
        kind: LeaveKind.annual,
        start: day(today, -38),
        end: day(today, -36),
        days: 3,
        status: RequestStatus.approved,
        reason: 'Family trip / ทริปครอบครัว',
        submittedAt: at(-43, 14, 20),
        decidedAt: at(-42, 9, 12),
      ),
      LeaveRequest(
        id: 'L-0041',
        kind: LeaveKind.sick,
        start: day(today, -22),
        end: day(today, -22),
        days: 1,
        status: RequestStatus.approved,
        reason: 'Migraine / ปวดหัวไมเกรน',
        submittedAt: at(-22, 7, 30),
        decidedAt: at(-22, 8, 15),
      ),
      LeaveRequest(
        id: 'L-0040',
        kind: LeaveKind.personal,
        start: day(today, 5),
        end: day(today, 5),
        days: 1,
        status: RequestStatus.pending,
        reason: 'Government errand / ติดต่อราชการ',
        submittedAt: at(-1, 11),
      ),
      LeaveRequest(
        id: 'L-0039',
        kind: LeaveKind.annual,
        start: day(today, -48),
        end: day(today, -47),
        days: 2,
        status: RequestStatus.rejected,
        reason: 'Personal trip / ธุระส่วนตัว',
        submittedAt: at(-55, 10),
        decisionReason: 'Release week / สัปดาห์ปล่อยระบบ',
        decidedAt: at(-54, 16),
      ),
    ],
    overtimeRequests: [
      OvertimeRequest(
        id: 'OT-0091',
        date: day(today, -4),
        startMinutes: 1110,
        endMinutes: 1290,
        rate: 1.5,
        hourlyWage: 250,
        status: RequestStatus.approved,
        reason: 'Release bug fixes',
        submittedAt: at(-5, 16),
      ),
      OvertimeRequest(
        id: 'OT-0090',
        date: day(today, -7),
        startMinutes: 1110,
        endMinutes: 1230,
        rate: 1.5,
        hourlyWage: 250,
        status: RequestStatus.approved,
        reason: 'Design review',
        submittedAt: at(-8, 15),
      ),
      OvertimeRequest(
        id: 'OT-0089',
        date: day(today, 2),
        startMinutes: 540,
        endMinutes: 780,
        rate: 3,
        hourlyWage: 250,
        status: RequestStatus.pending,
        reason: 'Public holiday support',
        submittedAt: at(-1, 13),
      ),
    ],
    teamApprovals: [
      TeamApproval(
        id: 'L-2201',
        nameTh: 'พิมพ์ลภัส มณีรัตน์',
        nameEn: 'Pimlapas Maneerat',
        kind: LeaveKind.annual,
        start: day(today, 7),
        end: day(today, 9),
        days: 3,
        reasonTh: 'พาแม่ไปหาหมอที่เชียงใหม่',
        reasonEn: 'Taking my mother to a doctor in Chiang Mai',
        status: RequestStatus.pending,
      ),
      TeamApproval(
        id: 'L-2200',
        nameTh: 'ธนกร อินทรชัย',
        nameEn: 'Thanakorn Intarachai',
        kind: LeaveKind.sick,
        start: day(today, 2),
        end: day(today, 2),
        days: 1,
        reasonTh: 'เป็นไข้ ปวดหัว',
        reasonEn: 'Fever and headache',
        status: RequestStatus.pending,
      ),
    ],
    workLogs: [
      WorkLog(
        date: day(today, -1),
        clockIn: at(-1, 8, 38),
        clockOut: at(-1, 18, 12),
      ),
      WorkLog(
        date: day(today, -2),
        clockIn: at(-2, 9, 5),
        clockOut: at(-2, 18, 1),
      ),
      WorkLog(
        date: day(today, -3),
        clockIn: at(-3, 8, 33),
        clockOut: at(-3, 21, 18),
      ),
      WorkLog(
        date: day(today, -4),
        clockIn: at(-4, 8, 51),
        clockOut: at(-4, 17, 55),
      ),
    ],
  );
}
