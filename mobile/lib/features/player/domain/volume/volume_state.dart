class VolumeState {
  const VolumeState({this.volume = 1.0, this.boostDb = 0});

  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double volumeStep = 0.01;
  static const double minBoostDb = 0.0;
  static const double maxBoostDb = 20.0;
  static const double boostStepDb = 1.0;

  final double volume;
  final double boostDb;

  bool get hasBoost => boostDb > 0;

  double get percent => volume * 100;

  VolumeState copyWith({double? volume, double? boostDb}) {
    return VolumeState(
      volume: volume ?? this.volume,
      boostDb: boostDb ?? this.boostDb,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VolumeState &&
        other.volume == volume &&
        other.boostDb == boostDb;
  }

  @override
  int get hashCode => Object.hash(volume, boostDb);
}
