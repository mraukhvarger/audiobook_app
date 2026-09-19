import 'package:flutter/foundation.dart';

import '../../../../features/library/domain/models/book.dart';
import '../../../../features/library/domain/models/track.dart';
import '../../domain/cache/audio_cache.dart';
import '../../domain/storage_provider.dart';

class BookCacheController extends ChangeNotifier {
  BookCacheController({required this.bookId, required AudioCache cache})
      : _cache = cache;

  final String bookId;
  final AudioCache _cache;

  bool _busy = false;
  CacheProgress? _progress;
  String? _error;

  bool get busy => _busy;

  CacheProgress? get progress => _progress;

  String? get error => _error;

  Future<void> download(Book book, List<Track> tracks) async {
    if (_busy) return;
    _busy = true;
    _progress = CacheProgress(totalTracks: tracks.length);
    _error = null;
    notifyListeners();
    try {
      await _cache.downloadBook(
        book,
        tracks,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );
    } on StorageException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = '$error';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    if (_busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _cache.deleteBook(bookId);
    } on StorageException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = '$error';
    } finally {
      _progress = null;
      _busy = false;
      notifyListeners();
    }
  }
}
