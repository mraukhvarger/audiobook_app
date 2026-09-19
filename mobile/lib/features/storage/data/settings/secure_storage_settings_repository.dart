import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/storage_settings_repository.dart';
import '../../domain/storage_connection.dart';

class SecureStorageSettingsRepository implements StorageSettingsRepository {
  SecureStorageSettingsRepository({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _providerKey = 'storage.providerId';
  static const String _baseUrlKey = 'storage.baseUrl';
  static const String _usernameKey = 'storage.username';
  static const String _passwordKey = 'storage.password';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<StorageConnection?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUrl = preferences.getString(_baseUrlKey);
    final username = preferences.getString(_usernameKey);
    if (rawUrl == null || username == null) return null;
    final baseUrl = Uri.tryParse(rawUrl);
    if (baseUrl == null || !baseUrl.hasScheme) return null;
    final password = await _secureStorage.read(key: _passwordKey) ?? '';
    return StorageConnection(
      providerId: preferences.getString(_providerKey) ??
          StorageConnection.webDavProviderId,
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> save(StorageConnection connection) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_providerKey, connection.providerId);
    await preferences.setString(_baseUrlKey, connection.baseUrl.toString());
    await preferences.setString(_usernameKey, connection.username);
    await _secureStorage.write(
      key: _passwordKey,
      value: connection.password,
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_providerKey);
    await preferences.remove(_baseUrlKey);
    await preferences.remove(_usernameKey);
    await _secureStorage.delete(key: _passwordKey);
  }
}
