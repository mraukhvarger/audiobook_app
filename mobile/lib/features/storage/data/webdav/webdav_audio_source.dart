import '../../../library/domain/audio/audio_file_ref.dart';
import '../../../library/domain/audio/audio_formats.dart';
import '../../../library/domain/audio/audio_metadata.dart';
import '../../../library/domain/audio/audio_source.dart';
import '../../domain/media/media_probe.dart';
import '../../domain/storage_provider.dart';

class WebDavAudioSource implements AudioSource {
  WebDavAudioSource({
    required StorageProvider provider,
    required MediaProbe mediaProbe,
  })  : _provider = provider,
        _mediaProbe = mediaProbe;

  final StorageProvider _provider;
  final MediaProbe _mediaProbe;

  @override
  Future<List<AudioFileRef>> listAudioFiles(String folderRef) async {
    final entries = await _provider.listEntries(folderRef);
    final files = <AudioFileRef>[];
    for (final entry in entries) {
      if (entry.isFolder) continue;
      if (!AudioFormats.isSupported(entry.name)) continue;
      files.add(
        AudioFileRef(
          ref: _provider.uriFor(entry.ref).toString(),
          fileName: entry.name,
          sizeBytes: entry.sizeBytes,
          sourceRef: entry.ref,
        ),
      );
    }
    return files;
  }

  @override
  Future<Duration> probeDuration(AudioFileRef file) {
    return _mediaProbe.probeDuration(
      Uri.parse(file.ref),
      _provider.authHeaders,
    );
  }

  @override
  Future<AudioMetadata?> readMetadata(AudioFileRef file) {
    return _mediaProbe.readMetadata(
      Uri.parse(file.ref),
      _provider.authHeaders,
    );
  }
}
