import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../core/database/app_database.dart';
import '../../../library/domain/models/book.dart';
import '../../../library/domain/models/track.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../domain/cache/audio_cache.dart';
import '../../domain/storage_provider.dart';
import '../../domain/storage_provider_registry.dart';
import 'cache_dao.dart';

class FileAudioCache implements AudioCache {
  FileAudioCache({
    required StorageProviderRegistry registry,
    required CacheDao dao,
    required LibraryRepository libraryRepository,
    required Future<Directory> Function() rootDirectory,
    DateTime Function()? now,
    int limitBytes = defaultLimitBytes,
  })  : _registry = registry,
        _dao = dao,
        _library = libraryRepository,
        _rootDirectory = rootDirectory,
        _now = now ?? DateTime.now,
        _limitBytes = limitBytes;

  static const int defaultLimitBytes = 2 * 1024 * 1024 * 1024;

  final StorageProviderRegistry _registry;
  final CacheDao _dao;
  final LibraryRepository _library;
  final Future<Directory> Function() _rootDirectory;
  final DateTime Function() _now;
  final int _limitBytes;

  @override
  Future<Map<String, String>> cachedPaths(String bookId) async {
    final entries = await _dao.entriesForBook(bookId);
    return {for (final entry in entries) entry.trackId: entry.path};
  }

  @override
  Future<void> downloadBook(
    Book book,
    List<Track> tracks, {
    void Function(CacheProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      CacheProgress(totalTracks: tracks.length),
    );
    final root = await _rootDirectory();
    final bookDir = Directory(p.join(root.path, book.id));
    await bookDir.create(recursive: true);

    var completed = 0;
    for (final track in tracks) {
      final provider = _providerFor(track);
      if (provider == null) {
        completed++;
        continue;
      }
      if (await _alreadyCached(track)) {
        completed++;
        onProgress?.call(
          CacheProgress(
            completedTracks: completed,
            totalTracks: tracks.length,
          ),
        );
        continue;
      }
      final target = File(
        p.join(bookDir.path,
            '${_safeName(track.id)}_${_safeName(track.fileName)}'),
      );
      try {
        await provider.download(
          track.sourceRef ?? track.uri,
          target.path,
          onProgress: (received, total) {
            onProgress?.call(
              CacheProgress(
                completedTracks: completed,
                totalTracks: tracks.length,
                trackReceivedBytes: received,
                trackTotalBytes: total,
              ),
            );
          },
        );
      } catch (_) {
        if (await target.exists()) await target.delete();
        rethrow;
      }
      final size = await target.length();
      final now = _now();
      await _dao.upsert(
        CacheEntriesCompanion.insert(
          trackId: track.id,
          bookId: book.id,
          path: target.path,
          sizeBytes: size,
          lastPlayedAt: now,
        ),
      );
      await _library.setTrackCachePath(track.id, target.path);
      completed++;
      onProgress?.call(
        CacheProgress(
          completedTracks: completed,
          totalTracks: tracks.length,
        ),
      );
    }
    await enforceLimit(_limitBytes);
  }

  @override
  Future<void> deleteBook(String bookId) async {
    final entries = await _dao.entriesForBook(bookId);
    for (final entry in entries) {
      await _deleteFile(entry.path);
    }
    await _dao.deleteForBook(bookId);
    await _library.clearCachePaths(bookId);
    final root = await _rootDirectory();
    final bookDir = Directory(p.join(root.path, bookId));
    if (await bookDir.exists()) await bookDir.delete(recursive: true);
  }

  @override
  Future<void> deleteAll() async {
    final entries = await _dao.allEntries();
    for (final entry in entries) {
      await _deleteFile(entry.path);
    }
    await _dao.deleteAll();
    final root = await _rootDirectory();
    if (await root.exists()) await root.delete(recursive: true);
    await root.create(recursive: true);
  }

  @override
  Future<int> totalSizeBytes() => _dao.totalSize();

  @override
  Future<void> enforceLimit(int maxBytes) async {
    var total = await _dao.totalSize();
    if (total <= maxBytes) return;
    final entries = await _dao.orderedByLeastRecentlyUsed();
    for (final entry in entries) {
      if (total <= maxBytes) break;
      await _deleteFile(entry.path);
      await _dao.deleteEntry(entry.trackId);
      await _library.setTrackCachePath(entry.trackId, null);
      total -= entry.sizeBytes;
    }
  }

  @override
  Future<void> markPlayed(String trackId, {DateTime? at}) async {
    if (await _dao.entryForTrack(trackId) == null) return;
    await _dao.updateLastPlayed(trackId, at ?? _now());
  }

  StorageProvider? _providerFor(Track track) {
    final providerId = track.sourceProvider;
    if (providerId == null || providerId == 'local') return null;
    return _registry.byId(providerId);
  }

  Future<bool> _alreadyCached(Track track) async {
    final path = track.cachePath;
    if (path == null) return false;
    return File(path).exists();
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
}
