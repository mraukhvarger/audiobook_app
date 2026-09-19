import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/core/database/app_database.dart';
import 'package:player_book/features/player/data/database/progress_dao.dart';
import 'package:player_book/features/player/data/repositories/drift_progress_repository.dart';
import 'package:player_book/features/player/domain/models/book_position.dart';
import 'package:player_book/features/player/domain/models/playback_progress.dart';

void main() {
  late AppDatabase database;
  late DriftProgressRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftProgressRepository(ProgressDao(database));
    await database.into(database.books).insert(
          BooksCompanion.insert(
            id: 'book-1',
            title: 'Book',
            sourceProvider: 'local',
            sourceRef: '/books/1',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
  });

  tearDown(() => database.close());

  PlaybackProgress progress({
    BookPosition position = const BookPosition(trackIndex: 1, offsetMs: 5000),
    bool completed = false,
  }) {
    return PlaybackProgress(
      bookId: 'book-1',
      position: position,
      updatedAt: DateTime.utc(2026, 1, 2),
      completed: completed,
    );
  }

  test('saves and restores a position', () async {
    await repository.saveProgress(progress());

    final restored = await repository.getProgress('book-1');

    expect(restored, isNotNull);
    expect(
        restored!.position, const BookPosition(trackIndex: 1, offsetMs: 5000));
    expect(restored.updatedAt.toUtc(), DateTime.utc(2026, 1, 2));
    expect(restored.completed, isFalse);
  });

  test('round-trips the completed flag', () async {
    await repository.saveProgress(progress(completed: true));

    final restored = await repository.getProgress('book-1');

    expect(restored!.completed, isTrue);
  });

  test('upsert overwrites the previous position', () async {
    await repository.saveProgress(progress());
    await repository.saveProgress(
      progress(
        position: const BookPosition(trackIndex: 0, offsetMs: 1000),
        completed: true,
      ),
    );

    final restored = await repository.getProgress('book-1');

    expect(
        restored!.position, const BookPosition(trackIndex: 0, offsetMs: 1000));
    expect(restored.completed, isTrue);
  });

  test('returns all stored progress', () async {
    await repository.saveProgress(progress());

    final all = await repository.getAllProgress();

    expect(all.keys, ['book-1']);
  });

  test('deletes progress', () async {
    await repository.saveProgress(progress());

    await repository.deleteProgress('book-1');

    expect(await repository.getProgress('book-1'), isNull);
  });
}
