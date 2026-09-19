import '../models/book_position.dart';

class BookTimeline {
  BookTimeline(List<int> trackDurationsMs)
      : _durations = List.unmodifiable(
          trackDurationsMs.map((duration) => duration < 0 ? 0 : duration),
        ) {
    var cursor = 0;
    final starts = <int>[];
    for (final duration in _durations) {
      starts.add(cursor);
      cursor += duration;
    }
    _starts = List.unmodifiable(starts);
  }

  final List<int> _durations;
  late final List<int> _starts;

  int get trackCount => _durations.length;

  List<int> get trackDurationsMs => _durations;

  bool get isEmpty => _durations.isEmpty;

  int get totalDurationMs =>
      _durations.isEmpty ? 0 : _starts.last + _durations.last;

  int toTotalMs(BookPosition position) {
    if (_durations.isEmpty) return 0;
    final index = position.trackIndex.clamp(0, _durations.length - 1);
    final offset = position.offsetMs.clamp(0, _durations[index]);
    return _starts[index] + offset;
  }

  BookPosition fromTotalMs(int totalMs) {
    if (_durations.isEmpty) return BookPosition.zero;
    final total = totalDurationMs;
    final clamped = totalMs.clamp(0, total);
    if (clamped >= total) {
      final last = _durations.length - 1;
      return BookPosition(trackIndex: last, offsetMs: _durations[last]);
    }
    for (var index = _durations.length - 1; index >= 0; index--) {
      if (clamped >= _starts[index]) {
        return BookPosition(
          trackIndex: index,
          offsetMs: clamped - _starts[index],
        );
      }
    }
    return BookPosition.zero;
  }

  double progressAt(BookPosition position) {
    final total = totalDurationMs;
    if (total == 0) return 0;
    return (toTotalMs(position) / total).clamp(0.0, 1.0);
  }
}
