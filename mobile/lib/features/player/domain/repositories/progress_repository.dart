import '../models/playback_progress.dart';

abstract interface class ProgressRepository {
  Future<PlaybackProgress?> getProgress(String bookId);

  Future<Map<String, PlaybackProgress>> getAllProgress();

  Future<void> saveProgress(PlaybackProgress progress);

  Future<void> deleteProgress(String bookId);
}
