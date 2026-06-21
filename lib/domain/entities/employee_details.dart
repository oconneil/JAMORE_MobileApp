class EmployeeDetails {
  const EmployeeDetails({
    required this.employeeId,
    this.fullNameThai,
    this.fullNameEng,
    this.employeeNameThai,
    this.employeeNameEng,
    this.employeeLastnameThai,
    this.employeeLastnameEng,
    this.imageFile,
    this.startDate,
    this.emailCompany,
    this.positionId,
    this.departmentId,
    this.positionNameThai,
    this.positionNameEng,
    this.departmentNameThai,
    this.departmentNameEng,
  });

  final String employeeId;
  final String? fullNameThai;
  final String? fullNameEng;
  final String? employeeNameThai;
  final String? employeeNameEng;
  final String? employeeLastnameThai;
  final String? employeeLastnameEng;
  final String? imageFile;
  final DateTime? startDate;
  final String? emailCompany;
  final String? positionId;
  final String? departmentId;
  final String? positionNameThai;
  final String? positionNameEng;
  final String? departmentNameThai;
  final String? departmentNameEng;

  String? displayName({required bool isThai}) {
    final preferred = isThai ? fullNameThai : fullNameEng;
    final fallback = isThai ? fullNameEng : fullNameThai;
    final normalized = (preferred ?? fallback)
        ?.replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? displayPositionName({required bool isThai}) {
    if (positionId == null) return null;
    final preferred = isThai ? positionNameThai : positionNameEng;
    final fallback = isThai ? positionNameEng : positionNameThai;
    final value = (preferred ?? fallback)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? displayDepartmentName({required bool isThai}) {
    final preferred = isThai ? departmentNameThai : departmentNameEng;
    final fallback = isThai ? departmentNameEng : departmentNameThai;
    final value = (preferred ?? fallback)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  EmploymentTenure? tenureAsOf(DateTime value) {
    final start = startDate;
    if (start == null) return null;
    final firstDay = DateTime(start.year, start.month, start.day);
    final lastDay = DateTime(value.year, value.month, value.day);
    if (lastDay.isBefore(firstDay)) return null;

    var years = lastDay.year - firstDay.year;
    var cursor = _addYears(firstDay, years);
    if (cursor.isAfter(lastDay)) {
      years--;
      cursor = _addYears(firstDay, years);
    }

    var months =
        (lastDay.year - cursor.year) * 12 + lastDay.month - cursor.month;
    var monthCursor = _addMonths(cursor, months);
    if (monthCursor.isAfter(lastDay)) {
      months--;
      monthCursor = _addMonths(cursor, months);
    }

    return EmploymentTenure(
      years: years,
      months: months,
      days: lastDay.difference(monthCursor).inDays,
    );
  }

  static DateTime _addYears(DateTime value, int years) {
    final year = value.year + years;
    final day = value.day.clamp(1, _daysInMonth(year, value.month));
    return DateTime(year, value.month, day);
  }

  static DateTime _addMonths(DateTime value, int months) {
    final monthIndex = value.year * 12 + value.month - 1 + months;
    final year = monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final day = value.day.clamp(1, _daysInMonth(year, month));
    return DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}

class EmploymentTenure {
  const EmploymentTenure({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;
}
