import '../network/api_exception.dart';

class UserDetails {
  const UserDetails({
    required this.id,
    required this.userName,
    required this.raw,
    this.email,
    this.userNameThai,
    this.userNameEng,
    this.employeeId,
    this.userGroupType,
    this.defaultLanguage,
    this.companyId,
    this.inactive = false,
  });

  final String id;
  final String userName;
  final String? email;
  final String? userNameThai;
  final String? userNameEng;
  final String? employeeId;
  final String? userGroupType;
  final String? defaultLanguage;
  final String? companyId;
  final bool inactive;
  final Map<String, Object?> raw;

  factory UserDetails.fromApiResponse(Object? response) {
    if (response is! Map) {
      throw const ApiException(message: 'Invalid user response.');
    }
    final envelope = Map<String, Object?>.from(response);
    final rawValue = _field(envelope, 'value');
    if (rawValue is! Map) {
      final message = _text(_field(envelope, 'message'));
      throw ApiException(message: message ?? 'User data is missing.');
    }

    final value = Map<String, Object?>.from(rawValue);
    final userName = _text(_field(value, 'userName'));
    if (userName == null) {
      throw const ApiException(message: 'User name is missing.');
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
      raw: value,
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

  static bool _bool(Object? value) => switch (value) {
    bool result => result,
    num result => result != 0,
    String result => result.toLowerCase() == 'true' || result == '1',
    _ => false,
  };
}
