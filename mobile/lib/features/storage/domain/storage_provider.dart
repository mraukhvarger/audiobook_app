import 'models/remote_entry.dart';

abstract interface class StorageProvider {
  String get providerId;

  bool get isConnected;

  Future<void> connect();

  Future<void> disconnect();

  Future<List<RemoteEntry>> listEntries(String parentRef);

  Future<RemoteEntry?> getMetadata(String ref);

  Uri uriFor(String ref);

  Map<String, String> get authHeaders;

  Stream<List<int>> openStream(String ref);

  Future<void> download(
    String ref,
    String targetPath, {
    void Function(int received, int total)? onProgress,
  });
}

sealed class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class StorageAuthException extends StorageException {
  const StorageAuthException([super.message = 'Authorization failed']);
}

class StorageNetworkException extends StorageException {
  const StorageNetworkException([super.message = 'Network error']);
}

class StorageNotFoundException extends StorageException {
  const StorageNotFoundException([super.message = 'Not found']);
}
