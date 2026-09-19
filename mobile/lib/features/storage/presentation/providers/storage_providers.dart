import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/database_provider.dart';
import '../../../library/domain/usecases/import_book_from_folder.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../data/cache/cache_dao.dart';
import '../../data/cache/file_audio_cache.dart';
import '../../data/media/android_media_probe.dart';
import '../../data/settings/secure_storage_settings_repository.dart';
import '../../data/webdav/webdav_audio_source.dart';
import '../../data/webdav/webdav_config.dart';
import '../../data/webdav/webdav_storage_provider.dart';
import '../../domain/cache/audio_cache.dart';
import '../../domain/models/remote_entry.dart';
import '../../domain/repositories/storage_settings_repository.dart';
import '../../domain/storage_connection.dart';
import '../../domain/storage_provider.dart';
import '../../domain/storage_provider_registry.dart';
import '../../domain/track_source_resolver.dart';
import '../controllers/book_cache_controller.dart';
import '../controllers/storage_connection_controller.dart';

final storageSettingsRepositoryProvider =
    Provider<StorageSettingsRepository>((ref) {
  return SecureStorageSettingsRepository();
});

final storageConnectionProvider = FutureProvider<StorageConnection?>((ref) {
  return ref.watch(storageSettingsRepositoryProvider).load();
});

final storageProviderRegistryProvider =
    Provider<StorageProviderRegistry>((ref) {
  final connection = ref.watch(storageConnectionProvider).valueOrNull;
  return StorageProviderRegistry([
    if (connection != null) _webDavProvider(connection),
  ]);
});

final activeStorageProviderProvider = Provider<StorageProvider?>((ref) {
  final connection = ref.watch(storageConnectionProvider).valueOrNull;
  if (connection == null) return null;
  return ref.watch(storageProviderRegistryProvider).byId(connection.providerId);
});

final storageConnectionControllerProvider =
    ChangeNotifierProvider<StorageConnectionController>((ref) {
  return StorageConnectionController(
    repository: ref.watch(storageSettingsRepositoryProvider),
    providerFactory: _webDavProvider,
  );
});

final cacheDaoProvider = Provider<CacheDao>((ref) {
  return CacheDao(ref.watch(appDatabaseProvider));
});

final audioCacheProvider = Provider<AudioCache>((ref) {
  return FileAudioCache(
    registry: ref.watch(storageProviderRegistryProvider),
    dao: ref.watch(cacheDaoProvider),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    rootDirectory: _cacheDirectory,
  );
});

final trackSourceResolverProvider = Provider<TrackSourceResolver>((ref) {
  return StorageTrackSourceResolver(
    registry: ref.watch(storageProviderRegistryProvider),
    cache: ref.watch(audioCacheProvider),
  );
});

final remoteEntriesProvider =
    FutureProvider.family<List<RemoteEntry>, String>((ref, parentRef) async {
  final provider = ref.watch(activeStorageProviderProvider);
  if (provider == null) {
    throw const StorageAuthException('Storage is not connected');
  }
  return provider.listEntries(parentRef);
});

final remoteImportProvider = Provider<ImportBookFromFolder?>((ref) {
  final provider = ref.watch(activeStorageProviderProvider);
  if (provider == null) return null;
  return ImportBookFromFolder(
    audioSource: WebDavAudioSource(
      provider: provider,
      mediaProbe: const AndroidMediaProbe(),
    ),
    sourceProvider: StorageConnection.webDavProviderId,
  );
});

final bookCacheStatusProvider =
    FutureProvider.family<CacheStatus, String>((ref, bookId) async {
  final cache = ref.watch(audioCacheProvider);
  final tracks = await ref.watch(libraryRepositoryProvider).getTracks(bookId);
  final remote = tracks.where((track) => track.isRemote).toList();
  if (remote.isEmpty) return CacheStatus.cached;
  final cached = await cache.cachedPaths(bookId);
  if (cached.isEmpty) return CacheStatus.none;
  if (cached.length >= remote.length) return CacheStatus.cached;
  return CacheStatus.partial;
});

final bookCacheControllerProvider = ChangeNotifierProvider.autoDispose
    .family<BookCacheController, String>((ref, bookId) {
  return BookCacheController(
    bookId: bookId,
    cache: ref.watch(audioCacheProvider),
  );
});

WebDavStorageProvider _webDavProvider(StorageConnection connection) {
  return WebDavStorageProvider(
    WebDavConfig(
      baseUrl: connection.baseUrl,
      username: connection.username,
      password: connection.password,
    ),
  );
}

Future<Directory> _cacheDirectory() async {
  final directory = await getApplicationSupportDirectory();
  final cache = Directory(p.join(directory.path, 'audio_cache'));
  if (!await cache.exists()) await cache.create(recursive: true);
  return cache;
}
