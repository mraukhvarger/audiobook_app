enum PlaybackStatus { idle, loading, ready, completed }

class EngineTrack {
  const EngineTrack({
    required this.id,
    required this.uri,
    required this.title,
    this.album,
    this.artUri,
    this.duration,
  });

  final String id;
  final Uri uri;
  final String title;
  final String? album;
  final Uri? artUri;
  final Duration? duration;
}

abstract interface class PlaybackEngine {
  Stream<Duration> get positionStream;

  Stream<Duration?> get durationStream;

  Stream<bool> get playingStream;

  Stream<int?> get currentIndexStream;

  Stream<PlaybackStatus> get statusStream;

  Stream<Object> get errorStream;

  bool get playing;

  int? get currentIndex;

  Duration get position;

  Duration? get duration;

  double get speed;

  Future<void> load(
    List<EngineTrack> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position, {int? index});

  Future<void> setSpeed(double speed);

  Future<void> setVolume(double volume);

  Future<void> setBoostDb(double decibels);

  Future<void> dispose();
}
