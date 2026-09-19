abstract interface class ShakeDetector {
  void start();

  void stop();

  /// Runs the shake handler bypassing the sensor and the debounce.
  void trigger();

  Future<void> dispose();
}

typedef ShakeDetectorFactory = ShakeDetector Function(
  void Function() onShake,
  double threshold,
);
