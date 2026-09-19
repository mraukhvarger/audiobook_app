import 'book_position.dart';

class PlaybackProgress {
  const PlaybackProgress({
    required this.bookId,
    required this.position,
    required this.updatedAt,
    this.completed = false,
  });

  final String bookId;
  final BookPosition position;
  final DateTime updatedAt;
  final bool completed;

  PlaybackProgress copyWith({
    BookPosition? position,
    DateTime? updatedAt,
    bool? completed,
  }) {
    return PlaybackProgress(
      bookId: bookId,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlaybackProgress &&
        other.bookId == bookId &&
        other.position == position &&
        other.updatedAt == updatedAt &&
        other.completed == completed;
  }

  @override
  int get hashCode => Object.hash(bookId, position, updatedAt, completed);
}
