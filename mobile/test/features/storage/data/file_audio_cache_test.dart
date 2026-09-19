import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/core/database/app_database.dart';
import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/book_summary.dart';
import 'package:player_book/features/library/domain/models/imported_book.dart';
import 'package:player_book/features/library/domain/models/track.dart';
import 'package:player_book/features/library/domain/repositories/library_repository.dart';
import 'package:player_book/features/storage/data/cache/cache_dao.dart';
import 'package:player_book/features/storage/data/cache/file_audio_cache.dart';
import 'package:player_book/features/storage/domain/storage_provider_registry.dart';

import '../support/fakes.dart';

class _FakeLibraryRepository implements LibraryRepository {
  _FakeLibraryRepository(this.tracks);

  List<Track> tracks;
  final List<String> cachePathWrites = [];

  @override
  Future<void> setTrackCachePath(String trackId, String? cachePath) async {
    cachePathWrites.add('$trackId:${cachePath ?? ''}');
    tracks = [
      for (final track in tracks)
        track.id == trackId ? track.copyWith(cachePath: cachePath) : track,
    ];
  }

  @override
  Future<void> clearCachePaths(String bookId) async {
    tracks = [
      for (final track in tracks)
        track.bookId == bookId ? track.copyWith(clearCachePath: true) : track,
    ];
  }

  @override
  Future<Book?> getBook(String id) async => null;

  @override
  Future<List<Book>> getBooks() async => const [];

  @override
  Future<List<BookSummary>> getBookSummaries() async => const [];

  @override
  Future<List<Track>> getTracks(String bookId) async => tracks;

  @override
  Future<void> saveImportedBook(ImportedBook imported) async {}

  @override
  Future<void> deleteBook(String id) async {}
}

void main() {
  late AppDatabase database;
  late Directory root;
  late _FakeLibraryRepository library;

  final book = Book(
    id: 'book-1',
    title: 'Книга',
    sourceProvider: 'webdav',
    sourceRef: '/book',
    createdAt: DateTime.utc(2026),
  );

  List<Track> tracks() => [
        const Track(
          id: 't1',
          bookId: 'book-1',
          order: 0,
          fileName: '1.mp3',
          uri: 'https://webdav.example.ru/book/1.mp3',
          durationMs: 1000,
          sizeBytes: 10,
          sourceProvider: 'webdav',
          sourceRef: '/book/1.mp3',
        ),
        const Track(
          id: 't2',
          bookId: 'book-1',
          order: 1,
          fileName: '2.mp3',
          uri: 'https://webdav.example.ru/book/2.mp3',
          durationMs: 1000,
          sizeBytes: 20,
          sourceProvider: 'webdav',
          sourceRef: '/book/2.mp3',
        ),
      ];

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    root = Directory.systemTemp.createTempSync('audio_cache_test');
    library = _FakeLibraryRepository(tracks());
  });

  tearDown(() async {
    await database.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  FileAudioCache buildCache({
    FakeStorageProvider? provider,
    int limitBytes = FileAudioCache.defaultLimitBytes,
  }) {
    return FileAudioCache(
      registry: StorageProviderRegistry([
        provider ?? FakeStorageProvider(),
      ]),
      dao: CacheDao(database),
      libraryRepository: library,
      rootDirectory: () async => root,
      limitBytes: limitBytes,
      now: () => DateTime.utc(2026, 1, 1),
    );
  }

  test('downloads remote tracks and records the cached paths', () async {
    final provider = FakeStorageProvider(
      contentSizes: {'/book/1.mp3': 100, '/book/2.mp3': 200},
    );
    final cache = buildCache(provider: provider);
    final progress = <double>[];

    await cache.downloadBook(
      book,
      library.tracks,
      onProgress: (value) => progress.add(value.fraction),
    );

    expect(provider.downloadCalls, ['/book/1.mp3', '/book/2.mp3']);
    final expectedPaths = await cache.cachedPaths('book-1');
    expect(expectedPaths.keys, containsAll(['t1', 't2']));
    for (final path in expectedPaths.values) {
      expect(File(path).existsSync(), isTrue);
    }
    expect(await cache.totalSizeBytes(), 300);
    expect(library.tracks.every((track) => track.cachePath != null), isTrue);
    expect(progress.last, closeTo(1, 1e-9));
  });

  test('evicts least recently used entries over the limit', () async {
    final provider = FakeStorageProvider(
      contentSizes: {'/book/1.mp3': 100, '/book/2.mp3': 200},
    );
    final cache = buildCache(provider: provider, limitBytes: 1000);
    await cache.downloadBook(book, library.tracks);

    await cache.markPlayed('t1', at: DateTime.utc(2027));
    await cache.enforceLimit(150);

    final remaining = await cache.cachedPaths('book-1');

    expect(remaining.keys, ['t1']);
    expect(File(remaining['t1']!).existsSync(), isTrue);
  });

  test('clearing a book removes files, entries and cache paths', () async {
    final provider = FakeStorageProvider();
    final cache = buildCache(provider: provider);
    await cache.downloadBook(book, library.tracks);
    final paths = await cache.cachedPaths('book-1');

    await cache.deleteBook('book-1');

    expect(await cache.cachedPaths('book-1'), isEmpty);
    for (final path in paths.values) {
      expect(File(path).existsSync(), isFalse);
    }
    expect(library.tracks.every((track) => track.cachePath == null), isTrue);
  });
}
