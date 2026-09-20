import 'log_entry.dart';

abstract interface class AppLogger {
  Stream<LogEntry> get stream;

  void debug(String message, {Object? error, StackTrace? stackTrace});

  void info(String message, {Object? error, StackTrace? stackTrace});

  void error(String message, {Object? error, StackTrace? stackTrace});

  Future<List<LogEntry>> readAll();

  Future<void> clear();
}

class NoopAppLogger implements AppLogger {
  const NoopAppLogger();

  @override
  Stream<LogEntry> get stream => const Stream.empty();

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  Future<List<LogEntry>> readAll() async => const [];

  @override
  Future<void> clear() async {}
}
