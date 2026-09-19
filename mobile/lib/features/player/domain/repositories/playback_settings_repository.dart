import '../settings/playback_settings.dart';

abstract interface class PlaybackSettingsRepository {
  Future<PlaybackSettings> load();

  Future<void> save(PlaybackSettings settings);
}
