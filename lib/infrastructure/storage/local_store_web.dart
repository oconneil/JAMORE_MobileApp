import 'dart:convert';

import 'package:web/web.dart' as web;

import 'local_store.dart';

LocalStore createPlatformStore() => WebLocalStore();

class WebLocalStore implements LocalStore {
  static const _key = 'jamore.demo.state.v1';

  @override
  Future<Map<String, Object?>?> read() async {
    final raw = web.window.localStorage.getItem(_key);
    if (raw == null) return null;
    return Map<String, Object?>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<void> write(Map<String, Object?> data) async {
    web.window.localStorage.setItem(_key, jsonEncode(data));
  }

  @override
  Future<void> clear() async => web.window.localStorage.removeItem(_key);
}
