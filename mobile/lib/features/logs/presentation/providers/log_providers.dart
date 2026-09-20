import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/app_log_level.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/logging/file_app_logger.dart';
import '../../../../core/logging/log_entry.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  final logger = FileAppLogger(directory: _logDirectory);
  ref.onDispose(() => logger.dispose());
  return logger;
});

final logDisplayLevelProvider =
    StateProvider<AppLogLevel>((ref) => AppLogLevel.info);

final logEntriesProvider = StreamProvider<List<LogEntry>>((ref) async* {
  final logger = ref.watch(appLoggerProvider);
  final stream = logger.stream;
  final entries = <LogEntry>[...await logger.readAll()];
  yield List.unmodifiable(entries);
  await for (final entry in stream) {
    entries.add(entry);
    yield List.unmodifiable(entries);
  }
});

Future<Directory> _logDirectory() async {
  final directory = await getApplicationSupportDirectory();
  return Directory(p.join(directory.path, 'logs'));
}
