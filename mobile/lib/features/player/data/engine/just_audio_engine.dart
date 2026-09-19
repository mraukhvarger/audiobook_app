import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../domain/engine/playback_engine.dart';

class JustAudioEngine implements PlaybackEngine {
  factory JustAudioEngine({AudioPlayer? player}) {
    final loudnessEnhancer = AndroidLoudnessEnhancer();
    final resolvedPlayer = player ??
        AudioPlayer(
          audioPipeline: AudioPipeline(
            androidAudioEffects: [loudnessEnhancer],
          ),
        );
    return JustAudioEngine._(resolvedPlayer, loudnessEnhancer);
  }

  JustAudioEngine._(this._player, this._loudnessEnhancer);

  final AudioPlayer _player;
  final AndroidLoudnessEnhancer _loudnessEnhancer;
  final _errors = StreamController<Object>.broadcast();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<PlaybackStatus> get statusStream =>
      _player.processingStateStream.map(_mapStatus);

  @override
  Stream<Object> get errorStream => _errors.stream;

  @override
  bool get playing => _player.playing;

  @override
  int? get currentIndex => _player.currentIndex;

  @override
  Duration get position => _player.position;

  @override
  Duration? get duration => _player.duration;

  @override
  double get speed => _player.speed;

  @override
  Future<void> load(
    List<EngineTrack> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    final source = ConcatenatingAudioSource(
      children: [
        for (final track in tracks)
          AudioSource.uri(
            track.uri,
            tag: MediaItem(
              id: track.id,
              title: track.title,
              album: track.album,
              duration: track.duration,
              artUri: track.artUri,
            ),
          ),
      ],
    );
    await _player.setAudioSource(
      source,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } on PlayerInterruptedException {
      // Normal when the player is paused, stopped or disposed.
    } catch (error) {
      _errors.add(error);
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setBoostDb(double decibels) async {
    final clamped = decibels.clamp(0.0, 20.0);
    await _loudnessEnhancer.setEnabled(clamped > 0);
    await _loudnessEnhancer.setTargetGain(clamped);
  }

  @override
  Future<void> dispose() async {
    await _loudnessEnhancer.setEnabled(false);
    await _errors.close();
    await _player.dispose();
  }

  PlaybackStatus _mapStatus(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return PlaybackStatus.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return PlaybackStatus.loading;
      case ProcessingState.ready:
        return PlaybackStatus.ready;
      case ProcessingState.completed:
        return PlaybackStatus.completed;
    }
  }
}
