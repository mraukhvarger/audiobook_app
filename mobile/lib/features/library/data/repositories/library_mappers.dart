import '../../domain/models/book.dart';
import '../../domain/models/track.dart';
import '../../../../core/database/app_database.dart';

Book bookFromRow(BookRow row) {
  return Book(
    id: row.id,
    title: row.title,
    author: row.author,
    coverPath: row.coverPath,
    sourceProvider: row.sourceProvider,
    sourceRef: row.sourceRef,
    createdAt: row.createdAt,
  );
}

Track trackFromRow(TrackRow row) {
  return Track(
    id: row.id,
    bookId: row.bookId,
    order: row.order,
    fileName: row.fileName,
    uri: row.uri,
    durationMs: row.durationMs,
    sizeBytes: row.sizeBytes,
  );
}
