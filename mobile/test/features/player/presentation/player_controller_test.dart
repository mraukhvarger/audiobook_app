import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/domain/engine/playback_engine.dart';
import 'package:player_book/features/player/domain/models/book_position.dart';
import 'package:player_book/features/player/domain/models/playback_progress.dart';
import 'package:player_book/features/player/domain/settings/playback_settings.dart';
import 'package:player_book/features/player/domain/sleep_timer/sleep_timer.dart';
import 'package:player_book/features/player/domain/sleep_timer/sleep_timer_settings.dart';
import 'package:player_book/features/player/domain/volume/volume_state.dart';
import 'package:player_book/features/player/presentation/controllers/player_controller.dart';

import '../support/fakes.dart';

class MutableClock {
  MutableClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}

Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  const tenMinutes = 10 * 60 * 1000;

  late FakePlaybackEngine engine;
  late FakeLibraryRepository library;
  late FakeProgressRepository progress;
  late FakeSettingsRepository settings;
  late FakeSleepTimerSettingsRepository sleepSettings;
  late FakeShakeDetector? shakeDetector;
  late FakeVolumeSettingsRepository volumeSettings;
  late MutableClock clock;
  late PlayerController controller;

  setUp(() {
    engine = FakePlaybackEngine();
    library = FakeLibraryRepository(
      book: sampleBook(),
      tracks: [
        sampleTrack(
            id: 't1', bookId: 'book-1', order: 0, durationMs: tenMinutes),
        sampleTrack(
            id: 't2', bookId: 'book-1', order: 1, durationMs: tenMinutes),
      ],
    );
    progress = FakeProgressRepository();
    settings = FakeSettingsRepository();
    sleepSettings = FakeSleepTimerSettingsRepository();
    shakeDetector = null;
    volumeSettings = FakeVolumeSettingsRepository();
    clock = MutableClock(DateTime.utc(2026, 1, 1, 12));
    controller = PlayerController(
      bookId: 'book-1',
      engine: engine,
      libraryRepository: library,
      progressRepository: progress,
      settingsRepository: settings,
      sleepTimerSettingsRepository: sleepSettings,
      shakeDetectorFactory: (onShake, threshold) {
        final detector = FakeShakeDetector(onShake);
        shakeDetector = detector;
        return detector;
      },
      volumeSettingsRepository: volumeSettings,
      now: clock.call,
    );
  });

  tearDown(() => controller.dispose());

  test('loads tracks and applies the saved speed', () async {
    settings.settings = const PlaybackSettings(speed: 1.5);

    await controller.initialize();

    expect(controller.loading, isFalse);
    expect(controller.tracks, hasLength(2));
    expect(controller.durationMs, 2 * tenMinutes);
    expect(engine.loadedTracks, hasLength(2));
    expect(engine.speeds, contains(1.5));
    expect(controller.speed, 1.5);
  });

  test('restores a saved position on initialize', () async {
    progress.saved['book-1'] = PlaybackProgress(
      bookId: 'book-1',
      position: const BookPosition(trackIndex: 1, offsetMs: 5 * 60 * 1000),
      updatedAt: clock(),
    );

    await controller.initialize();

    expect(engine.initialIndex, 1);
    expect(engine.initialPosition, const Duration(minutes: 5));
    expect(controller.positionMs, 15 * 60 * 1000);
  });

  test('seeks across file boundaries using the unified timeline', () async {
    await controller.initialize();

    await controller.seekToMs(15 * 60 * 1000);

    expect(engine.seeks.last.index, 1);
    expect(engine.seeks.last.position, const Duration(minutes: 5));
    expect(
      progress.saved['book-1']!.position,
      const BookPosition(trackIndex: 1, offsetMs: 5 * 60 * 1000),
    );
  });

  test('skip forward/back moves by the configured interval', () async {
    await controller.initialize();
    engine.emitPosition(const Duration(seconds: 60));
    await tick();

    await controller.skipBy(30);

    expect(engine.seeks.last.position, const Duration(seconds: 90));
  });

  test('throttles writes but flush keeps the latest position', () async {
    await controller.initialize();

    engine.emitPosition(const Duration(seconds: 10));
    await tick();
    expect(progress.writes, 1);

    clock.advance(const Duration(seconds: 1));
    engine.emitPosition(const Duration(seconds: 20));
    await tick();
    expect(progress.writes, 1);

    clock.advance(const Duration(seconds: 10));
    engine.emitPosition(const Duration(seconds: 30));
    await tick();
    expect(progress.writes, 2);

    clock.advance(const Duration(seconds: 1));
    engine.emitPosition(const Duration(seconds: 40));
    await tick();
    expect(progress.writes, 2);

    await controller.flushProgress();

    expect(progress.writes, 3);
    expect(progress.saved['book-1']!.position.offsetMs, 40 * 1000);
  });

  test('marks the book completed at the end', () async {
    await controller.initialize();

    engine.emitStatus(PlaybackStatus.completed);
    await tick();

    expect(controller.completed, isTrue);
    expect(controller.progress, 1);
    expect(progress.saved['book-1']!.completed, isTrue);
  });

  test('restarts from the beginning after completion', () async {
    await controller.initialize();
    engine.emitStatus(PlaybackStatus.completed);
    await tick();

    await controller.play();

    expect(controller.completed, isFalse);
    expect(engine.seeks.last.position, Duration.zero);
  });

  test('auto-rewinds on resume after pause', () async {
    settings.settings = const PlaybackSettings(autoRewindSeconds: 10);
    await controller.initialize();
    engine.emitPosition(const Duration(seconds: 60));
    await tick();

    await controller.play();
    await tick();
    await controller.pause();
    await tick();
    await controller.play();

    expect(engine.seeks.last.position, const Duration(seconds: 50));
  });

  test('auto-rewind does not go before the beginning', () async {
    settings.settings = const PlaybackSettings(autoRewindSeconds: 10);
    await controller.initialize();
    engine.emitPosition(const Duration(seconds: 5));
    await tick();

    await controller.play();
    await tick();
    await controller.pause();
    await tick();
    await controller.play();

    expect(engine.seeks.last.position, Duration.zero);
  });

  test('applies and persists speed', () async {
    await controller.initialize();

    await controller.setSpeed(1.5);

    expect(engine.speeds.last, 1.5);
    expect(settings.settings.speed, 1.5);
  });

  test('persists updated control settings', () async {
    await controller.initialize();

    await controller.updateSettings(
      const PlaybackSettings(speed: 1.25, skipSeconds: 15),
    );

    expect(engine.speeds.last, 1.25);
    expect(settings.settings.skipSeconds, 15);
  });

  test('skips to the next track on playback error', () async {
    await controller.initialize();

    engine.emitError(Exception('broken file'));
    await tick();

    expect(engine.seeks.last.index, 1);
    expect(engine.seeks.last.position, Duration.zero);
    expect(controller.errorMessage, isNotNull);
  });

  test('reports a missing book', () async {
    library.book = null;

    await controller.initialize();

    expect(controller.book, isNull);
    expect(controller.loading, isFalse);
  });

  test('sleep timer fades volume and pauses when it fires', () async {
    await controller.initialize();

    await controller.startSleepTimer(const Duration(minutes: 5));
    expect(controller.sleepTimerActive, isTrue);
    expect(shakeDetector!.started, isTrue);

    clock.advance(const Duration(minutes: 4, seconds: 55));
    await controller.debugSleepTick();
    expect(controller.sleepTimerPhase, SleepTimerPhase.fading);
    expect(engine.volumes.last, lessThan(1.0));

    clock.advance(const Duration(seconds: 5));
    await controller.debugSleepTick();
    expect(controller.sleepTimerPhase, SleepTimerPhase.fired);
    expect(engine.volumes.last, 0);
    expect(engine.playing, isFalse);
  });

  test('sleep timer fade decreases volume monotonically to zero', () async {
    await controller.initialize();
    await controller.startSleepTimer(const Duration(minutes: 1));

    final volumes = <double>[];
    for (var i = 0; i < 12; i++) {
      clock.advance(const Duration(seconds: 5));
      await controller.debugSleepTick();
      volumes.add(engine.volumes.last);
    }

    expect(volumes.first, 1.0);
    expect(volumes.last, 0);
    for (var i = 1; i < volumes.length; i++) {
      expect(volumes[i], lessThanOrEqualTo(volumes[i - 1]));
    }
  });

  test('shake during fade extends the timer and restores volume', () async {
    await controller.initialize();
    await controller.startSleepTimer(const Duration(minutes: 1));

    clock.advance(const Duration(seconds: 55));
    await controller.debugSleepTick();
    expect(engine.volumes.last, lessThan(1));

    await controller.simulateShake();
    expect(engine.volumes.last, 1.0);

    clock.advance(const Duration(seconds: 55));
    await controller.debugSleepTick();
    expect(controller.sleepTimerPhase, SleepTimerPhase.fading);
  });

  test('shake after firing resumes playback and restarts the timer', () async {
    await controller.initialize();
    await controller.play();
    await controller.startSleepTimer(const Duration(minutes: 1));

    clock.advance(const Duration(seconds: 60));
    await controller.debugSleepTick();
    expect(engine.playing, isFalse);

    await controller.simulateShake();

    expect(engine.playing, isTrue);
    expect(controller.sleepTimerActive, isTrue);
    expect(controller.sleepTimerPhase, SleepTimerPhase.active);
  });

  test('cancelling the sleep timer restores the volume', () async {
    await controller.initialize();
    await controller.startSleepTimer(const Duration(minutes: 1));

    clock.advance(const Duration(seconds: 55));
    await controller.debugSleepTick();
    await controller.cancelSleepTimer();

    expect(controller.sleepTimerActive, isFalse);
    expect(engine.volumes.last, 1.0);
  });

  test('saved duration is reused when toggling the timer', () async {
    await controller.initialize();
    await controller.updateSleepSettings(
      const SleepTimerSettings(durationMinutes: 25),
    );

    expect(sleepSettings.settings.durationMinutes, 25);

    await controller.toggleSleepTimer();
    expect(controller.sleepTimerActive, isTrue);
    expect(controller.sleepTimerRemaining!.inMinutes, greaterThanOrEqualTo(24));

    await controller.toggleSleepTimer();
    expect(controller.sleepTimerActive, isFalse);

    await controller.toggleSleepTimer();
    expect(controller.sleepTimerRemaining!.inMinutes, greaterThanOrEqualTo(24));
  });

  test('loads saved sleep timer settings on initialize', () async {
    sleepSettings.settings =
        const SleepTimerSettings(durationMinutes: 5, shakeEnabled: false);

    await controller.initialize();

    expect(controller.sleepSettings.durationMinutes, 5);
    expect(controller.sleepSettings.shakeEnabled, isFalse);
  });

  test('applies and persists volume', () async {
    await controller.initialize();

    await controller.setVolume(0.6);

    expect(engine.volumes.last, 0.6);
    expect(volumeSettings.state.volume, 0.6);
  });

  test('clamps volume to the allowed range', () async {
    await controller.initialize();

    await controller.setVolume(1.5);
    expect(controller.volumeState.volume, 1.0);

    await controller.setVolume(-0.2);
    expect(controller.volumeState.volume, 0.0);
  });

  test('applies and persists boost, limited to the maximum', () async {
    await controller.initialize();

    await controller.setBoost(25);

    expect(engine.boosts.last, VolumeState.maxBoostDb);
    expect(volumeSettings.state.boostDb, VolumeState.maxBoostDb);
  });

  test('restores saved volume and boost on initialize', () async {
    volumeSettings.state = const VolumeState(volume: 0.4, boostDb: 6);

    await controller.initialize();

    expect(engine.volumes.last, 0.4);
    expect(engine.boosts.last, 6);
    expect(controller.volumeState, const VolumeState(volume: 0.4, boostDb: 6));
  });

  test('reset returns volume and boost to defaults', () async {
    await controller.initialize();
    await controller.setVolume(0.3);
    await controller.setBoost(10);

    await controller.resetVolume();

    expect(controller.volumeState, const VolumeState());
    expect(engine.volumes.last, 1.0);
    expect(engine.boosts.last, 0);
    expect(volumeSettings.state, const VolumeState());
  });

  test('sleep timer fades relative to the user volume', () async {
    await controller.initialize();
    await controller.setVolume(0.5);

    await controller.startSleepTimer(const Duration(minutes: 1));
    clock.advance(const Duration(seconds: 55));
    await controller.debugSleepTick();

    expect(engine.volumes.last, closeTo(0.25, 1e-9));

    await controller.cancelSleepTimer();
    expect(engine.volumes.last, 0.5);
  });
}
