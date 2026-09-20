enum AppLogLevel {
  debug,
  info,
  error;

  String get label => switch (this) {
        AppLogLevel.debug => 'DEBUG',
        AppLogLevel.info => 'INFO',
        AppLogLevel.error => 'ERROR',
      };

  /// Whether a displayed threshold of [this] shows an entry of [other].
  bool includes(AppLogLevel other) => other.index >= index;

  static AppLogLevel fromLabel(String label) {
    for (final level in AppLogLevel.values) {
      if (level.label == label) return level;
    }
    return AppLogLevel.info;
  }
}
