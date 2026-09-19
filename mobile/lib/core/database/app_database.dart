import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('BookRow')
class Books extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get author => text().nullable()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get sourceProvider => text()();

  TextColumn get sourceRef => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TrackRow')
class Tracks extends Table {
  TextColumn get id => text()();

  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();

  IntColumn get order => integer()();

  TextColumn get fileName => text()();

  TextColumn get uri => text()();

  IntColumn get durationMs => integer()();

  IntColumn get sizeBytes => integer()();

  TextColumn get sourceProvider => text().nullable()();

  TextColumn get sourceRef => text().nullable()();

  TextColumn get cachePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CacheEntryRow')
class CacheEntries extends Table {
  TextColumn get trackId => text()();

  TextColumn get bookId => text()();

  TextColumn get path => text()();

  IntColumn get sizeBytes => integer()();

  DateTimeColumn get lastPlayedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}

@DataClassName('BookProgressRow')
class BookProgress extends Table {
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();

  IntColumn get trackIndex => integer()();

  IntColumn get offsetMs => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {bookId};
}

@DriftDatabase(tables: [Books, Tracks, CacheEntries, BookProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(bookProgress);
        }
        if (from < 3) {
          await m.addColumn(tracks, tracks.sourceProvider);
          await m.addColumn(tracks, tracks.sourceRef);
          await m.addColumn(tracks, tracks.cachePath);
          await m.createTable(cacheEntries);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'player_book.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
