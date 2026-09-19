class Track {
  const Track({
    required this.id,
    required this.bookId,
    required this.order,
    required this.fileName,
    required this.uri,
    required this.durationMs,
    required this.sizeBytes,
    this.sourceProvider,
    this.sourceRef,
    this.cachePath,
  });

  final String id;
  final String bookId;
  final int order;
  final String fileName;
  final String uri;
  final int durationMs;
  final int sizeBytes;
  final String? sourceProvider;
  final String? sourceRef;
  final String? cachePath;

  Duration get duration => Duration(milliseconds: durationMs);

  bool get isRemote => sourceProvider != null && sourceProvider != 'local';

  Track copyWith({
    String? id,
    String? bookId,
    int? order,
    String? fileName,
    String? uri,
    int? durationMs,
    int? sizeBytes,
    String? sourceProvider,
    String? sourceRef,
    String? cachePath,
    bool clearCachePath = false,
  }) {
    return Track(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      order: order ?? this.order,
      fileName: fileName ?? this.fileName,
      uri: uri ?? this.uri,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      sourceRef: sourceRef ?? this.sourceRef,
      cachePath: clearCachePath ? null : (cachePath ?? this.cachePath),
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
        other.sizeBytes == sizeBytes &&
        other.sourceProvider == sourceProvider &&
        other.sourceRef == sourceRef &&
        other.cachePath == cachePath;
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
        sourceProvider,
        sourceRef,
        cachePath,
      );
}
