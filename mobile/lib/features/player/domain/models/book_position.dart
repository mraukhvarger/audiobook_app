class BookPosition {
  const BookPosition({required this.trackIndex, required this.offsetMs});

  static const BookPosition zero = BookPosition(trackIndex: 0, offsetMs: 0);

  final int trackIndex;
  final int offsetMs;

  Duration get offset => Duration(milliseconds: offsetMs);

  @override
  bool operator ==(Object other) {
    return other is BookPosition &&
        other.trackIndex == trackIndex &&
        other.offsetMs == offsetMs;
  }

  @override
  int get hashCode => Object.hash(trackIndex, offsetMs);

  @override
  String toString() =>
      'BookPosition(trackIndex: $trackIndex, offsetMs: $offsetMs)';
}
