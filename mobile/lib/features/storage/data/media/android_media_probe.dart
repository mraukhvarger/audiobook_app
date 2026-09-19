import 'package:flutter/services.dart';

import '../../../library/domain/audio/audio_metadata.dart';
import '../../domain/media/media_probe.dart';

class AndroidMediaProbe implements MediaProbe {
  const AndroidMediaProbe({MethodChannel channel = _defaultChannel})
      : _channel = channel;

  static const MethodChannel _defaultChannel =
      MethodChannel('com.playerbook/media_probe');

  final MethodChannel _channel;

  @override
  Future<Duration> probeDuration(
    Uri uri,
    Map<String, String> headers,
  ) async {
    final milliseconds = await _channel.invokeMethod<int>('duration', {
      'uri': uri.toString(),
      'headers': headers,
    });
    return Duration(milliseconds: milliseconds ?? 0);
  }

  @override
  Future<AudioMetadata?> readMetadata(
    Uri uri,
    Map<String, String> headers,
  ) async {
    final result =
        await _channel.invokeMapMethod<Object?, Object?>('metadata', {
      'uri': uri.toString(),
      'headers': headers,
    });
    if (result == null) return null;
    return AudioMetadata(
      title: result['title'] as String?,
      author: result['author'] as String?,
      coverPath: result['coverPath'] as String?,
    );
  }
}
