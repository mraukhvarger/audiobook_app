import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/audio/audio_file_ref.dart';
import '../../domain/audio/audio_formats.dart';
import '../../domain/audio/audio_metadata.dart';
import '../../domain/audio/audio_source.dart';

class LocalFileAudioSource implements AudioSource {
  const LocalFileAudioSource();

  @override
  Future<List<AudioFileRef>> listAudioFiles(String folderRef) async {
    final directory = Directory(folderRef);
    if (!await directory.exists()) {
      throw FileSystemException('Folder not found', folderRef);
    }

    final files = <AudioFileRef>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final fileName = p.basename(entity.path);
      if (!AudioFormats.isSupported(fileName)) continue;
      files.add(
        AudioFileRef(
          ref: entity.path,
          fileName: fileName,
          sizeBytes: await entity.length(),
        ),
      );
    }
    return files;
  }

  @override
  Future<Duration> probeDuration(AudioFileRef file) async => Duration.zero;

  @override
  Future<AudioMetadata?> readMetadata(AudioFileRef file) async => null;
}
