import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/volume_settings_repository.dart';
import '../../domain/volume/volume_state.dart';

class SharedPrefsVolumeSettingsRepository implements VolumeSettingsRepository {
  static const _volumeKey = 'volume.volume';
  static const _boostKey = 'volume.boostDb';

  @override
  Future<VolumeState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return VolumeState(
      volume: prefs.getDouble(_volumeKey) ?? 1.0,
      boostDb: prefs.getDouble(_boostKey) ?? 0.0,
    );
  }

  @override
  Future<void> save(VolumeState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, state.volume);
    await prefs.setDouble(_boostKey, state.boostDb);
  }
}
