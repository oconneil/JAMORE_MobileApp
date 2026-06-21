import 'local_store_native.dart'
    if (dart.library.js_interop) 'local_store_web.dart'
    as implementation;

abstract interface class LocalStore {
  Future<Map<String, Object?>?> read();
  Future<void> write(Map<String, Object?> data);
  Future<void> clear();
}

LocalStore createLocalStore() => implementation.createPlatformStore();
