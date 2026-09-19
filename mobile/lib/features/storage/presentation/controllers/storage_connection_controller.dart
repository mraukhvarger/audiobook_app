import 'package:flutter/foundation.dart';

import '../../domain/repositories/storage_settings_repository.dart';
import '../../domain/storage_connection.dart';
import '../../domain/storage_provider.dart';

typedef StorageProviderFactory = StorageProvider Function(
  StorageConnection connection,
);

class StorageConnectionController extends ChangeNotifier {
  StorageConnectionController({
    required StorageSettingsRepository repository,
    required StorageProviderFactory providerFactory,
  })  : _repository = repository,
        _providerFactory = providerFactory;

  final StorageSettingsRepository _repository;
  final StorageProviderFactory _providerFactory;

  StorageConnection? _connection;
  bool _connecting = false;
  String? _error;

  StorageConnection? get connection => _connection;

  bool get connecting => _connecting;

  String? get error => _error;

  bool get isConnected => _connection != null;

  Future<void> load() async {
    _connection = await _repository.load();
    notifyListeners();
  }

  Future<bool> connect({
    required Uri baseUrl,
    required String username,
    required String password,
  }) async {
    _connecting = true;
    _error = null;
    notifyListeners();
    final connection = StorageConnection(
      providerId: StorageConnection.webDavProviderId,
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    final provider = _providerFactory(connection);
    try {
      await provider.connect();
      await _repository.save(connection);
      _connection = connection;
      return true;
    } on StorageException catch (error) {
      _error = error.message;
      return false;
    } catch (error) {
      _error = '$error';
      return false;
    } finally {
      provider.disconnect();
      _connecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;
    if (connection != null) {
      await _providerFactory(connection).disconnect();
    }
    await _repository.clear();
    _connection = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
