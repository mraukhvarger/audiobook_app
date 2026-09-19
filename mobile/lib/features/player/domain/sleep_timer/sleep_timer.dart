enum SleepTimerPhase { inactive, active, fading, fired }

class SleepTimer {
  SleepTimer({this.fadeDuration = const Duration(seconds: 10)});

  final Duration fadeDuration;

  Duration _duration = Duration.zero;
  DateTime? _endAt;

  Duration get duration => _duration;

  bool get isActive => _endAt != null;

  SleepTimerPhase phaseAt(DateTime now) {
    final endAt = _endAt;
    if (endAt == null) return SleepTimerPhase.inactive;
    final remaining = endAt.difference(now);
    if (remaining <= Duration.zero) return SleepTimerPhase.fired;
    if (remaining < fadeDuration) return SleepTimerPhase.fading;
    return SleepTimerPhase.active;
  }

  Duration? remainingAt(DateTime now) {
    final endAt = _endAt;
    if (endAt == null) return null;
    final remaining = endAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Volume multiplier in `0..1` relative to the base volume, or `null` when
  /// the timer is inactive.
  double? volumeFactorAt(DateTime now) {
    final endAt = _endAt;
    if (endAt == null) return null;
    final remainingMs = endAt.difference(now).inMilliseconds;
    if (remainingMs <= 0) return 0;
    final fadeMs = fadeDuration.inMilliseconds;
    if (remainingMs >= fadeMs) return 1;
    return remainingMs / fadeMs;
  }

  void start({required DateTime now, required Duration duration}) {
    if (duration <= Duration.zero) return;
    _duration = duration;
    _endAt = now.add(duration);
  }

  void extend({required DateTime now}) {
    if (_endAt == null) return;
    _endAt = now.add(_duration);
  }

  void cancel() {
    _endAt = null;
  }
}
