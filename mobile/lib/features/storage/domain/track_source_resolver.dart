import 'dart:io';

import '../../library/domain/models/track.dart';
import 'cache/audio_cache.dart';
import 'storage_provider_registry.dart';

class ResolvedTrackSource {
  const ResolvedTrackSource({
    required this.uri,
    this.headers = const {},
    required this.isRemote,
  });

  final Uri uri;
  final Map<String, String> headers;
  final bool isRemote;
}

abstract interface class TrackSourceResolver {
  Future<ResolvedTrackSource> resolve(Track track);

  Future<void> markPlayed(String trackId);
}

class LocalTrackSourceResolver implements TrackSourceResolver {
  const LocalTrackSourceResolver();

  @override
  Future<ResolvedTrackSource> resolve(Track track) async {
    return ResolvedTrackSource(uri: trackUri(track.uri), isRemote: false);
  }

  @override
  Future<void> markPlayed(String trackId) async {}
}

class StorageTrackSourceResolver implements TrackSourceResolver {
  StorageTrackSourceResolver({
    required StorageProviderRegistry registry,
    required AudioCache cache,
    Future<bool> Function(String path)? fileExists,
  })  : _cache = cache,
        _registry = registry,
        _fileExists = fileExists ?? _defaultFileExists;

  final StorageProviderRegistry _registry;
  final AudioCache _cache;
  final Future<bool> Function(String path) _fileExists;

  @override
  Future<ResolvedTrackSource> resolve(Track track) async {
    final cachePath = track.cachePath;
    if (cachePath != null && await _fileExists(cachePath)) {
      return ResolvedTrackSource(uri: Uri.file(cachePath), isRemote: false);
    }
    final providerId = track.sourceProvider;
    final provider = providerId == null ? null : _registry.byId(providerId);
    if (provider == null) {
      return ResolvedTrackSource(uri: trackUri(track.uri), isRemote: false);
    }
    return ResolvedTrackSource(
      uri: _remoteUri(provider.uriFor, track),
      headers: provider.authHeaders,
      isRemote: true,
    );
  }

  @override
  Future<void> markPlayed(String trackId) => _cache.markPlayed(trackId);

  Uri _remoteUri(Uri Function(String ref) uriFor, Track track) {
    final ref = track.sourceRef;
    if (ref != null && ref.isNotEmpty) {
      final parsed = Uri.tryParse(ref);
      if (parsed != null && parsed.hasScheme) return parsed;
      return uriFor(ref);
    }
    return trackUri(track.uri);
  }
}

Uri trackUri(String value) {
  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) return parsed;
  return Uri.file(value);
}

Future<bool> _defaultFileExists(String path) => File(path).exists();
