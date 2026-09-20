import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_log_level.dart';
import 'app_logger.dart';
import 'log_entry.dart';

class FileAppLogger implements AppLogger {
  FileAppLogger({
    required Future<Directory> Function() directory,
    this.fileName = 'app.log',
    this.maxFileBytes = 512 * 1024,
    this.maxBackups = 3,
    DateTime Function()? now,
  })  : _directory = directory,
        _now = now ?? DateTime.now;

  final Future<Directory> Function() _directory;
  final String fileName;
  final int maxFileBytes;
  final int maxBackups;
  final DateTime Function() _now;

  final _controller = StreamController<LogEntry>.broadcast();
  Future<void> _queue = Future<void>.value();

  @override
  Stream<LogEntry> get stream => _controller.stream;

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _add(AppLogLevel.debug, message, error, stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _add(AppLogLevel.info, message, error, stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _add(AppLogLevel.error, message, error, stackTrace);
  }

  @override
  Future<List<LogEntry>> readAll() async {
    await _queue;
    final file = await _logFile();
    final entries = <LogEntry>[];
    for (var i = maxBackups; i >= 1; i--) {
      entries.addAll(await _read(File('${file.path}.$i')));
    }
    entries.addAll(await _read(file));
    return entries;
  }

  @override
  Future<void> clear() async {
    await _queue;
    final file = await _logFile();
    for (var i = 0; i <= maxBackups; i++) {
      final target = File(i == 0 ? file.path : '${file.path}.$i');
      if (await target.exists()) await target.delete();
    }
  }

  Future<void> dispose() async {
    await _queue;
    await _controller.close();
  }

  void _add(
    AppLogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final entry = LogEntry(
      time: _now(),
      level: level,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );
    _controller.add(entry);
    _queue = _queue.then((_) => _append(entry)).catchError((Object _) {});
  }

  Future<void> _append(LogEntry entry) async {
    final directory = await _directory();
    if (!await directory.exists()) await directory.create(recursive: true);
    final file = File(p.join(directory.path, fileName));
    await _rotateIfNeeded(file);
    await file.writeAsString(
      '${entry.toLine()}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  Future<void> _rotateIfNeeded(File file) async {
    if (!await file.exists()) return;
    if (await file.length() < maxFileBytes) return;
    final oldest = File('${file.path}.$maxBackups');
    if (await oldest.exists()) await oldest.delete();
    for (var i = maxBackups - 1; i >= 1; i--) {
      final source = File('${file.path}.$i');
      if (await source.exists()) await source.rename('${file.path}.${i + 1}');
    }
    await file.rename('${file.path}.1');
  }

  Future<List<LogEntry>> _read(File file) async {
    if (!await file.exists()) return const [];
    try {
      final lines = await file.readAsLines();
      return [
        for (final line in lines) LogEntry.tryParse(line),
      ].whereType<LogEntry>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<File> _logFile() async {
    final directory = await _directory();
    return File(p.join(directory.path, fileName));
  }
}
