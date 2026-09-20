import 'app_log_level.dart';

class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime time;
  final AppLogLevel level;
  final String message;
  final String? error;
  final String? stackTrace;

  String toLine() {
    final buffer = StringBuffer()
      ..write(time.toUtc().toIso8601String())
      ..write(' ')
      ..write(level.label)
      ..write(' ')
      ..write(_oneLine(message));
    final error = this.error;
    if (error != null && error.isNotEmpty) {
      buffer.write(' | error=${_oneLine(error)}');
    }
    final stackTrace = this.stackTrace;
    if (stackTrace != null && stackTrace.isNotEmpty) {
      buffer.write(' | stack=${_oneLine(stackTrace)}');
    }
    return buffer.toString();
  }

  static LogEntry? tryParse(String line) {
    if (line.trim().isEmpty) return null;
    final firstSpace = line.indexOf(' ');
    if (firstSpace <= 0) return null;
    final time = DateTime.tryParse(line.substring(0, firstSpace));
    if (time == null) return null;

    final rest = line.substring(firstSpace + 1);
    final secondSpace = rest.indexOf(' ');
    if (secondSpace <= 0) return null;
    final level = AppLogLevel.fromLabel(rest.substring(0, secondSpace));

    var body = rest.substring(secondSpace + 1);
    String? error;
    String? stackTrace;
    final errorIndex = body.indexOf(' | error=');
    if (errorIndex >= 0) {
      final afterError = body.substring(errorIndex + ' | error='.length);
      final stackIndex = afterError.indexOf(' | stack=');
      if (stackIndex >= 0) {
        error = afterError.substring(0, stackIndex);
        stackTrace = afterError.substring(stackIndex + ' | stack='.length);
      } else {
        error = afterError;
      }
      body = body.substring(0, errorIndex);
    }

    return LogEntry(
      time: time.toLocal(),
      level: level,
      message: _fromOneLine(body),
      error: error == null ? null : _fromOneLine(error),
      stackTrace: stackTrace == null ? null : _fromOneLine(stackTrace),
    );
  }

  static String _oneLine(String value) =>
      value.replaceAll('\r', '').replaceAll('\n', r'\n');

  static String _fromOneLine(String value) => value.replaceAll(r'\n', '\n');
}
