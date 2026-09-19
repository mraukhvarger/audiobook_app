import 'audio_file_ref.dart';
import 'audio_metadata.dart';

abstract interface class AudioSource {
  Future<List<AudioFileRef>> listAudioFiles(String folderRef);

  Future<Duration> probeDuration(AudioFileRef file);

  Future<AudioMetadata?> readMetadata(AudioFileRef file);
}
