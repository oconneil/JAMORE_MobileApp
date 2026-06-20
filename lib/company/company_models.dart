import '../network/api_exception.dart';

class CompanyDetails {
  const CompanyDetails({
    required this.companyId,
    required this.jamoreApiServer,
    required this.raw,
  });

  final String companyId;
  final String jamoreApiServer;
  final Map<String, Object?> raw;

  factory CompanyDetails.fromApiResponse(Object? response) {
    if (response is! Map) {
      throw const ApiException(message: 'Invalid company response.');
    }
    final envelope = Map<String, Object?>.from(response);
    final rawValue = _field(envelope, 'value');
    if (rawValue is! Map) {
      final message = _field(envelope, 'message')?.toString();
      throw ApiException(
        message: message?.isNotEmpty == true
            ? message!
            : 'Company data is missing.',
      );
    }

    final value = Map<String, Object?>.from(rawValue);
    final companyId = _field(value, 'companyID')?.toString().trim() ?? '';
    final jamoreApiServer =
        _field(value, 'jamoreAPIServer')?.toString().trim() ?? '';
    if (companyId.isEmpty) {
      throw const ApiException(message: 'Company ID is missing.');
    }
    if (jamoreApiServer.isEmpty) {
      throw const ApiException(message: 'Jamore API server is missing.');
    }

    return CompanyDetails(
      companyId: companyId,
      jamoreApiServer: jamoreApiServer,
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
}
