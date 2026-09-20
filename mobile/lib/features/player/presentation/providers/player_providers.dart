import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../logs/presentation/providers/log_providers.dart';
import '../../../storage/presentation/providers/storage_providers.dart';
import '../../data/database/progress_dao.dart';
import '../../data/engine/just_audio_engine.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../data/sensors/accelerometer_shake_detector.dart';
import '../../data/settings/shared_prefs_playback_settings_repository.dart';
import '../../data/settings/shared_prefs_sleep_timer_settings_repository.dart';
import '../../data/settings/shared_prefs_volume_settings_repository.dart';
import '../../domain/engine/playback_engine.dart';
import '../../domain/repositories/playback_settings_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/sleep_timer_settings_repository.dart';
import '../../domain/repositories/volume_settings_repository.dart';
import '../../domain/sleep_timer/shake_detector.dart';
import '../controllers/player_controller.dart';

final playbackEngineFactoryProvider =
    Provider<PlaybackEngine Function()>((ref) {
  return () => JustAudioEngine();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ProgressDao(ref.watch(appDatabaseProvider)));
});

final playbackSettingsRepositoryProvider =
    Provider<PlaybackSettingsRepository>((ref) {
  return SharedPrefsPlaybackSettingsRepository();
});

final sleepTimerSettingsRepositoryProvider =
    Provider<SleepTimerSettingsRepository>((ref) {
  return SharedPrefsSleepTimerSettingsRepository();
});

final shakeDetectorFactoryProvider = Provider<ShakeDetectorFactory>((ref) {
  return (onShake, threshold) =>
      AccelerometerShakeDetector(onShake: onShake, threshold: threshold);
});

final volumeSettingsRepositoryProvider =
    Provider<VolumeSettingsRepository>((ref) {
  return SharedPrefsVolumeSettingsRepository();
});

final playerControllerProvider = ChangeNotifierProvider.autoDispose
    .family<PlayerController, String>((ref, bookId) {
  ref.keepAlive();
  final controller = PlayerController(
    bookId: bookId,
    engine: ref.watch(playbackEngineFactoryProvider)(),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    progressRepository: ref.watch(progressRepositoryProvider),
    settingsRepository: ref.watch(playbackSettingsRepositoryProvider),
    sleepTimerSettingsRepository:
        ref.watch(sleepTimerSettingsRepositoryProvider),
    shakeDetectorFactory: ref.watch(shakeDetectorFactoryProvider),
    volumeSettingsRepository: ref.watch(volumeSettingsRepositoryProvider),
    sourceResolver: ref.watch(trackSourceResolverProvider),
    cache: ref.watch(audioCacheProvider),
    logger: ref.watch(appLoggerProvider),
  );
  unawaited(controller.initialize());
  return controller;
});
