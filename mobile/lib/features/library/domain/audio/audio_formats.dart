class AudioFormats {
  const AudioFormats._();

  static const Set<String> supportedExtensions = {
    'mp3',
    'm4a',
    'm4b',
    'aac',
    'ogg',
    'oga',
    'opus',
    'flac',
    'wav',
    'wma',
  };

  static bool isSupported(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return false;
    final extension = fileName.substring(dot + 1).toLowerCase();
    return supportedExtensions.contains(extension);
  }
}
