import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/player/domain/models/book_position.dart';
import 'package:player_book/features/player/domain/timeline/book_timeline.dart';

void main() {
  const tenMinutes = 10 * 60 * 1000;

  group('BookTimeline', () {
    final timeline = BookTimeline(const [tenMinutes, tenMinutes]);

    test('total duration is the sum of tracks', () {
      expect(timeline.totalDurationMs, 20 * 60 * 1000);
    });

    test('maps a book position to a total position', () {
      expect(
        timeline.toTotalMs(
          const BookPosition(trackIndex: 1, offsetMs: 5 * 60 * 1000),
        ),
        15 * 60 * 1000,
      );
    });

    test('maps total to track and offset', () {
      expect(
        timeline.fromTotalMs(15 * 60 * 1000),
        const BookPosition(trackIndex: 1, offsetMs: 5 * 60 * 1000),
      );
    });

    test('round-trips arbitrary positions', () {
      for (final total in [
        0,
        1000,
        9 * 60 * 1000,
        10 * 60 * 1000,
        19 * 60 * 1000
      ]) {
        final position = timeline.fromTotalMs(total);
        expect(timeline.toTotalMs(position), total);
      }
    });

    test('clamps positions past the end to the last track end', () {
      expect(
        timeline.fromTotalMs(999 * 60 * 1000),
        const BookPosition(trackIndex: 1, offsetMs: tenMinutes),
      );
    });

    test('clamps negative positions to zero', () {
      expect(timeline.fromTotalMs(-5000), BookPosition.zero);
      expect(
        timeline.toTotalMs(const BookPosition(trackIndex: 0, offsetMs: -5)),
        0,
      );
    });

    test('seek across the boundary lands at the start of the next track', () {
      expect(
        timeline.fromTotalMs(10 * 60 * 1000),
        const BookPosition(trackIndex: 1, offsetMs: 0),
      );
    });

    test('seek backwards across the boundary lands in the previous track', () {
      expect(
        timeline.fromTotalMs(10 * 60 * 1000 - 1),
        const BookPosition(trackIndex: 0, offsetMs: 10 * 60 * 1000 - 1),
      );
    });

    test('handles empty timeline', () {
      final empty = BookTimeline(const []);
      expect(empty.totalDurationMs, 0);
      expect(empty.fromTotalMs(100), BookPosition.zero);
      expect(
          empty.toTotalMs(const BookPosition(trackIndex: 3, offsetMs: 5)), 0);
    });

    test('treats negative durations as zero', () {
      final timeline = BookTimeline(const [-100, 1000]);
      expect(timeline.totalDurationMs, 1000);
      expect(
        timeline.fromTotalMs(0),
        const BookPosition(trackIndex: 1, offsetMs: 0),
      );
    });

    test('progress fraction is bounded', () {
      expect(
        timeline.progressAt(const BookPosition(trackIndex: 0, offsetMs: 0)),
        0,
      );
      expect(
        timeline.progressAt(const BookPosition(trackIndex: 1, offsetMs: 0)),
        0.5,
      );
      expect(
        timeline.progressAt(
            const BookPosition(trackIndex: 1, offsetMs: tenMinutes)),
        1,
      );
    });
  });
}
