import 'dart:typed_data';

import '../../application/ports/customer_api_session.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Runtime connection details for the currently authenticated customer.
///
/// These values deliberately stay separate from the Universe API client:
/// Universe uses API_BASE_URL + TokenUniverse, while the customer API uses
/// Company.JamoreAPIServer/api/ + TokenJamore.
class JamoreApiConnection implements CustomerApiSession {
  Uri? _apiBaseUri;
  String? _accessToken;
  String? _companyId;

  bool get isConfigured =>
      _apiBaseUri != null && _accessToken != null && _companyId != null;

  Uri get apiBaseUri {
    final value = _apiBaseUri;
    if (value == null) {
      throw const ApiException(
        message: 'Jamore customer API is not configured.',
      );
    }
    return value;
  }

  String? get accessToken => _accessToken;

  String get companyId {
    final value = _companyId;
    if (value == null) {
      throw const ApiException(
        message: 'Jamore customer API is not configured.',
      );
    }
    return value;
  }

  @override
  void configure({
    required String apiServer,
    required String accessToken,
    required String companyId,
  }) {
    final normalizedServer = apiServer.trim();
    final normalizedToken = accessToken.trim();
    final normalizedCompanyId = companyId.trim();
    if (normalizedServer.isEmpty) {
      throw const ApiException(message: 'Jamore API server is missing.');
    }
    if (normalizedToken.isEmpty) {
      throw const ApiException(message: 'TokenJamore is missing.');
    }
    if (normalizedCompanyId.isEmpty) {
      throw const ApiException(message: 'Company ID is missing.');
    }

    final server = Uri.tryParse(
      normalizedServer.endsWith('/') ? normalizedServer : '$normalizedServer/',
    );
    if (server == null ||
        !server.hasScheme ||
        server.host.isEmpty ||
        (server.scheme != 'http' && server.scheme != 'https')) {
      throw const ApiException(message: 'Jamore API server URL is invalid.');
    }

    _apiBaseUri = server.resolve('api/');
    _accessToken = normalizedToken;
    _companyId = normalizedCompanyId;
  }

  @override
  void clear() {
    _apiBaseUri = null;
    _accessToken = null;
    _companyId = null;
  }
}

/// Use this type in customer feature repositories so it cannot be confused
/// with the Universe [ApiClient].
class JamoreApiClient extends ApiClient {
  JamoreApiClient({required this.connection, super.client, super.timeout})
    : super(
        baseUriProvider: () => connection.apiBaseUri,
        accessTokenProvider: () => connection.accessToken,
      );

  final JamoreApiConnection connection;

  @override
  Future<Object?> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => super.request(
    method,
    path,
    body: body,
    query: query,
    headers: {...?headers, 'x-companyid': connection.companyId},
  );

  @override
  Future<Uint8List> requestBytes(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => super.requestBytes(
    method,
    path,
    body: body,
    query: query,
    headers: {...?headers, 'x-companyid': connection.companyId},
  );
}
