import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

part 'library_dao.g.dart';

@DriftAccessor(tables: [Books, Tracks, BookProgress])
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(super.db);

  Future<List<({String bookId, int positionMs, bool completed})>>
      progressTotals() {
    return customSelect(
      'SELECT p.book_id AS bookId, '
      'p.completed AS completed, '
      'p.offset_ms + COALESCE((SELECT SUM(t.duration_ms) FROM tracks t '
      'WHERE t.book_id = p.book_id AND t."order" < p.track_index), 0) AS positionMs '
      'FROM book_progress p',
      readsFrom: {bookProgress, tracks},
    )
        .map(
          (row) => (
            bookId: row.read<String>('bookId'),
            positionMs: row.read<int>('positionMs'),
            completed: row.read<int>('completed') != 0,
          ),
        )
        .get();
  }

  Future<void> insertBookWithTracks(
    BooksCompanion book,
    List<TracksCompanion> trackList,
  ) async {
    await transaction(() async {
      await into(books).insert(book);
      await batch((batch) => batch.insertAll(tracks, trackList));
    });
  }

  Future<List<BookRow>> allBooks() {
    return (select(books)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<BookRow?> bookById(String id) {
    return (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<({BookRow book, int totalDurationMs})>> bookSummaries() async {
    final totalDuration = tracks.durationMs.sum();
    final query = select(books).join([
      leftOuterJoin(tracks, tracks.bookId.equalsExp(books.id)),
    ])
      ..addColumns([totalDuration])
      ..groupBy([books.id]);
    final rows = await query.get();
    return rows
        .map(
          (row) => (
            book: row.readTable(books),
            totalDurationMs: row.read(totalDuration) ?? 0,
          ),
        )
        .toList();
  }

  Future<List<TrackRow>> tracksForBook(String bookId) {
    return (select(tracks)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
  }

  Future<void> deleteBook(String id) async {
    await (delete(books)..where((t) => t.id.equals(id))).go();
  }
}
