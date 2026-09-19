class Book {
  const Book({
    required this.id,
    required this.title,
    this.author,
    this.coverPath,
    required this.sourceProvider,
    required this.sourceRef,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? author;
  final String? coverPath;
  final String sourceProvider;
  final String sourceRef;
  final DateTime createdAt;

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverPath,
    String? sourceProvider,
    String? sourceRef,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.coverPath == coverPath &&
        other.sourceProvider == sourceProvider &&
        other.sourceRef == sourceRef &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        author,
        coverPath,
        sourceProvider,
        sourceRef,
        createdAt,
      );
}
