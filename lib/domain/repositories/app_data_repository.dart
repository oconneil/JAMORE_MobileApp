import '../entities/hr_models.dart';

abstract interface class AppDataRepository {
  Future<DemoData> load();
  Future<void> save(DemoData data);
  Future<DemoData> reset({required String localeCode});
}
