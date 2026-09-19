class AudioMetadata {
  const AudioMetadata({this.title, this.author, this.coverPath});

  final String? title;
  final String? author;
  final String? coverPath;

  bool get isEmpty => title == null && author == null && coverPath == null;
}
