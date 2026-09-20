// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Player Book';

  @override
  String get libraryTitle => 'Библиотека';

  @override
  String get add => 'Добавить';

  @override
  String get addBook => 'Добавить книгу';

  @override
  String get folderPickerAndroidOnly =>
      'Выбор папки доступен только на Android';

  @override
  String get untitled => 'Без названия';

  @override
  String addedBook(String title) {
    return 'Добавлено: $title';
  }

  @override
  String get importNoAudioFiles =>
      'В выбранной папке нет поддерживаемых аудиофайлов';

  @override
  String importFailed(String error) {
    return 'Не удалось импортировать: $error';
  }

  @override
  String get deleteBookTitle => 'Удалить книгу?';

  @override
  String deleteBookMessage(String title) {
    return '«$title» будет удалена из библиотеки. Исходные файлы останутся на устройстве.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get libraryEmpty => 'Библиотека пуста';

  @override
  String get libraryEmptyHint => 'Добавьте папку с аудиокнигой';

  @override
  String get importingBook => 'Импорт книги...';

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get backToLibrary => 'Назад в библиотеку';

  @override
  String get bookFallback => 'Книга';

  @override
  String get bookNotFound => 'Книга не найдена';

  @override
  String bookTracksCount(int count, String duration) {
    return '$count треков · $duration';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String listenedPercent(int percent) {
    return 'Прослушано $percent%';
  }

  @override
  String get continueListening => 'Продолжить';

  @override
  String get listen => 'Слушать';

  @override
  String get back => 'Назад';

  @override
  String get playerFallback => 'Плеер';

  @override
  String get playbackSettingsTitle => 'Настройки воспроизведения';

  @override
  String trackOfTotal(int current, int total) {
    return 'Трек $current из $total';
  }

  @override
  String skipBackSeconds(int seconds) {
    return '−$secondsс';
  }

  @override
  String skipForwardSeconds(int seconds) {
    return '+$secondsс';
  }

  @override
  String get play => 'Играть';

  @override
  String get pause => 'Пауза';

  @override
  String playbackSpeed(String speed) {
    return 'Скорость ${speed}x';
  }

  @override
  String sleepRemaining(String time) {
    return 'Сон $time';
  }

  @override
  String get sleepTimer => 'Таймер сна';

  @override
  String sleepRemainingLeft(String time) {
    return 'Осталось $time';
  }

  @override
  String get durationLabel => 'Длительность';

  @override
  String durationMinutesEllipsis(int minutes) {
    return '$minutes мин…';
  }

  @override
  String get shakeReaction => 'Реакция на встряхивание';

  @override
  String get sensitivity => 'Чувствительность';

  @override
  String get sensitivityLow => 'Низкая';

  @override
  String get sensitivityMedium => 'Средняя';

  @override
  String get sensitivityHigh => 'Высокая';

  @override
  String get simulateShakeDebug => 'Симулировать встряхивание (debug)';

  @override
  String get timerDurationTitle => 'Длительность таймера';

  @override
  String get minutesSuffix => 'мин';

  @override
  String get sleepTimerRange => 'От 1 до 480 минут';

  @override
  String get save => 'Сохранить';

  @override
  String get volume => 'Громкость';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String volumePercent(String percent) {
    return 'Громкость $percent';
  }

  @override
  String volumePercentBoost(String percent, int db) {
    return 'Громкость $percent +$db дБ';
  }

  @override
  String get volumeBoost => 'Усиление';

  @override
  String boostDb(int db) {
    return '+$db дБ';
  }

  @override
  String get boostOff => 'выключено';

  @override
  String get boostOffShort => 'выкл';

  @override
  String get boostWarning =>
      'Усиление тихих записей может искажать громкий материал';

  @override
  String get resetVolumeBoost => 'Сбросить громкость и усиление';

  @override
  String get shakeToExtend => 'Встряхните телефон, чтобы продлить';

  @override
  String get playbackStartFailed => 'Не удалось запустить воспроизведение';

  @override
  String get playbackTrackFailed =>
      'Не удалось воспроизвести трек, перехожу к следующему';

  @override
  String get speed => 'Скорость';

  @override
  String get skipInterval => 'Интервал перемотки';

  @override
  String secondsShort(int seconds) {
    return '$seconds с';
  }

  @override
  String get autoRewind => 'Автоотмотка при возобновлении';

  @override
  String get storageTitle => 'Хранилище';

  @override
  String get storageProviderWebDav => 'WebDAV (Яндекс.Диск)';

  @override
  String get storageUrlLabel => 'Адрес сервера';

  @override
  String get storageUsernameLabel => 'Логин';

  @override
  String get storagePasswordLabel => 'Пароль приложения';

  @override
  String get storageConnect => 'Подключить';

  @override
  String get storageDisconnect => 'Отключить';

  @override
  String get storageConnected => 'Подключено';

  @override
  String get storageNotConnected => 'Не подключено';

  @override
  String get storageConnectedSuccess => 'Хранилище подключено';

  @override
  String get storageDisconnected => 'Хранилище отключено';

  @override
  String get storageUrlRequired => 'Укажите адрес сервера';

  @override
  String get storageCredentialsRequired => 'Укажите логин и пароль';

  @override
  String get storageBrowse => 'Обзор хранилища';

  @override
  String get storageEmptyFolder => 'Папка пуста';

  @override
  String get remoteImportFolder => 'Импортировать папку';

  @override
  String remoteLoadFailed(String error) {
    return 'Не удалось загрузить содержимое: $error';
  }

  @override
  String get remoteImportNoAudio =>
      'В этой папке нет поддерживаемых аудиофайлов';

  @override
  String get cacheNone => 'Требуется сеть';

  @override
  String get cachePartial => 'Частично офлайн';

  @override
  String get cacheCached => 'Доступно офлайн';

  @override
  String get cacheDownload => 'Скачать для офлайна';

  @override
  String cacheDownloading(int percent) {
    return 'Загрузка $percent%';
  }

  @override
  String get cacheClear => 'Удалить загрузку';

  @override
  String get cacheClearTitle => 'Удалить загрузку?';

  @override
  String cacheClearMessage(String title) {
    return 'Локальные копии «$title» будут удалены. Книга останется в библиотеке.';
  }

  @override
  String get cacheDownloaded => 'Книга доступна офлайн';

  @override
  String get cacheCleared => 'Загрузка удалена';

  @override
  String get storageProviderLabel => 'Провайдер';

  @override
  String get storageProviderYandex => 'Яндекс.Диск (WebDAV)';

  @override
  String get storageDescription =>
      'Облако подключается по протоколу WebDAV. Для Яндекс.Диска нужен пароль приложения, а не пароль Яндекс ID.';

  @override
  String get storageHelpSectionTitle => 'Справка';

  @override
  String get storageHelpWebdav => 'Как настроить WebDAV в Яндекс.Диске';

  @override
  String get storageHelpAppPassword => 'Создать пароль приложения';

  @override
  String get storageLinkFailed => 'Не удалось открыть ссылку';

  @override
  String get logsTitle => 'Логи';

  @override
  String get logsRefresh => 'Обновить';

  @override
  String get logsClear => 'Очистить';

  @override
  String get logsClearTitle => 'Очистить журнал?';

  @override
  String get logsClearMessage =>
      'Все сохранённые записи журнала будут удалены.';

  @override
  String get logsLevelLabel => 'Уровень';

  @override
  String get logsLevelDebug => 'Debug';

  @override
  String get logsLevelInfo => 'Info';

  @override
  String get logsLevelError => 'Ошибка';

  @override
  String get logsEmpty => 'Записей нет';
}
