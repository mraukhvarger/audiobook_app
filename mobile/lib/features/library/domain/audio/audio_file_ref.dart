class AudioFileRef {
  const AudioFileRef({
    required this.ref,
    required this.fileName,
    this.sizeBytes = 0,
    this.sourceRef,
  });

  final String ref;
  final String fileName;
  final int sizeBytes;

  /// Провайдер-специфичная ссылка (например, путь WebDAV), если она
  /// отличается от [ref], который используется для доступа к содержимому.
  final String? sourceRef;

  @override
  bool operator ==(Object other) {
    return other is AudioFileRef &&
        other.ref == ref &&
        other.fileName == fileName &&
        other.sizeBytes == sizeBytes &&
        other.sourceRef == sourceRef;
  }

  @override
  int get hashCode => Object.hash(ref, fileName, sizeBytes, sourceRef);
}
