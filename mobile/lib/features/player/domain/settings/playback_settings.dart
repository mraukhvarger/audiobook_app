class PlaybackSettings {
  const PlaybackSettings({
    this.speed = 1.0,
    this.skipSeconds = 30,
    this.autoRewindSeconds = 10,
    this.autoRewindEnabled = true,
  });

  static const double minSpeed = 0.5;
  static const double maxSpeed = 3.0;
  static const double speedStep = 0.05;

  final double speed;
  final int skipSeconds;
  final int autoRewindSeconds;
  final bool autoRewindEnabled;

  PlaybackSettings copyWith({
    double? speed,
    int? skipSeconds,
    int? autoRewindSeconds,
    bool? autoRewindEnabled,
  }) {
    return PlaybackSettings(
      speed: speed ?? this.speed,
      skipSeconds: skipSeconds ?? this.skipSeconds,
      autoRewindSeconds: autoRewindSeconds ?? this.autoRewindSeconds,
      autoRewindEnabled: autoRewindEnabled ?? this.autoRewindEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlaybackSettings &&
        other.speed == speed &&
        other.skipSeconds == skipSeconds &&
        other.autoRewindSeconds == autoRewindSeconds &&
        other.autoRewindEnabled == autoRewindEnabled;
  }

  @override
  int get hashCode =>
      Object.hash(speed, skipSeconds, autoRewindSeconds, autoRewindEnabled);
}
