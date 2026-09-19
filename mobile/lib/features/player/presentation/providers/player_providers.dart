import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../data/database/progress_dao.dart';
import '../../data/engine/just_audio_engine.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../data/settings/shared_prefs_playback_settings_repository.dart';
import '../../domain/engine/playback_engine.dart';
import '../../domain/repositories/playback_settings_repository.dart';
import '../../domain/repositories/progress_repository.dart';
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

final playerControllerProvider = ChangeNotifierProvider.autoDispose
    .family<PlayerController, String>((ref, bookId) {
  final controller = PlayerController(
    bookId: bookId,
    engine: ref.watch(playbackEngineFactoryProvider)(),
    libraryRepository: ref.watch(libraryRepositoryProvider),
    progressRepository: ref.watch(progressRepositoryProvider),
    settingsRepository: ref.watch(playbackSettingsRepositoryProvider),
  );
  unawaited(controller.initialize());
  return controller;
});
