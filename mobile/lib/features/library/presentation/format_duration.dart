String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '$hours ч $minutes мин';
  }
  return '$minutes мин';
}
