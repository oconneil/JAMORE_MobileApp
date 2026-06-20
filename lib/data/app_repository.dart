import 'local_store.dart';
import 'mock_data.dart';
import 'models.dart';

class AppRepository {
  AppRepository(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final LocalStore _store;
  final DateTime Function() _clock;

  Future<DemoData> load() async {
    try {
      final json = await _store.read();
      if (json == null || json['schemaVersion'] != 1) {
        return seedDemoData(_clock());
      }
      return DemoData.fromJson(json);
    } on Object {
      return seedDemoData(_clock());
    }
  }

  Future<void> save(DemoData data) => _store.write(data.toJson());

  Future<DemoData> reset({required String localeCode}) async {
    await _store.clear();
    final data = seedDemoData(_clock(), localeCode: localeCode);
    await save(data);
    return data;
  }
}
