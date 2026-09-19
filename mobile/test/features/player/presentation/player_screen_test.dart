import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/presentation/providers/library_providers.dart';
import 'package:player_book/features/player/domain/volume/volume_state.dart';
import 'package:player_book/features/player/presentation/providers/player_providers.dart';
import 'package:player_book/features/player/presentation/screens/player_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  late FakePlaybackEngine engine;
  late FakeLibraryRepository library;
  late FakeProgressRepository progress;
  late FakeSettingsRepository settings;
  late FakeSleepTimerSettingsRepository sleepSettings;
  late FakeVolumeSettingsRepository volumeSettings;

  setUp(() {
    engine = FakePlaybackEngine();
    library = FakeLibraryRepository(
      book: sampleBook(),
      tracks: [
        sampleTrack(
          id: 't1',
          bookId: 'book-1',
          order: 0,
          durationMs: 10 * 60 * 1000,
        ),
        sampleTrack(
          id: 't2',
          bookId: 'book-1',
          order: 1,
          durationMs: 10 * 60 * 1000,
        ),
      ],
    );
    progress = FakeProgressRepository();
    settings = FakeSettingsRepository();
    sleepSettings = FakeSleepTimerSettingsRepository();
    volumeSettings = FakeVolumeSettingsRepository();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        playbackEngineFactoryProvider.overrideWithValue(() => engine),
        libraryRepositoryProvider.overrideWithValue(library),
        progressRepositoryProvider.overrideWithValue(progress),
        playbackSettingsRepositoryProvider.overrideWithValue(settings),
        sleepTimerSettingsRepositoryProvider.overrideWithValue(sleepSettings),
        volumeSettingsRepositoryProvider.overrideWithValue(volumeSettings),
        shakeDetectorFactoryProvider.overrideWithValue(
          (onShake, threshold) => FakeShakeDetector(onShake),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlayerScreen(bookId: 'book-1'),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('shows book info and unified timeline', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    expect(find.text('Тестовая книга'), findsWidgets);
    expect(find.text('Автор'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('Трек 1 из 2'), findsOneWidget);
  });

  testWidgets('toggles play and pause', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    await tester.tap(find.byTooltip('Играть'));
    await settle(tester);
    expect(find.byTooltip('Пауза'), findsOneWidget);
    expect(engine.playing, isTrue);

    await tester.tap(find.byTooltip('Пауза'));
    await settle(tester);
    expect(find.byTooltip('Играть'), findsOneWidget);
    expect(engine.playing, isFalse);
  });

  testWidgets('changes speed from the settings sheet', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    final speedButton = find.textContaining('Скорость');
    await tester.ensureVisible(speedButton);
    await tester.pump();
    await tester.tap(speedButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('1.5x'));
    await tester.pumpAndSettle();

    expect(engine.speeds, contains(1.5));
    expect(settings.settings.speed, 1.5);
  });

  testWidgets('sleep timer presets are shown and persisted', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    final timerButton = find.textContaining('Таймер сна');
    await tester.ensureVisible(timerButton);
    await tester.pump();
    await tester.tap(timerButton);
    await tester.pumpAndSettle();

    expect(find.text('5 мин'), findsOneWidget);
    expect(find.text('10 мин'), findsOneWidget);
    expect(find.text('15 мин'), findsOneWidget);

    await tester.tap(find.text('5 мин'));
    await tester.pumpAndSettle();
    expect(sleepSettings.settings.durationMinutes, 5);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Осталось'), findsOneWidget);
  });

  testWidgets('volume sheet shows and resets volume and boost', (
    tester,
  ) async {
    volumeSettings.state = const VolumeState(volume: 0.3, boostDb: 5);
    await tester.pumpWidget(wrap());
    await settle(tester);

    final volumeButton = find.textContaining('Громкость');
    await tester.ensureVisible(volumeButton);
    await tester.pump();
    await tester.tap(volumeButton);
    await tester.pumpAndSettle();

    expect(find.text('30%'), findsOneWidget);
    expect(find.text('+5 дБ'), findsOneWidget);

    await tester.tap(find.textContaining('Сбросить'));
    await tester.pumpAndSettle();

    expect(volumeSettings.state, const VolumeState());
    expect(find.text('100%'), findsOneWidget);
  });
}
