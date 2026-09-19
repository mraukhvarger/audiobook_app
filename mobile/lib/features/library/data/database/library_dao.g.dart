// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_dao.dart';

// ignore_for_file: type=lint
mixin _$LibraryDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $TracksTable get tracks => attachedDatabase.tracks;
  $BookProgressTable get bookProgress => attachedDatabase.bookProgress;
  LibraryDaoManager get managers => LibraryDaoManager(this);
}

class LibraryDaoManager {
  final _$LibraryDaoMixin _db;
  LibraryDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db.attachedDatabase, _db.tracks);
  $$BookProgressTableTableManager get bookProgress =>
      $$BookProgressTableTableManager(_db.attachedDatabase, _db.bookProgress);
}
