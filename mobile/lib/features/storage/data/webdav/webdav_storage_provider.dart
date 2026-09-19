import 'dart:convert';

import '../../domain/models/remote_entry.dart';
import '../../domain/storage_provider.dart';
import 'webdav_client_adapter.dart';
import 'webdav_config.dart';

class WebDavStorageProvider implements StorageProvider {
  WebDavStorageProvider(this.config, {WebDavClientAdapter? client})
      : _client = client ?? PackageWebDavClient.basic(config);

  static const String providerIdValue = 'webdav';

  final WebDavConfig config;
  final WebDavClientAdapter _client;

  bool _connected = false;

  @override
  String get providerId => providerIdValue;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    await _client.ping();
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _client.close();
  }

  @override
  Future<List<RemoteEntry>> listEntries(String parentRef) =>
      _client.readDir(parentRef);

  @override
  Future<RemoteEntry?> getMetadata(String ref) => _client.readProps(ref);

  @override
  Stream<List<int>> openStream(String ref) async* {
    yield await _client.read(ref);
  }

  @override
  Future<void> download(
    String ref,
    String targetPath, {
    void Function(int received, int total)? onProgress,
  }) {
    return _client.readToFile(ref, targetPath, onProgress: onProgress);
  }

  @override
  Uri uriFor(String ref) {
    final base = config.baseUrl;
    final segments = <String>[
      ...base.pathSegments.where((segment) => segment.isNotEmpty),
      ...ref.split('/').where((segment) => segment.isNotEmpty),
    ];
    return base.replace(pathSegments: segments);
  }

  @override
  Map<String, String> get authHeaders {
    final token =
        base64Encode(utf8.encode('${config.username}:${config.password}'));
    return {'Authorization': 'Basic $token'};
  }
}
