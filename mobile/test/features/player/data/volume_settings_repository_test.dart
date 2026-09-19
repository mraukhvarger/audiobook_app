import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/data/settings/shared_prefs_volume_settings_repository.dart';
import 'package:player_book/features/player/domain/volume/volume_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsVolumeSettingsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = SharedPrefsVolumeSettingsRepository();
  });

  test('returns defaults when nothing is stored', () async {
    final state = await repository.load();

    expect(state, const VolumeState());
  });

  test('persists and restores volume and boost', () async {
    await repository.save(const VolumeState(volume: 0.42, boostDb: 12));

    final loaded = await repository.load();

    expect(loaded.volume, 0.42);
    expect(loaded.boostDb, 12);
  });
}
