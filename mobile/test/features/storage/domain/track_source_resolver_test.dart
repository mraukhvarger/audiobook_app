import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/track.dart';
import 'package:player_book/features/storage/domain/cache/audio_cache.dart';
import 'package:player_book/features/storage/domain/storage_provider_registry.dart';
import 'package:player_book/features/storage/domain/track_source_resolver.dart';

import '../support/fakes.dart';

class _FakeAudioCache implements AudioCache {
  final List<String> played = [];

  @override
  Future<Map<String, String>> cachedPaths(String bookId) async => {};

  @override
  Future<void> downloadBook(
    Book book,
    List<Track> tracks, {
    void Function(CacheProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> deleteBook(String bookId) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<int> totalSizeBytes() async => 0;

  @override
  Future<void> enforceLimit(int maxBytes) async {}

  @override
  Future<void> markPlayed(String trackId, {DateTime? at}) async {
    played.add(trackId);
  }
}

Track _track({
  String? sourceProvider = 'webdav',
  String? sourceRef = '/book/1.mp3',
  String? cachePath,
  String uri = 'https://webdav.example.ru/book/1.mp3',
}) {
  return Track(
    id: 't1',
    bookId: 'b1',
    order: 0,
    fileName: '1.mp3',
    uri: uri,
    durationMs: 1000,
    sizeBytes: 10,
    sourceProvider: sourceProvider,
    sourceRef: sourceRef,
    cachePath: cachePath,
  );
}

void main() {
  test('uses the cached file when it exists', () async {
    final provider = FakeStorageProvider();
    final cache = _FakeAudioCache();
    final resolver = StorageTrackSourceResolver(
      registry: StorageProviderRegistry([provider]),
      cache: cache,
      fileExists: (path) async => path == '/tmp/cache/1.mp3',
    );

    final resolved = await resolver.resolve(
      _track(cachePath: '/tmp/cache/1.mp3'),
    );

    expect(resolved.isRemote, isFalse);
    expect(resolved.uri.scheme, 'file');
    expect(resolved.headers, isEmpty);
  });

  test('falls back to the provider stream when not cached', () async {
    final provider = FakeStorageProvider();
    final resolver = StorageTrackSourceResolver(
      registry: StorageProviderRegistry([provider]),
      cache: _FakeAudioCache(),
      fileExists: (_) async => false,
    );

    final resolved = await resolver.resolve(
      _track(cachePath: '/tmp/missing.mp3'),
    );

    expect(resolved.isRemote, isTrue);
    expect(
      resolved.uri,
      Uri.parse('https://webdav.example.ru/book/1.mp3'),
    );
    expect(resolved.headers, provider.authHeaders);
  });

  test('resolves a relative sourceRef through the provider', () async {
    final provider = FakeStorageProvider();
    final resolver = StorageTrackSourceResolver(
      registry: StorageProviderRegistry([provider]),
      cache: _FakeAudioCache(),
      fileExists: (_) async => false,
    );

    final resolved = await resolver.resolve(
      _track(sourceRef: '/book/1.mp3'),
    );

    expect(
      resolved.uri,
      Uri.parse('https://webdav.example.ru').replace(
        pathSegments: ['book', '1.mp3'],
      ),
    );
  });

  test('treats a local track without a provider as a file', () async {
    final resolver = StorageTrackSourceResolver(
      registry: StorageProviderRegistry(const []),
      cache: _FakeAudioCache(),
      fileExists: (_) async => false,
    );

    final resolved = await resolver.resolve(
      _track(
        sourceProvider: 'local',
        sourceRef: '/books/1.mp3',
        uri: '/books/1.mp3',
      ),
    );

    expect(resolved.isRemote, isFalse);
    expect(resolved.uri.scheme, 'file');
  });

  test('markPlayed delegates to the cache', () async {
    final cache = _FakeAudioCache();
    final resolver = StorageTrackSourceResolver(
      registry: StorageProviderRegistry(const []),
      cache: cache,
    );

    await resolver.markPlayed('t1');

    expect(cache.played, ['t1']);
  });
}
