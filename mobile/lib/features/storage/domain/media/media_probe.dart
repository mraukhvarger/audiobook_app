import '../../../library/domain/audio/audio_metadata.dart';

abstract interface class MediaProbe {
  Future<Duration> probeDuration(Uri uri, Map<String, String> headers);

  Future<AudioMetadata?> readMetadata(Uri uri, Map<String, String> headers);
}

class NoopMediaProbe implements MediaProbe {
  const NoopMediaProbe();

  @override
  Future<Duration> probeDuration(Uri uri, Map<String, String> headers) async =>
      Duration.zero;

  @override
  Future<AudioMetadata?> readMetadata(
    Uri uri,
    Map<String, String> headers,
  ) async =>
      null;
}
