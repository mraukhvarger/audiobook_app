import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/book_position.dart';
import '../../domain/models/playback_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../database/progress_dao.dart';

class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._dao);

  final ProgressDao _dao;

  @override
  Future<PlaybackProgress?> getProgress(String bookId) async {
    final row = await _dao.progressFor(bookId);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<Map<String, PlaybackProgress>> getAllProgress() async {
    final rows = await _dao.allProgress();
    return {for (final row in rows) row.bookId: _fromRow(row)};
  }

  @override
  Future<void> saveProgress(PlaybackProgress progress) {
    return _dao.upsert(
      BookProgressCompanion.insert(
        bookId: progress.bookId,
        trackIndex: progress.position.trackIndex,
        offsetMs: progress.position.offsetMs,
        updatedAt: progress.updatedAt,
        completed: Value(progress.completed),
      ),
    );
  }

  @override
  Future<void> deleteProgress(String bookId) => _dao.remove(bookId);

  PlaybackProgress _fromRow(BookProgressRow row) {
    return PlaybackProgress(
      bookId: row.bookId,
      position: BookPosition(
        trackIndex: row.trackIndex,
        offsetMs: row.offsetMs,
      ),
      updatedAt: row.updatedAt,
      completed: row.completed,
    );
  }
}
