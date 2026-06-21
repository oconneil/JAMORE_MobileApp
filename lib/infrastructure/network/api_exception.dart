class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.body,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? body;
  final Object? cause;

  @override
  String toString() => statusCode == null
      ? 'ApiException: $message'
      : 'ApiException($statusCode): $message';
}
