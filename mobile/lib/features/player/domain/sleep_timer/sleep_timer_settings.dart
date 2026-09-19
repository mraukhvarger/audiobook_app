class SleepTimerSettings {
  const SleepTimerSettings({
    this.durationMinutes = 15,
    this.shakeEnabled = true,
    this.shakeThreshold = 14,
  });

  static const List<int> presets = [5, 10, 15];
  static const int minMinutes = 1;
  static const int maxMinutes = 480;

  static const double lowSensitivityThreshold = 20;
  static const double mediumSensitivityThreshold = 14;
  static const double highSensitivityThreshold = 9;

  final int durationMinutes;
  final bool shakeEnabled;
  final double shakeThreshold;

  Duration get duration => Duration(minutes: durationMinutes);

  SleepTimerSettings copyWith({
    int? durationMinutes,
    bool? shakeEnabled,
    double? shakeThreshold,
  }) {
    return SleepTimerSettings(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      shakeThreshold: shakeThreshold ?? this.shakeThreshold,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SleepTimerSettings &&
        other.durationMinutes == durationMinutes &&
        other.shakeEnabled == shakeEnabled &&
        other.shakeThreshold == shakeThreshold;
  }

  @override
  int get hashCode =>
      Object.hash(durationMinutes, shakeEnabled, shakeThreshold);
}
