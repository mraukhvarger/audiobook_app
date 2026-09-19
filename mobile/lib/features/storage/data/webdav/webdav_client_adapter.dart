import 'package:dio/dio.dart';
import 'package:webdav_client/webdav_client.dart' as wd;

import '../../domain/models/remote_entry.dart';
import '../../domain/storage_provider.dart';
import 'webdav_config.dart';

abstract interface class WebDavClientAdapter {
  Future<void> ping();

  Future<List<RemoteEntry>> readDir(String path);

  Future<RemoteEntry?> readProps(String path);

  Future<List<int>> read(String path);

  Future<void> readToFile(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });

  void close();
}

class PackageWebDavClient implements WebDavClientAdapter {
  PackageWebDavClient(this._client);

  factory PackageWebDavClient.basic(WebDavConfig config) {
    final client = wd.newClient(
      config.baseUrl.toString(),
      user: config.username,
      password: config.password,
    );
    client.setConnectTimeout(15000);
    client.setReceiveTimeout(120000);
    return PackageWebDavClient(client);
  }

  final wd.Client _client;

  @override
  Future<void> ping() => _run(() => _client.ping());

  @override
  Future<List<RemoteEntry>> readDir(String path) {
    return _run(() async {
      final files = await _client.readDir(path);
      return files.map(_toEntry).toList();
    });
  }

  @override
  Future<RemoteEntry?> readProps(String path) {
    return _run(() async {
      final file = await _client.readProps(path);
      return _toEntry(file);
    });
  }

  @override
  Future<List<int>> read(String path) => _run(() => _client.read(path));

  @override
  Future<void> readToFile(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) {
    return _run(
      () => _client.read2File(path, savePath, onProgress: onProgress),
    );
  }

  @override
  void close() {}

  RemoteEntry _toEntry(wd.File file) {
    final path = file.path ?? '';
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    final fallbackName = segments.isEmpty ? path : segments.last;
    return RemoteEntry(
      ref: path,
      name: file.name ?? fallbackName,
      isFolder: file.isDir ?? false,
      sizeBytes: file.size ?? 0,
      modifiedAt: file.mTime,
      mimeType: file.mimeType,
    );
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw _translate(error);
    }
  }

  StorageException _translate(Object error) {
    if (error is StorageException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return const StorageAuthException();
      }
      if (status == 404) {
        return const StorageNotFoundException();
      }
      return StorageNetworkException(error.message ?? 'WebDAV request failed');
    }
    if (error is FormatException) {
      return const StorageNetworkException('Malformed WebDAV response');
    }
    return StorageNetworkException(error.toString());
  }
}
