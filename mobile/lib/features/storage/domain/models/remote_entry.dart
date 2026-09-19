class RemoteEntry {
  const RemoteEntry({
    required this.ref,
    required this.name,
    required this.isFolder,
    this.sizeBytes = 0,
    this.modifiedAt,
    this.mimeType,
  });

  final String ref;
  final String name;
  final bool isFolder;
  final int sizeBytes;
  final DateTime? modifiedAt;
  final String? mimeType;

  @override
  bool operator ==(Object other) {
    return other is RemoteEntry &&
        other.ref == ref &&
        other.name == name &&
        other.isFolder == isFolder &&
        other.sizeBytes == sizeBytes &&
        other.modifiedAt == modifiedAt &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode =>
      Object.hash(ref, name, isFolder, sizeBytes, modifiedAt, mimeType);
}
