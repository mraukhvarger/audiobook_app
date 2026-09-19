import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/playback_settings_repository.dart';
import '../../domain/settings/playback_settings.dart';

class SharedPrefsPlaybackSettingsRepository
    implements PlaybackSettingsRepository {
  static const _speedKey = 'playback.speed';
  static const _skipKey = 'playback.skipSeconds';
  static const _rewindKey = 'playback.autoRewindSeconds';
  static const _rewindEnabledKey = 'playback.autoRewindEnabled';

  @override
  Future<PlaybackSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlaybackSettings(
      speed: prefs.getDouble(_speedKey) ?? 1.0,
      skipSeconds: prefs.getInt(_skipKey) ?? 30,
      autoRewindSeconds: prefs.getInt(_rewindKey) ?? 10,
      autoRewindEnabled: prefs.getBool(_rewindEnabledKey) ?? true,
    );
  }

  @override
  Future<void> save(PlaybackSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedKey, settings.speed);
    await prefs.setInt(_skipKey, settings.skipSeconds);
    await prefs.setInt(_rewindKey, settings.autoRewindSeconds);
    await prefs.setBool(_rewindEnabledKey, settings.autoRewindEnabled);
  }
}
