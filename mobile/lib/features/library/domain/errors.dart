class NoAudioFilesException implements Exception {
  const NoAudioFilesException(this.folderRef);

  final String folderRef;

  @override
  String toString() => 'No supported audio files found in folder "$folderRef"';
}
