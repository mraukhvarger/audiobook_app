import '../volume/volume_state.dart';

abstract interface class VolumeSettingsRepository {
  Future<VolumeState> load();

  Future<void> save(VolumeState state);
}
