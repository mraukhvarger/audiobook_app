import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/core/logging/app_log_level.dart';
import 'package:player_book/core/logging/file_app_logger.dart';
import 'package:player_book/core/logging/log_entry.dart';

void main() {
  late Directory directory;
  late FileAppLogger logger;

  FileAppLogger build({int maxFileBytes = 512 * 1024, int maxBackups = 3}) {
    return FileAppLogger(
      directory: () async => directory,
      maxFileBytes: maxFileBytes,
      maxBackups: maxBackups,
      now: () => DateTime.utc(2026, 1, 1, 12),
    );
  }

  setUp(() {
    directory = Directory.systemTemp.createTempSync('file_app_logger_test');
    logger = build();
  });

  tearDown(() async {
    await logger.dispose();
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test('writes every level to the file regardless of display', () async {
    logger.debug('debug message');
    logger.info('info message');
    logger.error('error message', error: Exception('boom'));

    final entries = await logger.readAll();

    expect(
      entries.map((entry) => entry.level),
      [AppLogLevel.debug, AppLogLevel.info, AppLogLevel.error],
    );
    expect(entries.first.message, 'debug message');
    expect(entries.last.error, contains('boom'));
    expect(File('${directory.path}/app.log').existsSync(), isTrue);
  });

  test('parses multi-line messages and stack traces', () async {
    logger.error(
      'line one\nline two',
      error: Exception('bad'),
      stackTrace: StackTrace.fromString('at one\nat two'),
    );

    final entries = await logger.readAll();

    expect(entries.single.message, 'line one\nline two');
    expect(entries.single.stackTrace, 'at one\nat two');
  });

  test('rotates and drops the oldest entries over the size limit', () async {
    logger = build(maxFileBytes: 120, maxBackups: 2);
    for (var i = 0; i < 40; i++) {
      logger.info('entry $i ${'x' * 40}');
    }
    final entries = await logger.readAll();

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.contains('app.log'))
        .toList();
    expect(files.length, lessThanOrEqualTo(3));
    expect(entries.length, lessThan(40));
    expect(entries.last.message, contains('entry 39'));
    expect(entries.any((entry) => entry.message.contains('entry 0 ')), isFalse);
  });

  test('clear removes all log files', () async {
    logger.info('one');
    logger.info('two');
    await logger.readAll();

    await logger.clear();

    expect(await logger.readAll(), isEmpty);
    expect(
      directory.listSync().whereType<File>().where(
            (file) => file.path.contains('app.log'),
          ),
      isEmpty,
    );
  });

  test('display threshold keeps more severe levels', () {
    expect(AppLogLevel.info.includes(AppLogLevel.debug), isFalse);
    expect(AppLogLevel.info.includes(AppLogLevel.info), isTrue);
    expect(AppLogLevel.info.includes(AppLogLevel.error), isTrue);
    expect(AppLogLevel.error.includes(AppLogLevel.info), isFalse);
    expect(AppLogLevel.debug.includes(AppLogLevel.debug), isTrue);
  });

  test('log entry round-trips through its line format', () {
    final entry = LogEntry(
      time: DateTime.utc(2026, 3, 4, 5, 6, 7),
      level: AppLogLevel.error,
      message: 'something failed',
      error: 'Exception: nope',
      stackTrace: 'frame one',
    );

    final parsed = LogEntry.tryParse(entry.toLine());

    expect(parsed, isNotNull);
    expect(parsed!.level, AppLogLevel.error);
    expect(parsed.message, 'something failed');
    expect(parsed.error, 'Exception: nope');
    expect(parsed.stackTrace, 'frame one');
  });
}
