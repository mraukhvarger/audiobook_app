import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/audio/natural_sort.dart';

void main() {
  group('naturalCompare', () {
    test('sorts numeric prefixes by value, not lexicographically', () {
      final names = ['11book.mp3', '1book.mp3', '2book.mp3'];
      names.sort(naturalCompare);
      expect(names, ['1book.mp3', '2book.mp3', '11book.mp3']);
    });

    test('orders the classic 1, 2, 10 example', () {
      final names = ['10.mp3', '2.mp3', '1.mp3'];
      names.sort(naturalCompare);
      expect(names, ['1.mp3', '2.mp3', '10.mp3']);
    });

    test('handles zero-padded numbers', () {
      final names = ['003.mp3', '01.mp3', '002.mp3'];
      names.sort(naturalCompare);
      expect(names, ['01.mp3', '002.mp3', '003.mp3']);
    });

    test('same numeric prefix falls back to name order', () {
      final names = ['1b.mp3', '1a.mp3'];
      names.sort(naturalCompare);
      expect(names, ['1a.mp3', '1b.mp3']);
    });

    test('equal numeric value is deterministic regardless of padding', () {
      final names = ['01.mp3', '1.mp3'];
      names.sort(naturalCompare);
      expect(names, ['01.mp3', '1.mp3']);
    });

    test('numbers are compared before letters', () {
      expect(naturalCompare('2b.mp3', 'b2.mp3'), lessThan(0));
    });

    test('compares multi-segment names', () {
      final names = ['1-10.mp3', '1-2.mp3', '1-1.mp3'];
      names.sort(naturalCompare);
      expect(names, ['1-1.mp3', '1-2.mp3', '1-10.mp3']);
    });

    test('returns zero for identical strings', () {
      expect(naturalCompare('1book.mp3', '1book.mp3'), 0);
    });
  });
}
