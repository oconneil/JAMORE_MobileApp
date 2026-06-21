import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import 'api_exception.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();
typedef BaseUriProvider = Uri Function();

class ApiClient {
  ApiClient({
    http.Client? client,
    Uri? baseUri,
    BaseUriProvider? baseUriProvider,
    Duration? timeout,
    this.accessTokenProvider,
  }) : _client = client ?? http.Client(),
       assert(
         baseUri == null || baseUriProvider == null,
         'Provide either baseUri or baseUriProvider, not both.',
       ),
       _baseUri =
           baseUri ?? (baseUriProvider == null ? AppConfig.apiBaseUri : null),
       _baseUriProvider = baseUriProvider,
       _timeout = timeout ?? AppConfig.apiTimeout;

  final http.Client _client;
  final Uri? _baseUri;
  final BaseUriProvider? _baseUriProvider;
  final Duration _timeout;
  final AccessTokenProvider? accessTokenProvider;

  Future<Object?> get(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => request('GET', path, query: query, headers: headers);

  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => request('POST', path, body: body, query: query, headers: headers);

  Future<Object?> put(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => request('PUT', path, body: body, query: query, headers: headers);

  Future<Object?> patch(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => request('PATCH', path, body: body, query: query, headers: headers);

  Future<Object?> delete(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => request('DELETE', path, body: body, query: query, headers: headers);

  Future<Uint8List> getBytes(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => requestBytes('GET', path, query: query, headers: headers);

  Future<Object?> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _resolve(path, query);
    final requestHeaders = await _headers(headers);
    final request = http.Request(method, uri)..headers.addAll(requestHeaders);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: _errorMessage(decoded, response.reasonPhrase),
          statusCode: response.statusCode,
          body: decoded,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(message: 'API request timed out.', cause: error);
    } on Object catch (error) {
      throw ApiException(
        message: 'Unable to connect to the API.',
        cause: error,
      );
    }
  }

  Future<Uint8List> requestBytes(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _resolve(path, query);
    final requestHeaders = await _headers(headers);
    final request = http.Request(method, uri)..headers.addAll(requestHeaders);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = _decode(
          utf8.decode(response.bodyBytes, allowMalformed: true),
        );
        throw ApiException(
          message: _errorMessage(decoded, response.reasonPhrase),
          statusCode: response.statusCode,
          body: decoded,
        );
      }
      return response.bodyBytes;
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(message: 'API request timed out.', cause: error);
    } on Object catch (error) {
      throw ApiException(
        message: 'Unable to connect to the API.',
        cause: error,
      );
    }
  }

  Uri _resolve(String path, Map<String, Object?>? query) {
    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    final baseUri = _baseUriProvider?.call() ?? _baseUri!;
    final uri = baseUri.resolve(relativePath);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        for (final entry in query.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      },
    );
  }

  Future<Map<String, String>> _headers(Map<String, String>? extra) async {
    final token = await accessTokenProvider?.call();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  static Object? _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  static String _errorMessage(Object? body, String? fallback) {
    if (body is Map) {
      for (final key in const ['message', 'detail', 'title', 'error']) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return fallback?.isNotEmpty == true ? fallback! : 'API request failed.';
  }

  void close() => _client.close();
}
