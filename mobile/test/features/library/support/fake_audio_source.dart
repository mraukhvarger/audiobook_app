import 'package:player_book/features/library/domain/audio/audio_file_ref.dart';
import 'package:player_book/features/library/domain/audio/audio_metadata.dart';
import 'package:player_book/features/library/domain/audio/audio_source.dart';
import 'package:player_book/features/library/domain/usecases/import_book_from_folder.dart';

class FakeAudioSource implements AudioSource {
  FakeAudioSource(
    this.files, {
    this.durations = const {},
    this.metadata,
  });

  final List<AudioFileRef> files;
  final Map<String, Duration> durations;
  final AudioMetadata? metadata;

  @override
  Future<List<AudioFileRef>> listAudioFiles(String folderRef) async => files;

  @override
  Future<Duration> probeDuration(AudioFileRef file) async {
    return durations[file.fileName] ?? Duration.zero;
  }

  @override
  Future<AudioMetadata?> readMetadata(AudioFileRef file) async => metadata;
}

IdGenerator sequentialIds([String prefix = 'id']) {
  var counter = 0;
  return () => '$prefix-${counter++}';
}
