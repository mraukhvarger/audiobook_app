import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [BookProgress])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  Future<BookProgressRow?> progressFor(String bookId) {
    return (select(bookProgress)..where((t) => t.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Future<List<BookProgressRow>> allProgress() => select(bookProgress).get();

  Future<void> upsert(BookProgressCompanion entry) {
    return into(bookProgress).insertOnConflictUpdate(entry);
  }

  Future<void> remove(String bookId) {
    return (delete(bookProgress)..where((t) => t.bookId.equals(bookId))).go();
  }
}
