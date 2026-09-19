import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/domain/engine/playback_engine.dart';
import 'package:player_book/features/player/domain/models/book_position.dart';
import 'package:player_book/features/player/domain/models/playback_progress.dart';
import 'package:player_book/features/player/domain/settings/playback_settings.dart';
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
    clock = MutableClock(DateTime.utc(2026, 1, 1, 12));
    controller = PlayerController(
      bookId: 'book-1',
      engine: engine,
      libraryRepository: library,
      progressRepository: progress,
      settingsRepository: settings,
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
}
