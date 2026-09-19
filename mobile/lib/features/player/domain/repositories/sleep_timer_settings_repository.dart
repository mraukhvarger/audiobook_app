import '../sleep_timer/sleep_timer_settings.dart';

abstract interface class SleepTimerSettingsRepository {
  Future<SleepTimerSettings> load();

  Future<void> save(SleepTimerSettings settings);
}
