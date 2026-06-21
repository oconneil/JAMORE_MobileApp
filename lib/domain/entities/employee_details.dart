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
    this.emailCompany,
    this.positionId,
    this.departmentId,
    this.positionNameThai,
    this.positionNameEng,
  });

  final String employeeId;
  final String? fullNameThai;
  final String? fullNameEng;
  final String? employeeNameThai;
  final String? employeeNameEng;
  final String? employeeLastnameThai;
  final String? employeeLastnameEng;
  final String? imageFile;
  final String? emailCompany;
  final String? positionId;
  final String? departmentId;
  final String? positionNameThai;
  final String? positionNameEng;

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
}
