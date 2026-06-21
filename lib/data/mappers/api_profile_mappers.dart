import '../../domain/entities/company_details.dart';
import '../../domain/entities/employee_details.dart';
import '../../domain/entities/user_details.dart';
import '../../domain/repositories/repository_failure.dart';

abstract final class ApiProfileMappers {
  static CompanyDetails company(Object? response) {
    final value = _envelopeValue(response, 'Company data is missing.');
    final companyId = _text(_field(value, 'companyID'));
    final apiServer = _text(_field(value, 'jamoreAPIServer'));
    if (companyId == null) {
      throw const RepositoryFailure('Company ID is missing.');
    }
    if (apiServer == null) {
      throw const RepositoryFailure('Jamore API server is missing.');
    }
    return CompanyDetails(companyId: companyId, jamoreApiServer: apiServer);
  }

  static UserDetails user(Object? response) =>
      userFromProfile(userProfile(response));

  static Map<String, Object?> userProfile(Object? response) =>
      _envelopeValue(response, 'User data is missing.');

  static UserDetails userFromProfile(Map<String, Object?> value) {
    final userName = _text(_field(value, 'userName'));
    if (userName == null) {
      throw const RepositoryFailure('User name is missing.');
    }
    return UserDetails(
      id: _text(_field(value, 'id')) ?? '',
      userName: userName,
      email: _text(_field(value, 'email')),
      userNameThai: _text(_field(value, 'userNameThai')),
      userNameEng: _text(_field(value, 'userNameEng')),
      employeeId: _text(_field(value, 'employeeID')),
      userGroupType: _text(_field(value, 'userGroupType')),
      defaultLanguage: _text(_field(value, 'defaultLanguage')),
      companyId: _text(_field(value, 'companyID')),
      inactive: _bool(_field(value, 'inactive')),
    );
  }

  static EmployeeDetails employee(Object? response) {
    final value = _envelopeValue(response, 'Employee data is missing.');
    final rawEmployee = _field(value, 'employee');
    if (rawEmployee is! Map) {
      throw const RepositoryFailure('Employee data is missing.');
    }
    final employee = Map<String, Object?>.from(rawEmployee);
    final rawDisplay = _field(value, 'display');
    final display = rawDisplay is Map
        ? Map<String, Object?>.from(rawDisplay)
        : <String, Object?>{};
    final employeeId = _text(_field(employee, 'employeeID'));
    if (employeeId == null) {
      throw const RepositoryFailure('Employee ID is missing.');
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
      startDate: _date(_field(employee, 'startDate')),
      emailCompany: _text(_field(employee, 'emailCompany')),
      positionId: _text(_field(employee, 'positionID')),
      departmentId: _text(_field(employee, 'departmentID')),
      positionNameThai: _text(_field(display, 'positionNameThai')),
      positionNameEng: _text(_field(display, 'positionNameEng')),
      departmentNameThai: _text(_field(display, 'departmentNameThai')),
      departmentNameEng: _text(_field(display, 'departmentNameEng')),
    );
  }

  static Map<String, Object?> _envelopeValue(
    Object? response,
    String fallbackMessage,
  ) {
    if (response is! Map) throw RepositoryFailure(fallbackMessage);
    final envelope = Map<String, Object?>.from(response);
    final status = _field(envelope, 'status');
    if (status != null && !_isSuccess(status)) {
      throw RepositoryFailure(
        _text(_field(envelope, 'message')) ?? fallbackMessage,
      );
    }
    final rawValue = _field(envelope, 'value');
    if (rawValue is! Map) {
      throw RepositoryFailure(
        _text(_field(envelope, 'message')) ?? fallbackMessage,
      );
    }
    return Map<String, Object?>.from(rawValue);
  }

  static bool _isSuccess(Object status) => switch (status) {
    num value => value == 1,
    String value =>
      value.trim().toLowerCase() == 'success' || value.trim() == '1',
    _ => false,
  };

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

  static DateTime? _date(Object? value) {
    final parsed = DateTime.tryParse(value?.toString().trim() ?? '');
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static bool _bool(Object? value) => switch (value) {
    bool result => result,
    num result => result != 0,
    String result => result.toLowerCase() == 'true' || result == '1',
    _ => false,
  };
}
