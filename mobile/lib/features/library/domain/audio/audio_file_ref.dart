class AudioFileRef {
  const AudioFileRef({
    required this.ref,
    required this.fileName,
    this.sizeBytes = 0,
  });

  final String ref;
  final String fileName;
  final int sizeBytes;

  @override
  bool operator ==(Object other) {
    return other is AudioFileRef &&
        other.ref == ref &&
        other.fileName == fileName &&
        other.sizeBytes == sizeBytes;
  }

  @override
  int get hashCode => Object.hash(ref, fileName, sizeBytes);
}
