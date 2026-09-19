import '../models/book.dart';
import '../models/book_summary.dart';
import '../models/imported_book.dart';
import '../models/track.dart';

abstract interface class LibraryRepository {
  Future<void> saveImportedBook(ImportedBook imported);

  Future<List<Book>> getBooks();

  Future<Book?> getBook(String id);

  Future<List<BookSummary>> getBookSummaries();

  Future<List<Track>> getTracks(String bookId);

  Future<void> setTrackCachePath(String trackId, String? cachePath);

  Future<void> clearCachePaths(String bookId);

  Future<void> deleteBook(String id);
}
