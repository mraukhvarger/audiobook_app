import '../storage_connection.dart';

abstract interface class StorageSettingsRepository {
  Future<StorageConnection?> load();

  Future<void> save(StorageConnection connection);

  Future<void> clear();
}
