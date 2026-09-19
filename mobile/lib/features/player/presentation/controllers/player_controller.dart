import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../library/domain/models/book.dart';
import '../../../library/domain/models/track.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../domain/engine/playback_engine.dart';
import '../../domain/models/book_position.dart';
import '../../domain/models/playback_progress.dart';
import '../../domain/repositories/playback_settings_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/settings/playback_settings.dart';
import '../../domain/timeline/book_timeline.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    required String bookId,
    required PlaybackEngine engine,
    required LibraryRepository libraryRepository,
    required ProgressRepository progressRepository,
    required PlaybackSettingsRepository settingsRepository,
    DateTime Function()? now,
    Duration saveInterval = const Duration(seconds: 5),
  })  : _bookId = bookId,
        _engine = engine,
        _libraryRepository = libraryRepository,
        _progressRepository = progressRepository,
        _settingsRepository = settingsRepository,
        _now = now ?? DateTime.now,
        _saveInterval = saveInterval;

  final String _bookId;
  final PlaybackEngine _engine;
  final LibraryRepository _libraryRepository;
  final ProgressRepository _progressRepository;
  final PlaybackSettingsRepository _settingsRepository;
  final DateTime Function() _now;
  final Duration _saveInterval;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Book? _book;
  List<Track> _tracks = const [];
  BookTimeline _timeline = BookTimeline(const []);

  bool _loading = true;
  bool _playing = false;
  bool _completed = false;
  bool _hasStarted = false;
  int _positionMs = 0;
  int _currentIndex = 0;
  double _speed = 1.0;
  String? _errorMessage;
  PlaybackSettings _settings = const PlaybackSettings();
  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Book? get book => _book;

  List<Track> get tracks => _tracks;

  bool get loading => _loading;

  bool get playing => _playing;

  bool get completed => _completed;

  int get positionMs => _positionMs;

  int get durationMs => _timeline.totalDurationMs;

  int get currentTrackIndex => _currentIndex;

  double get speed => _speed;

  PlaybackSettings get settings => _settings;

  String? get errorMessage => _errorMessage;

  double get progress {
    if (_completed) return 1;
    final total = durationMs;
    if (total <= 0) return 0;
    return (_positionMs / total).clamp(0.0, 1.0);
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      _settings = await _settingsRepository.load();
      _book = await _libraryRepository.getBook(_bookId);
      if (_book == null) {
        _errorMessage = 'Книга не найдена';
        _loading = false;
        notifyListeners();
        return;
      }
      _tracks = await _libraryRepository.getTracks(_bookId);
      _timeline = BookTimeline(
        _tracks.map((track) => track.durationMs).toList(),
      );
      _speed = _settings.speed;

      final stored = await _progressRepository.getProgress(_bookId);
      var start = BookPosition.zero;
      if (stored != null) {
        if (stored.completed) {
          _completed = true;
          start = _timeline.isEmpty
              ? BookPosition.zero
              : BookPosition(
                  trackIndex: _tracks.length - 1,
                  offsetMs: _timeline.trackDurationsMs.last,
                );
        } else {
          start = stored.position;
        }
      }
      _currentIndex = _clampIndex(start.trackIndex);
      _positionMs = _timeline.isEmpty ? 0 : _timeline.toTotalMs(start);

      _bindStreams();

      if (_tracks.isNotEmpty) {
        await _engine.load(
          _engineTracks(),
          initialIndex: _currentIndex,
          initialPosition: start.offset,
        );
        await _engine.setSpeed(_speed);
      }
      _loading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Не удалось запустить воспроизведение';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (_tracks.isEmpty) return;
    if (_completed) {
      await seekToMs(0);
      _completed = false;
    } else if (_hasStarted && _settings.autoRewindEnabled) {
      final target = (_positionMs - _settings.autoRewindSeconds * 1000)
          .clamp(0, durationMs);
      await seekToMs(target);
    }
    _hasStarted = true;
    _errorMessage = null;
    notifyListeners();
    unawaited(_engine.play());
  }

  Future<void> pause() async {
    await _engine.pause();
    await _persist(force: true);
  }

  Future<void> togglePlay() => _playing ? pause() : play();

  Future<void> seekToMs(int milliseconds) async {
    if (_tracks.isEmpty) return;
    final clamped = milliseconds.clamp(0, durationMs);
    final position = _timeline.fromTotalMs(clamped);
    _positionMs = _timeline.toTotalMs(position);
    _currentIndex = _clampIndex(position.trackIndex);
    _completed = false;
    notifyListeners();
    await _engine.seek(
      Duration(milliseconds: position.offsetMs),
      index: position.trackIndex,
    );
    await _persist(force: true);
  }

  Future<void> skipBy(int seconds) => seekToMs(_positionMs + seconds * 1000);

  Future<void> setSpeed(double speed) async {
    final clamped =
        speed.clamp(PlaybackSettings.minSpeed, PlaybackSettings.maxSpeed);
    _speed = clamped;
    _settings = _settings.copyWith(speed: clamped);
    await _engine.setSpeed(clamped);
    await _settingsRepository.save(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(PlaybackSettings settings) async {
    _settings = settings;
    _speed = settings.speed;
    await _engine.setSpeed(settings.speed);
    await _settingsRepository.save(settings);
    notifyListeners();
  }

  Future<void> flushProgress() => _persist(force: true);

  void _bindStreams() {
    _subscriptions.add(_engine.currentIndexStream.listen(_onIndexChanged));
    _subscriptions.add(_engine.positionStream.listen(_onPositionChanged));
    _subscriptions.add(_engine.playingStream.listen(_onPlayingChanged));
    _subscriptions.add(_engine.statusStream.listen(_onStatusChanged));
    _subscriptions.add(_engine.errorStream.listen(_onError));
  }

  void _onPositionChanged(Duration position) {
    if (_tracks.isEmpty) return;
    _positionMs = _timeline.toTotalMs(
      BookPosition(
        trackIndex: _currentIndex,
        offsetMs: position.inMilliseconds,
      ),
    );
    notifyListeners();
    unawaited(_maybePersist());
  }

  void _onIndexChanged(int? index) {
    if (index == null || index == _currentIndex) return;
    _currentIndex = index;
    _completed = false;
    notifyListeners();
    unawaited(_persist(force: true));
  }

  void _onPlayingChanged(bool playing) {
    final wasPlaying = _playing;
    _playing = playing;
    if (wasPlaying && !playing) {
      unawaited(_persist(force: true));
    }
    notifyListeners();
  }

  void _onStatusChanged(PlaybackStatus status) {
    if (status == PlaybackStatus.completed) {
      _completed = true;
      _positionMs = durationMs;
      unawaited(_persist(force: true));
      notifyListeners();
    }
  }

  void _onError(Object error) {
    _errorMessage = 'Не удалось воспроизвести трек, перехожу к следующему';
    notifyListeners();
    unawaited(_skipAfterError());
  }

  Future<void> _skipAfterError() async {
    if (_currentIndex + 1 < _tracks.length) {
      _currentIndex++;
      await _engine.seek(Duration.zero, index: _currentIndex);
      unawaited(_engine.play());
    } else {
      _completed = true;
      await _persist(force: true);
      notifyListeners();
    }
  }

  Future<void> _maybePersist() async {
    final now = _now();
    if (now.difference(_lastSavedAt) < _saveInterval) return;
    await _persist(force: true, at: now);
  }

  Future<void> _persist({bool force = false, DateTime? at}) async {
    if (_tracks.isEmpty) return;
    final now = at ?? _now();
    if (!force && now.difference(_lastSavedAt) < _saveInterval) return;
    _lastSavedAt = now;
    await _progressRepository.saveProgress(
      PlaybackProgress(
        bookId: _bookId,
        position: _timeline.fromTotalMs(_positionMs),
        updatedAt: now,
        completed: _completed,
      ),
    );
  }

  int _clampIndex(int index) {
    if (_tracks.isEmpty) return 0;
    return index.clamp(0, _tracks.length - 1);
  }

  List<EngineTrack> _engineTracks() {
    final cover = _book?.coverPath;
    final artUri = cover == null ? null : Uri.file(cover);
    return [
      for (final track in _tracks)
        EngineTrack(
          id: track.id,
          uri: _parseUri(track.uri),
          title: track.fileName,
          album: _book?.title,
          artUri: artUri,
          duration: Duration(milliseconds: track.durationMs),
        ),
    ];
  }

  Uri _parseUri(String value) {
    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.hasScheme) return parsed;
    return Uri.file(value);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    unawaited(_engine.dispose());
    super.dispose();
  }
}
