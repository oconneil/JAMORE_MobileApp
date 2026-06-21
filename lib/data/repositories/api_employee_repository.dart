import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/employee_details.dart';
import '../../domain/repositories/employee_gateway.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../infrastructure/network/api_exception.dart';
import '../../infrastructure/network/jamore_api_client.dart';
import '../mappers/api_profile_mappers.dart';

class ApiEmployeeRepository implements EmployeeGateway {
  ApiEmployeeRepository(this._apiClient);

  final JamoreApiClient _apiClient;

  @override
  Future<EmployeeDetails> getEmployee(String employeeId) async {
    try {
      final response = await _apiClient.get(
        'Employee/Get/${Uri.encodeComponent(employeeId.trim())}',
      );
      return ApiProfileMappers.employee(response);
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }

  @override
  Future<Uint8List> getEmployeeImage(String employeeId) async {
    try {
      final responseBytes = await _apiClient.getBytes(
        'Employee/GetEmployeeImage/${Uri.encodeComponent(employeeId.trim())}',
        headers: const {'Accept': 'image/*'},
      );
      final bytes = _decodeEmployeeImage(responseBytes);
      if (bytes.isEmpty) {
        throw const RepositoryFailure('Employee image is empty.');
      }
      return bytes;
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }

  static Uint8List _decodeEmployeeImage(Uint8List responseBytes) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(responseBytes));
    } on FormatException {
      return responseBytes;
    }

    if (decoded is! Map) {
      throw const RepositoryFailure('Employee image response is invalid.');
    }
    final envelope = Map<String, Object?>.from(decoded);
    final rawValue = _field(envelope, 'value');
    if (rawValue is! String || rawValue.trim().isEmpty) {
      final message = _field(envelope, 'message')?.toString().trim();
      throw RepositoryFailure(
        message == null || message.isEmpty
            ? 'Employee image data is missing.'
            : message,
      );
    }

    var encoded = rawValue.trim();
    if (encoded.startsWith('data:')) {
      final separator = encoded.indexOf(',');
      if (separator < 0) {
        throw const RepositoryFailure('Employee image data is invalid.');
      }
      encoded = encoded.substring(separator + 1);
    }
    try {
      return base64Decode(encoded);
    } on FormatException catch (error) {
      throw RepositoryFailure('Employee image data is invalid.', cause: error);
    }
  }

  static Object? _field(Map<String, Object?> map, String name) {
    final normalized = name.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return null;
  }
}
