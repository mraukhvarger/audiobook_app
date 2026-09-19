import 'dart:async';

import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/book_summary.dart';
import 'package:player_book/features/library/domain/models/imported_book.dart';
import 'package:player_book/features/library/domain/models/track.dart';
import 'package:player_book/features/library/domain/repositories/library_repository.dart';
import 'package:player_book/features/player/domain/engine/playback_engine.dart';
import 'package:player_book/features/player/domain/models/playback_progress.dart';
import 'package:player_book/features/player/domain/repositories/playback_settings_repository.dart';
import 'package:player_book/features/player/domain/repositories/progress_repository.dart';
import 'package:player_book/features/player/domain/repositories/sleep_timer_settings_repository.dart';
import 'package:player_book/features/player/domain/repositories/volume_settings_repository.dart';
import 'package:player_book/features/player/domain/settings/playback_settings.dart';
import 'package:player_book/features/player/domain/sleep_timer/shake_detector.dart';
import 'package:player_book/features/player/domain/sleep_timer/sleep_timer_settings.dart';
import 'package:player_book/features/player/domain/volume/volume_state.dart';

class FakePlaybackEngine implements PlaybackEngine {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _indexController = StreamController<int?>.broadcast();
  final _statusController = StreamController<PlaybackStatus>.broadcast();
  final _errorController = StreamController<Object>.broadcast();

  List<EngineTrack> loadedTracks = const [];
  int? initialIndex;
  Duration? initialPosition;
  final List<({int? index, Duration position})> seeks = [];
  final List<double> speeds = [];
  final List<double> volumes = [];
  final List<double> boosts = [];
  bool disposed = false;

  bool _playing = false;
  int? _currentIndex = 0;
  Duration _position = Duration.zero;
  Duration? _duration;
  double _speed = 1.0;
  double _volume = 1.0;
  double _boostDb = 0;

  double get volume => _volume;

  double get boostDb => _boostDb;

  @override
  bool get playing => _playing;

  @override
  int? get currentIndex => _currentIndex;

  @override
  Duration get position => _position;

  @override
  Duration? get duration => _duration;

  @override
  double get speed => _speed;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<int?> get currentIndexStream => _indexController.stream;

  @override
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  @override
  Stream<Object> get errorStream => _errorController.stream;

  @override
  Future<void> load(
    List<EngineTrack> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    loadedTracks = tracks;
    this.initialIndex = initialIndex;
    this.initialPosition = initialPosition;
    _currentIndex = initialIndex;
    _position = initialPosition;
  }

  @override
  Future<void> play() async {
    _playing = true;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _playingController.add(false);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    seeks.add((index: index, position: position));
    if (index != null) _currentIndex = index;
    _position = position;
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    speeds.add(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume;
    volumes.add(volume);
  }

  @override
  Future<void> setBoostDb(double decibels) async {
    _boostDb = decibels;
    boosts.add(decibels);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _errorController.close();
    await _positionController.close();
    await _playingController.close();
    await _indexController.close();
    await _statusController.close();
    await _durationController.close();
  }

  void emitPosition(Duration value) {
    _position = value;
    _positionController.add(value);
  }

  void emitIndex(int value) {
    _currentIndex = value;
    _indexController.add(value);
  }

  void emitStatus(PlaybackStatus value) => _statusController.add(value);

  void emitError(Object error) => _errorController.add(error);
}

class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository({this.book, this.tracks = const []});

  Book? book;
  List<Track> tracks;

  @override
  Future<Book?> getBook(String id) async => book;

  @override
  Future<List<Track>> getTracks(String bookId) async => tracks;

  @override
  Future<List<Book>> getBooks() async => book == null ? [] : [book!];

  @override
  Future<List<BookSummary>> getBookSummaries() async => [];

  @override
  Future<void> saveImportedBook(ImportedBook imported) async {}

  @override
  Future<void> deleteBook(String id) async {}
}

class FakeProgressRepository implements ProgressRepository {
  final Map<String, PlaybackProgress> saved = {};
  int writes = 0;

  @override
  Future<PlaybackProgress?> getProgress(String bookId) async => saved[bookId];

  @override
  Future<Map<String, PlaybackProgress>> getAllProgress() async => Map.of(saved);

  @override
  Future<void> saveProgress(PlaybackProgress progress) async {
    saved[progress.bookId] = progress;
    writes++;
  }

  @override
  Future<void> deleteProgress(String bookId) async {
    saved.remove(bookId);
  }
}

class FakeSettingsRepository implements PlaybackSettingsRepository {
  FakeSettingsRepository([this.settings = const PlaybackSettings()]);

  PlaybackSettings settings;

  @override
  Future<PlaybackSettings> load() async => settings;

  @override
  Future<void> save(PlaybackSettings value) async {
    settings = value;
  }
}

class FakeSleepTimerSettingsRepository implements SleepTimerSettingsRepository {
  FakeSleepTimerSettingsRepository([
    this.settings = const SleepTimerSettings(),
  ]);

  SleepTimerSettings settings;
  int writes = 0;

  @override
  Future<SleepTimerSettings> load() async => settings;

  @override
  Future<void> save(SleepTimerSettings value) async {
    settings = value;
    writes++;
  }
}

class FakeVolumeSettingsRepository implements VolumeSettingsRepository {
  FakeVolumeSettingsRepository([this.state = const VolumeState()]);

  VolumeState state;
  int writes = 0;

  @override
  Future<VolumeState> load() async => state;

  @override
  Future<void> save(VolumeState value) async {
    state = value;
    writes++;
  }
}

class FakeShakeDetector implements ShakeDetector {
  FakeShakeDetector(this.onShake);
  final void Function() onShake;
  bool started = false;
  int triggers = 0;

  @override
  void start() => started = true;

  @override
  void stop() => started = false;

  @override
  void trigger() {
    triggers++;
    onShake();
  }

  @override
  Future<void> dispose() async => started = false;
}

Book sampleBook({String id = 'book-1'}) {
  return Book(
    id: id,
    title: 'Тестовая книга',
    author: 'Автор',
    sourceProvider: 'local',
    sourceRef: '/books/test',
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

Track sampleTrack({
  required String id,
  required String bookId,
  required int order,
  required int durationMs,
}) {
  return Track(
    id: id,
    bookId: bookId,
    order: order,
    fileName: '$id.mp3',
    uri: '/books/test/$id.mp3',
    durationMs: durationMs,
    sizeBytes: 100,
  );
}
