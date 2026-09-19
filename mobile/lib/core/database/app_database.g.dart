// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceProviderMeta =
      const VerificationMeta('sourceProvider');
  @override
  late final GeneratedColumn<String> sourceProvider = GeneratedColumn<String>(
      'source_provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceRefMeta =
      const VerificationMeta('sourceRef');
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
      'source_ref', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, author, coverPath, sourceProvider, sourceRef, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<BookRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('source_provider')) {
      context.handle(
          _sourceProviderMeta,
          sourceProvider.isAcceptableOrUnknown(
              data['source_provider']!, _sourceProviderMeta));
    } else if (isInserting) {
      context.missing(_sourceProviderMeta);
    }
    if (data.containsKey('source_ref')) {
      context.handle(_sourceRefMeta,
          sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta));
    } else if (isInserting) {
      context.missing(_sourceRefMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      sourceProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_provider'])!,
      sourceRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_ref'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final String id;
  final String title;
  final String? author;
  final String? coverPath;
  final String sourceProvider;
  final String sourceRef;
  final DateTime createdAt;
  const BookRow(
      {required this.id,
      required this.title,
      this.author,
      this.coverPath,
      required this.sourceProvider,
      required this.sourceRef,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['source_provider'] = Variable<String>(sourceProvider);
    map['source_ref'] = Variable<String>(sourceRef);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      sourceProvider: Value(sourceProvider),
      sourceRef: Value(sourceRef),
      createdAt: Value(createdAt),
    );
  }

  factory BookRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      sourceProvider: serializer.fromJson<String>(json['sourceProvider']),
      sourceRef: serializer.fromJson<String>(json['sourceRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'coverPath': serializer.toJson<String?>(coverPath),
      'sourceProvider': serializer.toJson<String>(sourceProvider),
      'sourceRef': serializer.toJson<String>(sourceRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookRow copyWith(
          {String? id,
          String? title,
          Value<String?> author = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          String? sourceProvider,
          String? sourceRef,
          DateTime? createdAt}) =>
      BookRow(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        sourceProvider: sourceProvider ?? this.sourceProvider,
        sourceRef: sourceRef ?? this.sourceRef,
        createdAt: createdAt ?? this.createdAt,
      );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      sourceProvider: data.sourceProvider.present
          ? data.sourceProvider.value
          : this.sourceProvider,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceProvider: $sourceProvider, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, author, coverPath, sourceProvider, sourceRef, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.coverPath == this.coverPath &&
          other.sourceProvider == this.sourceProvider &&
          other.sourceRef == this.sourceRef &&
          other.createdAt == this.createdAt);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> coverPath;
  final Value<String> sourceProvider;
  final Value<String> sourceRef;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sourceProvider = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    this.coverPath = const Value.absent(),
    required String sourceProvider,
    required String sourceRef,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        sourceProvider = Value(sourceProvider),
        sourceRef = Value(sourceRef),
        createdAt = Value(createdAt);
  static Insertable<BookRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? coverPath,
    Expression<String>? sourceProvider,
    Expression<String>? sourceRef,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (coverPath != null) 'cover_path': coverPath,
      if (sourceProvider != null) 'source_provider': sourceProvider,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? author,
      Value<String?>? coverPath,
      Value<String>? sourceProvider,
      Value<String>? sourceRef,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (sourceProvider.present) {
      map['source_provider'] = Variable<String>(sourceProvider.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceProvider: $sourceProvider, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, TrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
      'uri', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, order, fileName, uri, durationMs, sizeBytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(Insertable<TrackRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
          _uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      uri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class TrackRow extends DataClass implements Insertable<TrackRow> {
  final String id;
  final String bookId;
  final int order;
  final String fileName;
  final String uri;
  final int durationMs;
  final int sizeBytes;
  const TrackRow(
      {required this.id,
      required this.bookId,
      required this.order,
      required this.fileName,
      required this.uri,
      required this.durationMs,
      required this.sizeBytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['order'] = Variable<int>(order);
    map['file_name'] = Variable<String>(fileName);
    map['uri'] = Variable<String>(uri);
    map['duration_ms'] = Variable<int>(durationMs);
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      order: Value(order),
      fileName: Value(fileName),
      uri: Value(uri),
      durationMs: Value(durationMs),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory TrackRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      order: serializer.fromJson<int>(json['order']),
      fileName: serializer.fromJson<String>(json['fileName']),
      uri: serializer.fromJson<String>(json['uri']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'order': serializer.toJson<int>(order),
      'fileName': serializer.toJson<String>(fileName),
      'uri': serializer.toJson<String>(uri),
      'durationMs': serializer.toJson<int>(durationMs),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  TrackRow copyWith(
          {String? id,
          String? bookId,
          int? order,
          String? fileName,
          String? uri,
          int? durationMs,
          int? sizeBytes}) =>
      TrackRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        order: order ?? this.order,
        fileName: fileName ?? this.fileName,
        uri: uri ?? this.uri,
        durationMs: durationMs ?? this.durationMs,
        sizeBytes: sizeBytes ?? this.sizeBytes,
      );
  TrackRow copyWithCompanion(TracksCompanion data) {
    return TrackRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      order: data.order.present ? data.order.value : this.order,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      uri: data.uri.present ? data.uri.value : this.uri,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('order: $order, ')
          ..write('fileName: $fileName, ')
          ..write('uri: $uri, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, order, fileName, uri, durationMs, sizeBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.order == this.order &&
          other.fileName == this.fileName &&
          other.uri == this.uri &&
          other.durationMs == this.durationMs &&
          other.sizeBytes == this.sizeBytes);
}

class TracksCompanion extends UpdateCompanion<TrackRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> order;
  final Value<String> fileName;
  final Value<String> uri;
  final Value<int> durationMs;
  final Value<int> sizeBytes;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.order = const Value.absent(),
    this.fileName = const Value.absent(),
    this.uri = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    required String bookId,
    required int order,
    required String fileName,
    required String uri,
    required int durationMs,
    required int sizeBytes,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        order = Value(order),
        fileName = Value(fileName),
        uri = Value(uri),
        durationMs = Value(durationMs),
        sizeBytes = Value(sizeBytes);
  static Insertable<TrackRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? order,
    Expression<String>? fileName,
    Expression<String>? uri,
    Expression<int>? durationMs,
    Expression<int>? sizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (order != null) 'order': order,
      if (fileName != null) 'file_name': fileName,
      if (uri != null) 'uri': uri,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? order,
      Value<String>? fileName,
      Value<String>? uri,
      Value<int>? durationMs,
      Value<int>? sizeBytes,
      Value<int>? rowid}) {
    return TracksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      order: order ?? this.order,
      fileName: fileName ?? this.fileName,
      uri: uri ?? this.uri,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('order: $order, ')
          ..write('fileName: $fileName, ')
          ..write('uri: $uri, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookProgressTable extends BookProgress
    with TableInfo<$BookProgressTable, BookProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _trackIndexMeta =
      const VerificationMeta('trackIndex');
  @override
  late final GeneratedColumn<int> trackIndex = GeneratedColumn<int>(
      'track_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _offsetMsMeta =
      const VerificationMeta('offsetMs');
  @override
  late final GeneratedColumn<int> offsetMs = GeneratedColumn<int>(
      'offset_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [bookId, trackIndex, offsetMs, updatedAt, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_progress';
  @override
  VerificationContext validateIntegrity(Insertable<BookProgressRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('track_index')) {
      context.handle(
          _trackIndexMeta,
          trackIndex.isAcceptableOrUnknown(
              data['track_index']!, _trackIndexMeta));
    } else if (isInserting) {
      context.missing(_trackIndexMeta);
    }
    if (data.containsKey('offset_ms')) {
      context.handle(_offsetMsMeta,
          offsetMs.isAcceptableOrUnknown(data['offset_ms']!, _offsetMsMeta));
    } else if (isInserting) {
      context.missing(_offsetMsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  BookProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookProgressRow(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      trackIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_index'])!,
      offsetMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}offset_ms'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
    );
  }

  @override
  $BookProgressTable createAlias(String alias) {
    return $BookProgressTable(attachedDatabase, alias);
  }
}

class BookProgressRow extends DataClass implements Insertable<BookProgressRow> {
  final String bookId;
  final int trackIndex;
  final int offsetMs;
  final DateTime updatedAt;
  final bool completed;
  const BookProgressRow(
      {required this.bookId,
      required this.trackIndex,
      required this.offsetMs,
      required this.updatedAt,
      required this.completed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['track_index'] = Variable<int>(trackIndex);
    map['offset_ms'] = Variable<int>(offsetMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  BookProgressCompanion toCompanion(bool nullToAbsent) {
    return BookProgressCompanion(
      bookId: Value(bookId),
      trackIndex: Value(trackIndex),
      offsetMs: Value(offsetMs),
      updatedAt: Value(updatedAt),
      completed: Value(completed),
    );
  }

  factory BookProgressRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      trackIndex: serializer.fromJson<int>(json['trackIndex']),
      offsetMs: serializer.fromJson<int>(json['offsetMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'trackIndex': serializer.toJson<int>(trackIndex),
      'offsetMs': serializer.toJson<int>(offsetMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  BookProgressRow copyWith(
          {String? bookId,
          int? trackIndex,
          int? offsetMs,
          DateTime? updatedAt,
          bool? completed}) =>
      BookProgressRow(
        bookId: bookId ?? this.bookId,
        trackIndex: trackIndex ?? this.trackIndex,
        offsetMs: offsetMs ?? this.offsetMs,
        updatedAt: updatedAt ?? this.updatedAt,
        completed: completed ?? this.completed,
      );
  BookProgressRow copyWithCompanion(BookProgressCompanion data) {
    return BookProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      trackIndex:
          data.trackIndex.present ? data.trackIndex.value : this.trackIndex,
      offsetMs: data.offsetMs.present ? data.offsetMs.value : this.offsetMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('trackIndex: $trackIndex, ')
          ..write('offsetMs: $offsetMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, trackIndex, offsetMs, updatedAt, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookProgressRow &&
          other.bookId == this.bookId &&
          other.trackIndex == this.trackIndex &&
          other.offsetMs == this.offsetMs &&
          other.updatedAt == this.updatedAt &&
          other.completed == this.completed);
}

class BookProgressCompanion extends UpdateCompanion<BookProgressRow> {
  final Value<String> bookId;
  final Value<int> trackIndex;
  final Value<int> offsetMs;
  final Value<DateTime> updatedAt;
  final Value<bool> completed;
  final Value<int> rowid;
  const BookProgressCompanion({
    this.bookId = const Value.absent(),
    this.trackIndex = const Value.absent(),
    this.offsetMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookProgressCompanion.insert({
    required String bookId,
    required int trackIndex,
    required int offsetMs,
    required DateTime updatedAt,
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        trackIndex = Value(trackIndex),
        offsetMs = Value(offsetMs),
        updatedAt = Value(updatedAt);
  static Insertable<BookProgressRow> custom({
    Expression<String>? bookId,
    Expression<int>? trackIndex,
    Expression<int>? offsetMs,
    Expression<DateTime>? updatedAt,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (trackIndex != null) 'track_index': trackIndex,
      if (offsetMs != null) 'offset_ms': offsetMs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookProgressCompanion copyWith(
      {Value<String>? bookId,
      Value<int>? trackIndex,
      Value<int>? offsetMs,
      Value<DateTime>? updatedAt,
      Value<bool>? completed,
      Value<int>? rowid}) {
    return BookProgressCompanion(
      bookId: bookId ?? this.bookId,
      trackIndex: trackIndex ?? this.trackIndex,
      offsetMs: offsetMs ?? this.offsetMs,
      updatedAt: updatedAt ?? this.updatedAt,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (trackIndex.present) {
      map['track_index'] = Variable<int>(trackIndex.value);
    }
    if (offsetMs.present) {
      map['offset_ms'] = Variable<int>(offsetMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookProgressCompanion(')
          ..write('bookId: $bookId, ')
          ..write('trackIndex: $trackIndex, ')
          ..write('offsetMs: $offsetMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $BookProgressTable bookProgress = $BookProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [books, tracks, bookProgress];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tracks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('book_progress', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  required String id,
  required String title,
  Value<String?> author,
  Value<String?> coverPath,
  required String sourceProvider,
  required String sourceRef,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> author,
  Value<String?> coverPath,
  Value<String> sourceProvider,
  Value<String> sourceRef,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TracksTable, List<TrackRow>> _tracksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tracks,
          aliasName: 'books__id__tracks__book_id');

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager($_db, $_db.tracks)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookProgressTable, List<BookProgressRow>>
      _bookProgressRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookProgress,
              aliasName: 'books__id__book_progress__book_id');

  $$BookProgressTableProcessedTableManager get bookProgressRefs {
    final manager = $$BookProgressTableTableManager($_db, $_db.bookProgress)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookProgressRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceRef => $composableBuilder(
      column: $table.sourceRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tracksRefs(
      Expression<bool> Function($$TracksTableFilterComposer f) f) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tracks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TracksTableFilterComposer(
              $db: $db,
              $table: $db.tracks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookProgressRefs(
      Expression<bool> Function($$BookProgressTableFilterComposer f) f) {
    final $$BookProgressTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookProgress,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookProgressTableFilterComposer(
              $db: $db,
              $table: $db.bookProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceRef => $composableBuilder(
      column: $table.sourceRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tracksRefs<T extends Object>(
      Expression<T> Function($$TracksTableAnnotationComposer a) f) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tracks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TracksTableAnnotationComposer(
              $db: $db,
              $table: $db.tracks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bookProgressRefs<T extends Object>(
      Expression<T> Function($$BookProgressTableAnnotationComposer a) f) {
    final $$BookProgressTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookProgress,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookProgressTableAnnotationComposer(
              $db: $db,
              $table: $db.bookProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    BookRow,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (BookRow, $$BooksTableReferences),
    BookRow,
    PrefetchHooks Function({bool tracksRefs, bool bookProgressRefs})> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String> sourceProvider = const Value.absent(),
            Value<String> sourceRef = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            author: author,
            coverPath: coverPath,
            sourceProvider: sourceProvider,
            sourceRef: sourceRef,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> author = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            required String sourceProvider,
            required String sourceRef,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            author: author,
            coverPath: coverPath,
            sourceProvider: sourceProvider,
            sourceRef: sourceRef,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BooksTable, BookRow>(table),
                    $$BooksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tracksRefs = false, bookProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tracksRefs) db.tracks,
                if (bookProgressRefs) db.bookProgress
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable, TrackRow>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._tracksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0).tracksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (bookProgressRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable,
                            BookProgressRow>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._bookProgressRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .bookProgressRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    BookRow,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (BookRow, $$BooksTableReferences),
    BookRow,
    PrefetchHooks Function({bool tracksRefs, bool bookProgressRefs})>;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  required String id,
  required String bookId,
  required int order,
  required String fileName,
  required String uri,
  required int durationMs,
  required int sizeBytes,
  Value<int> rowid,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> order,
  Value<String> fileName,
  Value<String> uri,
  Value<int> durationMs,
  Value<int> sizeBytes,
  Value<int> rowid,
});

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, TrackRow> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('tracks__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TracksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TracksTable,
    TrackRow,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (TrackRow, $$TracksTableReferences),
    TrackRow,
    PrefetchHooks Function({bool bookId})> {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> uri = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TracksCompanion(
            id: id,
            bookId: bookId,
            order: order,
            fileName: fileName,
            uri: uri,
            durationMs: durationMs,
            sizeBytes: sizeBytes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int order,
            required String fileName,
            required String uri,
            required int durationMs,
            required int sizeBytes,
            Value<int> rowid = const Value.absent(),
          }) =>
              TracksCompanion.insert(
            id: id,
            bookId: bookId,
            order: order,
            fileName: fileName,
            uri: uri,
            durationMs: durationMs,
            sizeBytes: sizeBytes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TracksTable, TrackRow>(table),
                    $$TracksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable: $$TracksTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$TracksTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TracksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TracksTable,
    TrackRow,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (TrackRow, $$TracksTableReferences),
    TrackRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$BookProgressTableCreateCompanionBuilder = BookProgressCompanion
    Function({
  required String bookId,
  required int trackIndex,
  required int offsetMs,
  required DateTime updatedAt,
  Value<bool> completed,
  Value<int> rowid,
});
typedef $$BookProgressTableUpdateCompanionBuilder = BookProgressCompanion
    Function({
  Value<String> bookId,
  Value<int> trackIndex,
  Value<int> offsetMs,
  Value<DateTime> updatedAt,
  Value<bool> completed,
  Value<int> rowid,
});

final class $$BookProgressTableReferences
    extends BaseReferences<_$AppDatabase, $BookProgressTable, BookProgressRow> {
  $$BookProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_progress__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookProgressTableFilterComposer
    extends Composer<_$AppDatabase, $BookProgressTable> {
  $$BookProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get trackIndex => $composableBuilder(
      column: $table.trackIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get offsetMs => $composableBuilder(
      column: $table.offsetMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $BookProgressTable> {
  $$BookProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get trackIndex => $composableBuilder(
      column: $table.trackIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get offsetMs => $composableBuilder(
      column: $table.offsetMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookProgressTable> {
  $$BookProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get trackIndex => $composableBuilder(
      column: $table.trackIndex, builder: (column) => column);

  GeneratedColumn<int> get offsetMs =>
      $composableBuilder(column: $table.offsetMs, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookProgressTable,
    BookProgressRow,
    $$BookProgressTableFilterComposer,
    $$BookProgressTableOrderingComposer,
    $$BookProgressTableAnnotationComposer,
    $$BookProgressTableCreateCompanionBuilder,
    $$BookProgressTableUpdateCompanionBuilder,
    (BookProgressRow, $$BookProgressTableReferences),
    BookProgressRow,
    PrefetchHooks Function({bool bookId})> {
  $$BookProgressTableTableManager(_$AppDatabase db, $BookProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookId = const Value.absent(),
            Value<int> trackIndex = const Value.absent(),
            Value<int> offsetMs = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookProgressCompanion(
            bookId: bookId,
            trackIndex: trackIndex,
            offsetMs: offsetMs,
            updatedAt: updatedAt,
            completed: completed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookId,
            required int trackIndex,
            required int offsetMs,
            required DateTime updatedAt,
            Value<bool> completed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookProgressCompanion.insert(
            bookId: bookId,
            trackIndex: trackIndex,
            offsetMs: offsetMs,
            updatedAt: updatedAt,
            completed: completed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BookProgressTable, BookProgressRow>(table),
                    $$BookProgressTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$BookProgressTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$BookProgressTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookProgressTable,
    BookProgressRow,
    $$BookProgressTableFilterComposer,
    $$BookProgressTableOrderingComposer,
    $$BookProgressTableAnnotationComposer,
    $$BookProgressTableCreateCompanionBuilder,
    $$BookProgressTableUpdateCompanionBuilder,
    (BookProgressRow, $$BookProgressTableReferences),
    BookProgressRow,
    PrefetchHooks Function({bool bookId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$BookProgressTableTableManager get bookProgress =>
      $$BookProgressTableTableManager(_db, _db.bookProgress);
}
