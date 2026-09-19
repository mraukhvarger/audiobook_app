import 'package:drift/drift.dart';

import '../../domain/models/book.dart';
import '../../domain/models/book_summary.dart';
import '../../domain/models/imported_book.dart';
import '../../domain/models/track.dart';
import '../../domain/repositories/library_repository.dart';
import '../../../../core/database/app_database.dart';
import '../database/library_dao.dart';
import 'library_mappers.dart';

class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(this._dao);

  final LibraryDao _dao;

  @override
  Future<void> saveImportedBook(ImportedBook imported) async {
    await _dao.insertBookWithTracks(
      BooksCompanion.insert(
        id: imported.book.id,
        title: imported.book.title,
        author: Value(imported.book.author),
        coverPath: Value(imported.book.coverPath),
        sourceProvider: imported.book.sourceProvider,
        sourceRef: imported.book.sourceRef,
        createdAt: imported.book.createdAt,
      ),
      imported.tracks.map((track) {
        return TracksCompanion.insert(
          id: track.id,
          bookId: track.bookId,
          order: track.order,
          fileName: track.fileName,
          uri: track.uri,
          durationMs: track.durationMs,
          sizeBytes: track.sizeBytes,
        );
      }).toList(),
    );
  }

  @override
  Future<List<Book>> getBooks() async {
    final rows = await _dao.allBooks();
    return rows.map(bookFromRow).toList();
  }

  @override
  Future<Book?> getBook(String id) async {
    final row = await _dao.bookById(id);
    return row == null ? null : bookFromRow(row);
  }

  @override
  Future<List<BookSummary>> getBookSummaries() async {
    final rows = await _dao.bookSummaries();
    final progress = await _dao.progressTotals();
    final progressByBook = {for (final item in progress) item.bookId: item};
    return rows.map((row) {
      final stored = progressByBook[row.book.id];
      return BookSummary(
        book: bookFromRow(row.book),
        totalDurationMs: row.totalDurationMs,
        progress: _progressFraction(row.totalDurationMs, stored),
      );
    }).toList();
  }

  double _progressFraction(
    int totalDurationMs,
    ({String bookId, int positionMs, bool completed})? stored,
  ) {
    if (stored == null) return 0;
    if (stored.completed) return 1;
    if (totalDurationMs <= 0) return 0;
    return (stored.positionMs / totalDurationMs).clamp(0.0, 1.0);
  }

  @override
  Future<List<Track>> getTracks(String bookId) async {
    final rows = await _dao.tracksForBook(bookId);
    return rows.map(trackFromRow).toList();
  }

  @override
  Future<void> deleteBook(String id) => _dao.deleteBook(id);
}
