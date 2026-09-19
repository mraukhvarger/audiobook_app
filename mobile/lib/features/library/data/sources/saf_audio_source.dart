import 'package:flutter/services.dart';

import '../../domain/audio/audio_file_ref.dart';
import '../../domain/audio/audio_metadata.dart';
import '../../domain/audio/audio_source.dart';
import '../../domain/audio/folder_picker.dart';

class SafAudioSource implements AudioSource, FolderPicker {
  const SafAudioSource({this.channel = _defaultChannel});

  static const MethodChannel _defaultChannel =
      MethodChannel('com.playerbook/audio_source');

  final MethodChannel channel;

  @override
  Future<PickedFolder?> pickFolder() async {
    final result =
        await channel.invokeMapMethod<Object?, Object?>('pickFolder');
    if (result == null) return null;
    final ref = result['uri'] as String?;
    if (ref == null) return null;
    return PickedFolder(ref: ref, name: (result['name'] as String?) ?? '');
  }

  @override
  Future<List<AudioFileRef>> listAudioFiles(String folderRef) async {
    final raw = await channel.invokeListMethod<Object?>(
      'listFiles',
      {'uri': folderRef},
    );
    return (raw ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(
          (entry) => AudioFileRef(
            ref: entry['uri']! as String,
            fileName: entry['name']! as String,
            sizeBytes: (entry['size'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<Duration> probeDuration(AudioFileRef file) async {
    final milliseconds = await channel.invokeMethod<int>(
      'duration',
      {'uri': file.ref},
    );
    return Duration(milliseconds: milliseconds ?? 0);
  }

  @override
  Future<AudioMetadata?> readMetadata(AudioFileRef file) async {
    final result = await channel.invokeMapMethod<Object?, Object?>(
      'metadata',
      {'uri': file.ref},
    );
    if (result == null) return null;
    return AudioMetadata(
      title: result['title'] as String?,
      author: result['author'] as String?,
      coverPath: result['coverPath'] as String?,
    );
  }
}
