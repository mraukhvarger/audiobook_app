import 'book.dart';

class BookSummary {
  const BookSummary({
    required this.book,
    required this.totalDurationMs,
    this.progress = 0,
  });

  final Book book;
  final int totalDurationMs;
  final double progress;

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);
}
