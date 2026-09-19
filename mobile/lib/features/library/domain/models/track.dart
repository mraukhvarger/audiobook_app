class Track {
  const Track({
    required this.id,
    required this.bookId,
    required this.order,
    required this.fileName,
    required this.uri,
    required this.durationMs,
    required this.sizeBytes,
  });

  final String id;
  final String bookId;
  final int order;
  final String fileName;
  final String uri;
  final int durationMs;
  final int sizeBytes;

  Duration get duration => Duration(milliseconds: durationMs);

  Track copyWith({
    String? id,
    String? bookId,
    int? order,
    String? fileName,
    String? uri,
    int? durationMs,
    int? sizeBytes,
  }) {
    return Track(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      order: order ?? this.order,
      fileName: fileName ?? this.fileName,
      uri: uri ?? this.uri,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Track &&
        other.id == id &&
        other.bookId == bookId &&
        other.order == order &&
        other.fileName == fileName &&
        other.uri == uri &&
        other.durationMs == durationMs &&
        other.sizeBytes == sizeBytes;
  }

  @override
  int get hashCode => Object.hash(
        id,
        bookId,
        order,
        fileName,
        uri,
        durationMs,
        sizeBytes,
      );
}
