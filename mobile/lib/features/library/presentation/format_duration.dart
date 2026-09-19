import 'package:player_book/l10n/generated/app_localizations.dart';

String formatDuration(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return l10n.durationHoursMinutes(hours, minutes);
  }
  return l10n.durationMinutes(minutes);
}
