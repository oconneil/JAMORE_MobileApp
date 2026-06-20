import '../network/api_exception.dart';

class EmployeeDetails {
  const EmployeeDetails({
    required this.employeeId,
    required this.raw,
    required this.displayRaw,
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
  final Map<String, Object?> raw;
  final Map<String, Object?> displayRaw;

  String? displayName({required bool isThai}) {
    final preferred = isThai ? fullNameThai : fullNameEng;
    final fallback = isThai ? fullNameEng : fullNameThai;
    return _normalizeName(preferred ?? fallback);
  }

  String? displayPositionName({required bool isThai}) {
    if (positionId == null) return null;
    final preferred = isThai ? positionNameThai : positionNameEng;
    final fallback = isThai ? positionNameEng : positionNameThai;
    return _text(preferred ?? fallback);
  }

  factory EmployeeDetails.fromApiResponse(Object? response) {
    if (response is! Map) {
      throw const ApiException(message: 'Invalid employee response.');
    }
    final envelope = Map<String, Object?>.from(response);
    final rawValue = _field(envelope, 'value');
    if (rawValue is! Map) {
      final message = _text(_field(envelope, 'message'));
      throw ApiException(message: message ?? 'Employee data is missing.');
    }

    final value = Map<String, Object?>.from(rawValue);
    final rawEmployee = _field(value, 'employee');
    if (rawEmployee is! Map) {
      throw const ApiException(message: 'Employee data is missing.');
    }
    final employee = Map<String, Object?>.from(rawEmployee);
    final rawDisplay = _field(value, 'display');
    final display = rawDisplay is Map
        ? Map<String, Object?>.from(rawDisplay)
        : <String, Object?>{};
    final employeeId = _text(_field(employee, 'employeeID'));
    if (employeeId == null) {
      throw const ApiException(message: 'Employee ID is missing.');
    }

    return EmployeeDetails(
      employeeId: employeeId,
      fullNameThai: _text(_field(employee, 'fullNameThai')),
      fullNameEng: _text(_field(employee, 'fullNameEng')),
      employeeNameThai: _text(_field(employee, 'employeeNameThai')),
      employeeNameEng: _text(_field(employee, 'employeeNameEng')),
      employeeLastnameThai: _text(_field(employee, 'employeeLastnameThai')),
      employeeLastnameEng: _text(_field(employee, 'employeeLastnameEng')),
      imageFile: _text(_field(employee, 'imgFile')),
      emailCompany: _text(_field(employee, 'emailCompany')),
      positionId: _text(_field(employee, 'positionID')),
      departmentId: _text(_field(employee, 'departmentID')),
      positionNameThai: _text(_field(display, 'positionNameThai')),
      positionNameEng: _text(_field(display, 'positionNameEng')),
      raw: employee,
      displayRaw: display,
    );
  }

  static Object? _field(Map<String, Object?> map, String name) {
    final normalized = name.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return null;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _normalizeName(String? value) {
    final normalized = value?.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
