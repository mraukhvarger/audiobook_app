import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Book'**
  String get appTitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @folderPickerAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Folder selection is only available on Android'**
  String get folderPickerAndroidOnly;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @addedBook.
  ///
  /// In en, this message translates to:
  /// **'Added: {title}'**
  String addedBook(String title);

  /// No description provided for @importNoAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'No supported audio files found in the selected folder'**
  String get importNoAudioFiles;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @deleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete book?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from the library. The original files will remain on the device.'**
  String deleteBookMessage(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Library is empty'**
  String get libraryEmpty;

  /// No description provided for @libraryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a folder with an audiobook'**
  String get libraryEmptyHint;

  /// No description provided for @importingBook.
  ///
  /// In en, this message translates to:
  /// **'Importing book...'**
  String get importingBook;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @backToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Back to library'**
  String get backToLibrary;

  /// No description provided for @bookFallback.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookFallback;

  /// No description provided for @bookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get bookNotFound;

  /// No description provided for @bookTracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks · {duration}'**
  String bookTracksCount(int count, String duration);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @listenedPercent.
  ///
  /// In en, this message translates to:
  /// **'Listened {percent}%'**
  String listenedPercent(int percent);

  /// No description provided for @continueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueListening;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @playerFallback.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerFallback;

  /// No description provided for @playbackSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get playbackSettingsTitle;

  /// No description provided for @trackOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Track {current} of {total}'**
  String trackOfTotal(int current, int total);

  /// No description provided for @skipBackSeconds.
  ///
  /// In en, this message translates to:
  /// **'−{seconds}s'**
  String skipBackSeconds(int seconds);

  /// No description provided for @skipForwardSeconds.
  ///
  /// In en, this message translates to:
  /// **'+{seconds}s'**
  String skipForwardSeconds(int seconds);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed {speed}x'**
  String playbackSpeed(String speed);

  /// No description provided for @sleepRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sleep {time}'**
  String sleepRemaining(String time);

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepRemainingLeft.
  ///
  /// In en, this message translates to:
  /// **'Remaining {time}'**
  String sleepRemainingLeft(String time);

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @durationMinutesEllipsis.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min…'**
  String durationMinutesEllipsis(int minutes);

  /// No description provided for @shakeReaction.
  ///
  /// In en, this message translates to:
  /// **'Shake response'**
  String get shakeReaction;

  /// No description provided for @sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get sensitivity;

  /// No description provided for @sensitivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get sensitivityLow;

  /// No description provided for @sensitivityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sensitivityMedium;

  /// No description provided for @sensitivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get sensitivityHigh;

  /// No description provided for @simulateShakeDebug.
  ///
  /// In en, this message translates to:
  /// **'Simulate shake (debug)'**
  String get simulateShakeDebug;

  /// No description provided for @timerDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer duration'**
  String get timerDurationTitle;

  /// No description provided for @minutesSuffix.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesSuffix;

  /// No description provided for @sleepTimerRange.
  ///
  /// In en, this message translates to:
  /// **'From 1 to 480 minutes'**
  String get sleepTimerRange;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @volumePercent.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent}'**
  String volumePercent(String percent);

  /// No description provided for @volumePercentBoost.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent} +{db} dB'**
  String volumePercentBoost(String percent, int db);

  /// No description provided for @volumeBoost.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get volumeBoost;

  /// No description provided for @boostDb.
  ///
  /// In en, this message translates to:
  /// **'+{db} dB'**
  String boostDb(int db);

  /// No description provided for @boostOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get boostOff;

  /// No description provided for @boostOffShort.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get boostOffShort;

  /// No description provided for @boostWarning.
  ///
  /// In en, this message translates to:
  /// **'Boosting quiet recordings may distort loud material'**
  String get boostWarning;

  /// No description provided for @resetVolumeBoost.
  ///
  /// In en, this message translates to:
  /// **'Reset volume and boost'**
  String get resetVolumeBoost;

  /// No description provided for @shakeToExtend.
  ///
  /// In en, this message translates to:
  /// **'Shake your phone to extend'**
  String get shakeToExtend;

  /// No description provided for @playbackStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start playback'**
  String get playbackStartFailed;

  /// No description provided for @playbackTrackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to play the track, skipping to the next one'**
  String get playbackTrackFailed;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @skipInterval.
  ///
  /// In en, this message translates to:
  /// **'Skip interval'**
  String get skipInterval;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsShort(int seconds);

  /// No description provided for @autoRewind.
  ///
  /// In en, this message translates to:
  /// **'Auto-rewind on resume'**
  String get autoRewind;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// No description provided for @storageProviderWebDav.
  ///
  /// In en, this message translates to:
  /// **'WebDAV (Yandex.Disk)'**
  String get storageProviderWebDav;

  /// No description provided for @storageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get storageUrlLabel;

  /// No description provided for @storageUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get storageUsernameLabel;

  /// No description provided for @storagePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'App password'**
  String get storagePasswordLabel;

  /// No description provided for @storageConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get storageConnect;

  /// No description provided for @storageDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get storageDisconnect;

  /// No description provided for @storageConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get storageConnected;

  /// No description provided for @storageNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get storageNotConnected;

  /// No description provided for @storageConnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Storage connected'**
  String get storageConnectedSuccess;

  /// No description provided for @storageDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Storage disconnected'**
  String get storageDisconnected;

  /// No description provided for @storageUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the server address'**
  String get storageUrlRequired;

  /// No description provided for @storageCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter login and password'**
  String get storageCredentialsRequired;

  /// No description provided for @storageBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse storage'**
  String get storageBrowse;

  /// No description provided for @storageEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty'**
  String get storageEmptyFolder;

  /// No description provided for @remoteImportFolder.
  ///
  /// In en, this message translates to:
  /// **'Import folder'**
  String get remoteImportFolder;

  /// No description provided for @remoteLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contents: {error}'**
  String remoteLoadFailed(String error);

  /// No description provided for @remoteImportNoAudio.
  ///
  /// In en, this message translates to:
  /// **'No supported audio files in this folder'**
  String get remoteImportNoAudio;

  /// No description provided for @cacheNone.
  ///
  /// In en, this message translates to:
  /// **'Network required'**
  String get cacheNone;

  /// No description provided for @cachePartial.
  ///
  /// In en, this message translates to:
  /// **'Partially offline'**
  String get cachePartial;

  /// No description provided for @cacheCached.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get cacheCached;

  /// No description provided for @cacheDownload.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get cacheDownload;

  /// No description provided for @cacheDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String cacheDownloading(int percent);

  /// No description provided for @cacheClear.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get cacheClear;

  /// No description provided for @cacheClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove download?'**
  String get cacheClearTitle;

  /// No description provided for @cacheClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Local copies of \"{title}\" will be removed. The book stays in the library.'**
  String cacheClearMessage(String title);

  /// No description provided for @cacheDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Book is available offline'**
  String get cacheDownloaded;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Download removed'**
  String get cacheCleared;

  /// No description provided for @storageProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get storageProviderLabel;

  /// No description provided for @storageProviderYandex.
  ///
  /// In en, this message translates to:
  /// **'Yandex Disk (WebDAV)'**
  String get storageProviderYandex;

  /// No description provided for @storageDescription.
  ///
  /// In en, this message translates to:
  /// **'The cloud is connected over WebDAV. Yandex Disk requires an app password, not your Yandex ID password.'**
  String get storageDescription;

  /// No description provided for @storageHelpSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get storageHelpSectionTitle;

  /// No description provided for @storageHelpWebdav.
  ///
  /// In en, this message translates to:
  /// **'How to set up WebDAV in Yandex Disk'**
  String get storageHelpWebdav;

  /// No description provided for @storageHelpAppPassword.
  ///
  /// In en, this message translates to:
  /// **'Create an app password'**
  String get storageHelpAppPassword;

  /// No description provided for @storageLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get storageLinkFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
