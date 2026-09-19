import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/domain/sleep_timer/sleep_timer.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1, 22);

  test('starts inactive', () {
    final timer = SleepTimer();
    expect(timer.isActive, isFalse);
    expect(timer.phaseAt(start), SleepTimerPhase.inactive);
    expect(timer.volumeFactorAt(start), isNull);
  });

  test('reports remaining time and active phase', () {
    final timer = SleepTimer()
      ..start(now: start, duration: const Duration(minutes: 5));

    expect(timer.phaseAt(start), SleepTimerPhase.active);
    expect(timer.remainingAt(start), const Duration(minutes: 5));
    expect(
      timer.remainingAt(start.add(const Duration(minutes: 2))),
      const Duration(minutes: 3),
    );
  });

  test('enters fading within the last 10 seconds', () {
    final timer = SleepTimer()
      ..start(now: start, duration: const Duration(minutes: 5));

    final fadingAt = start.add(const Duration(minutes: 4, seconds: 55));
    expect(timer.phaseAt(fadingAt), SleepTimerPhase.fading);
    expect(timer.volumeFactorAt(fadingAt), closeTo(0.5, 1e-9));

    final almostDone = start.add(const Duration(minutes: 4, seconds: 59));
    expect(timer.volumeFactorAt(almostDone), closeTo(0.1, 1e-9));
  });

  test('reaches zero and fired at the end', () {
    final timer = SleepTimer()
      ..start(now: start, duration: const Duration(minutes: 5));

    final end = start.add(const Duration(minutes: 5));
    expect(timer.phaseAt(end), SleepTimerPhase.fired);
    expect(timer.volumeFactorAt(end), 0);
    expect(timer.remainingAt(end), Duration.zero);

    final later = start.add(const Duration(minutes: 6));
    expect(timer.volumeFactorAt(later), 0);
    expect(timer.remainingAt(later), Duration.zero);
  });

  test('extends from now using the original duration', () {
    final timer = SleepTimer()
      ..start(now: start, duration: const Duration(minutes: 5));

    final shakeAt = start.add(const Duration(minutes: 4, seconds: 58));
    timer.extend(now: shakeAt);

    expect(timer.phaseAt(shakeAt), SleepTimerPhase.active);
    expect(timer.volumeFactorAt(shakeAt), 1);
    expect(
      timer.remainingAt(shakeAt),
      const Duration(minutes: 5),
    );
  });

  test('cancel makes the timer inactive', () {
    final timer = SleepTimer()
      ..start(now: start, duration: const Duration(minutes: 5));

    timer.cancel();

    expect(timer.isActive, isFalse);
    expect(timer.phaseAt(start), SleepTimerPhase.inactive);
  });

  test('ignores non-positive durations', () {
    final timer = SleepTimer()..start(now: start, duration: Duration.zero);
    expect(timer.isActive, isFalse);
  });

  test('custom fade duration changes the fade window', () {
    final timer = SleepTimer(fadeDuration: const Duration(seconds: 2))
      ..start(now: start, duration: const Duration(seconds: 10));

    expect(
      timer.phaseAt(start.add(const Duration(seconds: 8))),
      SleepTimerPhase.active,
    );
    expect(
      timer.phaseAt(start.add(const Duration(seconds: 9))),
      SleepTimerPhase.fading,
    );
  });
}
