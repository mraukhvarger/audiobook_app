import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/presentation/providers/library_providers.dart';
import 'package:player_book/features/player/presentation/providers/player_providers.dart';
import 'package:player_book/features/player/presentation/screens/player_screen.dart';

import '../support/fakes.dart';

void main() {
  late FakePlaybackEngine engine;
  late FakeLibraryRepository library;
  late FakeProgressRepository progress;
  late FakeSettingsRepository settings;

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
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        playbackEngineFactoryProvider.overrideWithValue(() => engine),
        libraryRepositoryProvider.overrideWithValue(library),
        progressRepositoryProvider.overrideWithValue(progress),
        playbackSettingsRepositoryProvider.overrideWithValue(settings),
      ],
      child: const MaterialApp(home: PlayerScreen(bookId: 'book-1')),
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
}
