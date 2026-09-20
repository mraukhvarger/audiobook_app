import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/core/logging/app_log_level.dart';
import 'package:player_book/core/logging/app_logger.dart';
import 'package:player_book/core/logging/log_entry.dart';
import 'package:player_book/features/logs/presentation/providers/log_providers.dart';
import 'package:player_book/features/logs/presentation/screens/logs_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

class FakeAppLogger implements AppLogger {
  FakeAppLogger(this.entries);

  final List<LogEntry> entries;
  final _controller = StreamController<LogEntry>.broadcast();
  bool cleared = false;

  @override
  Stream<LogEntry> get stream => _controller.stream;

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  Future<List<LogEntry>> readAll() async => List.of(entries);

  @override
  Future<void> clear() async {
    cleared = true;
    entries.clear();
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  late FakeAppLogger logger;

  LogEntry entry(AppLogLevel level, String message) => LogEntry(
        time: DateTime.utc(2026, 1, 1, 12),
        level: level,
        message: message,
      );

  setUp(() {
    logger = FakeAppLogger([
      entry(AppLogLevel.debug, 'debug message'),
      entry(AppLogLevel.info, 'info message'),
      entry(AppLogLevel.error, 'error message'),
    ]);
  });

  tearDown(() => logger.dispose());

  Widget wrap() {
    return ProviderScope(
      overrides: [appLoggerProvider.overrideWithValue(logger)],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LogsScreen(),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> selectLevel(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButton<AppLogLevel>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('filters the display by level but keeps all entries', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    expect(find.text('info message'), findsOneWidget);
    expect(find.text('error message'), findsOneWidget);
    expect(find.text('debug message'), findsNothing);

    await selectLevel(tester, 'Debug');
    expect(find.text('debug message'), findsOneWidget);

    await selectLevel(tester, 'Ошибка');
    expect(find.text('error message'), findsOneWidget);
    expect(find.text('info message'), findsNothing);
    expect(find.text('debug message'), findsNothing);

    expect(logger.entries, hasLength(3));
  });

  testWidgets('clears the journal', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    await tester.tap(find.byTooltip('Очистить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    expect(logger.cleared, isTrue);
    expect(find.text('Записей нет'), findsOneWidget);
  });
}
