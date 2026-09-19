import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/data/settings/shared_prefs_playback_settings_repository.dart';
import 'package:player_book/features/player/domain/settings/playback_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsPlaybackSettingsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = SharedPrefsPlaybackSettingsRepository();
  });

  test('returns defaults when nothing is stored', () async {
    final settings = await repository.load();

    expect(settings, const PlaybackSettings());
  });

  test('persists and restores settings', () async {
    await repository.save(
      const PlaybackSettings(
        speed: 1.25,
        skipSeconds: 15,
        autoRewindSeconds: 20,
        autoRewindEnabled: false,
      ),
    );

    final loaded = await repository.load();

    expect(loaded.speed, 1.25);
    expect(loaded.skipSeconds, 15);
    expect(loaded.autoRewindSeconds, 20);
    expect(loaded.autoRewindEnabled, isFalse);
  });
}
