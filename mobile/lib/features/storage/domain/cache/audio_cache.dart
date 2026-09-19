import '../../../library/domain/models/book.dart';
import '../../../library/domain/models/track.dart';

enum CacheStatus { none, downloading, cached, partial }

class CacheProgress {
  const CacheProgress({
    this.completedTracks = 0,
    this.totalTracks = 0,
    this.trackReceivedBytes = 0,
    this.trackTotalBytes = 0,
  });

  final int completedTracks;
  final int totalTracks;
  final int trackReceivedBytes;
  final int trackTotalBytes;

  double get fraction {
    if (totalTracks == 0) return 0;
    final inProgress =
        trackTotalBytes > 0 ? trackReceivedBytes / trackTotalBytes : 0.0;
    return ((completedTracks + inProgress) / totalTracks).clamp(0.0, 1.0);
  }
}

abstract interface class AudioCache {
  Future<Map<String, String>> cachedPaths(String bookId);

  Future<void> downloadBook(
    Book book,
    List<Track> tracks, {
    void Function(CacheProgress progress)? onProgress,
  });

  Future<void> deleteBook(String bookId);

  Future<void> deleteAll();

  Future<int> totalSizeBytes();

  Future<void> enforceLimit(int maxBytes);

  Future<void> markPlayed(String trackId, {DateTime? at});
}
