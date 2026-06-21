import '../../domain/entities/hr_models.dart';
import '../../domain/repositories/app_data_repository.dart';
import '../../infrastructure/storage/local_store.dart';
import '../mappers/demo_data_mapper.dart';
import '../seed/demo_seed.dart';

class LocalAppDataRepository implements AppDataRepository {
  LocalAppDataRepository(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final LocalStore _store;
  final DateTime Function() _clock;

  @override
  Future<DemoData> load() async {
    try {
      final json = await _store.read();
      if (json == null ||
          json['schemaVersion'] != DemoDataMapper.schemaVersion) {
        return seedDemoData(_clock());
      }
      return DemoDataMapper.fromJson(json);
    } on Object {
      return seedDemoData(_clock());
    }
  }

  @override
  Future<void> save(DemoData data) => _store.write(DemoDataMapper.toJson(data));

  @override
  Future<DemoData> reset({required String localeCode}) async {
    await _store.clear();
    final data = seedDemoData(_clock(), localeCode: localeCode);
    await save(data);
    return data;
  }
}
