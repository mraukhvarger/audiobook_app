import 'dart:io';

import 'package:player_book/features/library/domain/audio/audio_metadata.dart';
import 'package:player_book/features/storage/data/webdav/webdav_client_adapter.dart';
import 'package:player_book/features/storage/domain/media/media_probe.dart';
import 'package:player_book/features/storage/domain/models/remote_entry.dart';
import 'package:player_book/features/storage/domain/repositories/storage_settings_repository.dart';
import 'package:player_book/features/storage/domain/storage_connection.dart';
import 'package:player_book/features/storage/domain/storage_provider.dart';

class FakeStorageProvider implements StorageProvider {
  FakeStorageProvider({
    this.entries = const {},
    this.baseUri = 'https://webdav.example.ru',
    this.providerId = 'webdav',
    this.headers = const {'Authorization': 'Basic dGVzdDp0ZXN0'},
    this.contentSizes = const {},
    this.downloadError,
  });

  final Map<String, List<RemoteEntry>> entries;
  final String baseUri;
  final Map<String, String> headers;
  final Map<String, int> contentSizes;
  final Object? downloadError;

  @override
  final String providerId;

  @override
  bool isConnected = false;

  final List<String> listCalls = [];
  final List<String> downloadCalls = [];

  @override
  Future<void> connect() async => isConnected = true;

  @override
  Future<void> disconnect() async => isConnected = false;

  @override
  Future<List<RemoteEntry>> listEntries(String parentRef) async {
    listCalls.add(parentRef);
    return entries[parentRef] ?? const [];
  }

  @override
  Future<RemoteEntry?> getMetadata(String ref) async => null;

  @override
  Uri uriFor(String ref) {
    final segments = ref.split('/').where((s) => s.isNotEmpty).toList();
    return Uri.parse(baseUri).replace(pathSegments: segments);
  }

  @override
  Map<String, String> get authHeaders => headers;

  @override
  Stream<List<int>> openStream(String ref) async* {
    yield const [];
  }

  @override
  Future<void> download(
    String ref,
    String targetPath, {
    void Function(int received, int total)? onProgress,
  }) async {
    downloadCalls.add(ref);
    if (downloadError != null) throw downloadError!;
    final size = contentSizes[ref] ?? 16;
    final file = File(targetPath);
    await file.create(recursive: true);
    await file.writeAsBytes(List<int>.filled(size, 0));
    onProgress?.call(size, size);
  }
}

class FakeStorageSettingsRepository implements StorageSettingsRepository {
  FakeStorageSettingsRepository({this.connection});

  StorageConnection? connection;
  bool cleared = false;

  @override
  Future<StorageConnection?> load() async => connection;

  @override
  Future<void> save(StorageConnection value) async => connection = value;

  @override
  Future<void> clear() async {
    connection = null;
    cleared = true;
  }
}

class FakeMediaProbe implements MediaProbe {
  FakeMediaProbe({this.durations = const {}, this.metadata});

  final Map<String, Duration> durations;
  final AudioMetadata? metadata;

  final List<({Uri uri, Map<String, String> headers})> durationCalls = [];
  final List<({Uri uri, Map<String, String> headers})> metadataCalls = [];

  @override
  Future<Duration> probeDuration(Uri uri, Map<String, String> headers) async {
    durationCalls.add((uri: uri, headers: headers));
    return durations[uri.path] ?? Duration.zero;
  }

  @override
  Future<AudioMetadata?> readMetadata(
    Uri uri,
    Map<String, String> headers,
  ) async {
    metadataCalls.add((uri: uri, headers: headers));
    return metadata;
  }
}

class FakeWebDavClientAdapter implements WebDavClientAdapter {
  FakeWebDavClientAdapter({this.dir = const {}, this.pingError});

  final Map<String, List<RemoteEntry>> dir;
  Object? pingError;

  final List<String> dirCalls = [];
  bool closed = false;

  @override
  Future<void> ping() async {
    if (pingError != null) throw pingError!;
  }

  @override
  Future<List<RemoteEntry>> readDir(String path) async {
    dirCalls.add(path);
    return dir[path] ?? const [];
  }

  @override
  Future<RemoteEntry?> readProps(String path) async => null;

  @override
  Future<List<int>> read(String path) async => const [];

  @override
  Future<void> readToFile(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {}

  @override
  void close() => closed = true;
}
