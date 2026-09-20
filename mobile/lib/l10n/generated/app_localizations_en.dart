// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Player Book';

  @override
  String get libraryTitle => 'Library';

  @override
  String get add => 'Add';

  @override
  String get addBook => 'Add book';

  @override
  String get folderPickerAndroidOnly =>
      'Folder selection is only available on Android';

  @override
  String get untitled => 'Untitled';

  @override
  String addedBook(String title) {
    return 'Added: $title';
  }

  @override
  String get importNoAudioFiles =>
      'No supported audio files found in the selected folder';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get deleteBookTitle => 'Delete book?';

  @override
  String deleteBookMessage(String title) {
    return '\"$title\" will be removed from the library. The original files will remain on the device.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get libraryEmpty => 'Library is empty';

  @override
  String get libraryEmptyHint => 'Add a folder with an audiobook';

  @override
  String get importingBook => 'Importing book...';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get backToLibrary => 'Back to library';

  @override
  String get bookFallback => 'Book';

  @override
  String get bookNotFound => 'Book not found';

  @override
  String bookTracksCount(int count, String duration) {
    return '$count tracks · $duration';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String listenedPercent(int percent) {
    return 'Listened $percent%';
  }

  @override
  String get continueListening => 'Continue';

  @override
  String get listen => 'Listen';

  @override
  String get back => 'Back';

  @override
  String get playerFallback => 'Player';

  @override
  String get playbackSettingsTitle => 'Playback settings';

  @override
  String trackOfTotal(int current, int total) {
    return 'Track $current of $total';
  }

  @override
  String skipBackSeconds(int seconds) {
    return '−${seconds}s';
  }

  @override
  String skipForwardSeconds(int seconds) {
    return '+${seconds}s';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String playbackSpeed(String speed) {
    return 'Speed ${speed}x';
  }

  @override
  String sleepRemaining(String time) {
    return 'Sleep $time';
  }

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String sleepRemainingLeft(String time) {
    return 'Remaining $time';
  }

  @override
  String get durationLabel => 'Duration';

  @override
  String durationMinutesEllipsis(int minutes) {
    return '$minutes min…';
  }

  @override
  String get shakeReaction => 'Shake response';

  @override
  String get sensitivity => 'Sensitivity';

  @override
  String get sensitivityLow => 'Low';

  @override
  String get sensitivityMedium => 'Medium';

  @override
  String get sensitivityHigh => 'High';

  @override
  String get simulateShakeDebug => 'Simulate shake (debug)';

  @override
  String get timerDurationTitle => 'Timer duration';

  @override
  String get minutesSuffix => 'min';

  @override
  String get sleepTimerRange => 'From 1 to 480 minutes';

  @override
  String get save => 'Save';

  @override
  String get volume => 'Volume';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String volumePercent(String percent) {
    return 'Volume $percent';
  }

  @override
  String volumePercentBoost(String percent, int db) {
    return 'Volume $percent +$db dB';
  }

  @override
  String get volumeBoost => 'Boost';

  @override
  String boostDb(int db) {
    return '+$db dB';
  }

  @override
  String get boostOff => 'off';

  @override
  String get boostOffShort => 'off';

  @override
  String get boostWarning =>
      'Boosting quiet recordings may distort loud material';

  @override
  String get resetVolumeBoost => 'Reset volume and boost';

  @override
  String get shakeToExtend => 'Shake your phone to extend';

  @override
  String get playbackStartFailed => 'Failed to start playback';

  @override
  String get playbackTrackFailed =>
      'Failed to play the track, skipping to the next one';

  @override
  String get speed => 'Speed';

  @override
  String get skipInterval => 'Skip interval';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get autoRewind => 'Auto-rewind on resume';

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageProviderWebDav => 'WebDAV (Yandex.Disk)';

  @override
  String get storageUrlLabel => 'Server address';

  @override
  String get storageUsernameLabel => 'Login';

  @override
  String get storagePasswordLabel => 'App password';

  @override
  String get storageConnect => 'Connect';

  @override
  String get storageDisconnect => 'Disconnect';

  @override
  String get storageConnected => 'Connected';

  @override
  String get storageNotConnected => 'Not connected';

  @override
  String get storageConnectedSuccess => 'Storage connected';

  @override
  String get storageDisconnected => 'Storage disconnected';

  @override
  String get storageUrlRequired => 'Enter the server address';

  @override
  String get storageCredentialsRequired => 'Enter login and password';

  @override
  String get storageBrowse => 'Browse storage';

  @override
  String get storageEmptyFolder => 'Folder is empty';

  @override
  String get remoteImportFolder => 'Import folder';

  @override
  String remoteLoadFailed(String error) {
    return 'Failed to load contents: $error';
  }

  @override
  String get remoteImportNoAudio => 'No supported audio files in this folder';

  @override
  String get cacheNone => 'Network required';

  @override
  String get cachePartial => 'Partially offline';

  @override
  String get cacheCached => 'Available offline';

  @override
  String get cacheDownload => 'Download for offline';

  @override
  String cacheDownloading(int percent) {
    return 'Downloading $percent%';
  }

  @override
  String get cacheClear => 'Remove download';

  @override
  String get cacheClearTitle => 'Remove download?';

  @override
  String cacheClearMessage(String title) {
    return 'Local copies of \"$title\" will be removed. The book stays in the library.';
  }

  @override
  String get cacheDownloaded => 'Book is available offline';

  @override
  String get cacheCleared => 'Download removed';

  @override
  String get storageProviderLabel => 'Provider';

  @override
  String get storageProviderYandex => 'Yandex Disk (WebDAV)';

  @override
  String get storageDescription =>
      'The cloud is connected over WebDAV. Yandex Disk requires an app password, not your Yandex ID password.';

  @override
  String get storageHelpSectionTitle => 'Help';

  @override
  String get storageHelpWebdav => 'How to set up WebDAV in Yandex Disk';

  @override
  String get storageHelpAppPassword => 'Create an app password';

  @override
  String get storageLinkFailed => 'Could not open the link';

  @override
  String get logsTitle => 'Logs';

  @override
  String get logsRefresh => 'Refresh';

  @override
  String get logsClear => 'Clear';

  @override
  String get logsClearTitle => 'Clear the log?';

  @override
  String get logsClearMessage => 'All saved log entries will be removed.';

  @override
  String get logsLevelLabel => 'Level';

  @override
  String get logsLevelDebug => 'Debug';

  @override
  String get logsLevelInfo => 'Info';

  @override
  String get logsLevelError => 'Error';

  @override
  String get logsEmpty => 'No entries';
}
