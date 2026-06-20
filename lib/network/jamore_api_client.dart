import 'api_client.dart';
import 'api_exception.dart';

/// Runtime connection details for the currently authenticated customer.
///
/// These values deliberately stay separate from the Universe API client:
/// Universe uses API_BASE_URL + TokenUniverse, while the customer API uses
/// Company.JamoreAPIServer/api/ + TokenJamore.
class JamoreApiConnection {
  Uri? _apiBaseUri;
  String? _accessToken;

  bool get isConfigured => _apiBaseUri != null && _accessToken != null;

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

  void configure({required String apiServer, required String accessToken}) {
    final normalizedServer = apiServer.trim();
    final normalizedToken = accessToken.trim();
    if (normalizedServer.isEmpty) {
      throw const ApiException(message: 'Jamore API server is missing.');
    }
    if (normalizedToken.isEmpty) {
      throw const ApiException(message: 'TokenJamore is missing.');
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
  }

  void clear() {
    _apiBaseUri = null;
    _accessToken = null;
  }
}

/// Use this type in customer feature repositories so it cannot be confused
/// with the Universe [ApiClient].
class JamoreApiClient extends ApiClient {
  JamoreApiClient({
    required JamoreApiConnection connection,
    super.client,
    super.timeout,
  }) : super(
         baseUriProvider: () => connection.apiBaseUri,
         accessTokenProvider: () => connection.accessToken,
       );
}
