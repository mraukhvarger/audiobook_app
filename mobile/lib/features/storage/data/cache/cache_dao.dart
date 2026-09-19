import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

part 'cache_dao.g.dart';

@DriftAccessor(tables: [CacheEntries])
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.db);

  Future<void> upsert(CacheEntriesCompanion entry) {
    return into(cacheEntries).insertOnConflictUpdate(entry);
  }

  Future<CacheEntryRow?> entryForTrack(String trackId) {
    return (select(cacheEntries)..where((t) => t.trackId.equals(trackId)))
        .getSingleOrNull();
  }

  Future<List<CacheEntryRow>> entriesForBook(String bookId) {
    return (select(cacheEntries)..where((t) => t.bookId.equals(bookId))).get();
  }

  Future<List<CacheEntryRow>> allEntries() => select(cacheEntries).get();

  Future<List<CacheEntryRow>> orderedByLeastRecentlyUsed() {
    return (select(cacheEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.lastPlayedAt)]))
        .get();
  }

  Future<int> totalSize() async {
    final sum = cacheEntries.sizeBytes.sum();
    final query = selectOnly(cacheEntries)..addColumns([sum]);
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<void> updateLastPlayed(String trackId, DateTime at) {
    return (update(cacheEntries)..where((t) => t.trackId.equals(trackId)))
        .write(CacheEntriesCompanion(lastPlayedAt: Value(at)));
  }

  Future<void> deleteEntry(String trackId) {
    return (delete(cacheEntries)..where((t) => t.trackId.equals(trackId))).go();
  }

  Future<void> deleteForBook(String bookId) {
    return (delete(cacheEntries)..where((t) => t.bookId.equals(bookId))).go();
  }

  Future<void> deleteAll() => delete(cacheEntries).go();
}
