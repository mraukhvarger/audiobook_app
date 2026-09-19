import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/sleep_timer_settings_repository.dart';
import '../../domain/sleep_timer/sleep_timer_settings.dart';

class SharedPrefsSleepTimerSettingsRepository
    implements SleepTimerSettingsRepository {
  static const _durationKey = 'sleepTimer.durationMinutes';
  static const _shakeEnabledKey = 'sleepTimer.shakeEnabled';
  static const _shakeThresholdKey = 'sleepTimer.shakeThreshold';

  @override
  Future<SleepTimerSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SleepTimerSettings(
      durationMinutes: prefs.getInt(_durationKey) ?? 15,
      shakeEnabled: prefs.getBool(_shakeEnabledKey) ?? true,
      shakeThreshold: prefs.getDouble(_shakeThresholdKey) ??
          SleepTimerSettings.mediumSensitivityThreshold,
    );
  }

  @override
  Future<void> save(SleepTimerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, settings.durationMinutes);
    await prefs.setBool(_shakeEnabledKey, settings.shakeEnabled);
    await prefs.setDouble(_shakeThresholdKey, settings.shakeThreshold);
  }
}
