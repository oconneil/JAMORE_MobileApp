abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://localhost:5001/api/',
    defaultValue: 'https://universe.jamourthailand.com/api/',
  );

  static const apiTimeout = Duration(seconds: 20);

  static Uri get apiBaseUri {
    final normalized = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
    final uri = Uri.parse(normalized);
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('API_BASE_URL must be an absolute URL.');
    }
    return uri;
  }
}
