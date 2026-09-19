import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/core/database/app_database.dart';
import 'package:player_book/features/library/data/database/library_dao.dart';
import 'package:player_book/features/library/data/repositories/drift_library_repository.dart';
import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/imported_book.dart';
import 'package:player_book/features/library/domain/models/track.dart';
import 'package:player_book/features/player/data/database/progress_dao.dart';
import 'package:player_book/features/player/data/repositories/drift_progress_repository.dart';
import 'package:player_book/features/player/domain/models/book_position.dart';
import 'package:player_book/features/player/domain/models/playback_progress.dart';

ImportedBook _sampleBook() {
  const bookId = 'book-1';
  return ImportedBook(
    book: Book(
      id: bookId,
      title: 'My Book',
      author: 'Author',
      coverPath: null,
      sourceProvider: 'local',
      sourceRef: '/books/my-book',
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
    ),
    tracks: [
      for (var i = 0; i < 2; i++)
        Track(
          id: 'track-$i',
          bookId: bookId,
          order: i,
          fileName: '${i + 1}.mp3',
          uri: '/books/my-book/${i + 1}.mp3',
          durationMs: (i + 1) * 60000,
          sizeBytes: 1000 + i,
        ),
    ],
  );
}

void main() {
  late AppDatabase database;
  late DriftLibraryRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftLibraryRepository(LibraryDao(database));
  });

  tearDown(() => database.close());

  test('saves and reads back a book with its tracks', () async {
    await repository.saveImportedBook(_sampleBook());

    final books = await repository.getBooks();
    expect(books, hasLength(1));
    expect(books.single.title, 'My Book');
    expect(books.single.author, 'Author');
    expect(books.single.sourceRef, '/books/my-book');

    final tracks = await repository.getTracks('book-1');
    expect(tracks.map((t) => t.fileName), ['1.mp3', '2.mp3']);
    expect(tracks.map((t) => t.order), [0, 1]);
    expect(tracks.first.durationMs, 60000);
  });

  test('aggregates total duration per book', () async {
    await repository.saveImportedBook(_sampleBook());

    final summaries = await repository.getBookSummaries();

    expect(summaries, hasLength(1));
    expect(summaries.single.book.title, 'My Book');
    expect(summaries.single.totalDurationMs, 180000);
  });

  test('reports playback progress in summaries', () async {
    await repository.saveImportedBook(_sampleBook());
    final progressRepository = DriftProgressRepository(ProgressDao(database));
    await progressRepository.saveProgress(
      PlaybackProgress(
        bookId: 'book-1',
        position: const BookPosition(trackIndex: 1, offsetMs: 30000),
        updatedAt: DateTime.utc(2026, 1, 3),
      ),
    );

    final summaries = await repository.getBookSummaries();

    expect(summaries.single.progress, closeTo(0.5, 1e-9));
  });

  test('deletes a book together with its tracks', () async {
    await repository.saveImportedBook(_sampleBook());

    await repository.deleteBook('book-1');

    expect(await repository.getBooks(), isEmpty);
    expect(await repository.getTracks('book-1'), isEmpty);
  });
}
