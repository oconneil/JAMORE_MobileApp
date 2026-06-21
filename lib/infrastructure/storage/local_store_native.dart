import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_store.dart';

LocalStore createPlatformStore() => NativeLocalStore();

class NativeLocalStore implements LocalStore {
  Future<File> get _file async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/jamore/demo_state.json');
  }

  @override
  Future<Map<String, Object?>?> read() async {
    final file = await _file;
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    return Map<String, Object?>.from(decoded as Map);
  }

  @override
  Future<void> write(Map<String, Object?> data) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  @override
  Future<void> clear() async {
    final file = await _file;
    if (await file.exists()) await file.delete();
  }
}
