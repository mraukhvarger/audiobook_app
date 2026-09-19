import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/sleep_timer/shake_detector.dart';

class AccelerometerShakeDetector implements ShakeDetector {
  AccelerometerShakeDetector({
    required this.onShake,
    required this.threshold,
    this.debounce = const Duration(milliseconds: 1000),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const double _gravity = 9.81;

  final void Function() onShake;
  final double threshold;
  final Duration debounce;
  final DateTime Function() _now;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastTriggered = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void start() {
    _subscription ??= accelerometerEventStream().listen(_onEvent);
  }

  @override
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void trigger() {
    _lastTriggered = _now();
    onShake();
  }

  void _onEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if ((magnitude - _gravity).abs() < threshold) return;
    if (_now().difference(_lastTriggered) < debounce) return;
    trigger();
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
