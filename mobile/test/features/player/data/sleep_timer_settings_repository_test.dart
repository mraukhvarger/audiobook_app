import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/data/settings/shared_prefs_sleep_timer_settings_repository.dart';
import 'package:player_book/features/player/domain/sleep_timer/sleep_timer_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsSleepTimerSettingsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = SharedPrefsSleepTimerSettingsRepository();
  });

  test('returns defaults when nothing is stored', () async {
    final settings = await repository.load();

    expect(settings.durationMinutes, 15);
    expect(settings.shakeEnabled, isTrue);
  });

  test('persists and restores the selected duration', () async {
    await repository.save(
      const SleepTimerSettings(
        durationMinutes: 5,
        shakeEnabled: false,
        shakeThreshold: SleepTimerSettings.highSensitivityThreshold,
      ),
    );

    final loaded = await repository.load();

    expect(loaded.durationMinutes, 5);
    expect(loaded.shakeEnabled, isFalse);
    expect(loaded.shakeThreshold, SleepTimerSettings.highSensitivityThreshold);
  });
}
