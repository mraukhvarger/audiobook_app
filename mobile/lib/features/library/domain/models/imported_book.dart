import 'book.dart';
import 'track.dart';

class ImportedBook {
  const ImportedBook({required this.book, required this.tracks});

  final Book book;
  final List<Track> tracks;

  int get totalDurationMs =>
      tracks.fold(0, (sum, track) => sum + track.durationMs);

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);
}
