# Player Book — mobile

Flutter-приложение для прослушивания аудиокниг.

## Статус каркаса

Проект сгенерирован: есть `android/`, `.metadata`, зависимости зафиксированы в `pubspec.lock`.
Проверено: `flutter analyze` без замечаний, `flutter build apk --debug` собирается, APK
устанавливается и запускается на эмуляторе `pixel8`.

## Запуск

```powershell
cd mobile
flutter emulators --launch pixel8   # или подключить телефон по USB
flutter run
```

## Зависимости

- `just_audio`, `just_audio_background`, `audio_session` — воспроизведение и фоновый сервис
- `flutter_riverpod` — состояние
- `go_router` — навигация
- `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` — хранение
- `sensors_plus` — встряхивание для sleep timer
- `google_sign_in`, `googleapis` — Google Drive

## Структура

```
lib/
  app/                 # точка входа, роутинг, тема
  core/                # конфиг, DI, утилиты
  features/
    library/           # библиотека и импорт книг
    player/            # воспроизведение, таймлайн, sleep timer
    storage/           # StorageProvider, Google Drive, кэш
    settings/          # настройки
```

## Android

Для фонового воспроизведения (Android 14+):
- foreground service type `mediaPlayback`;
- разрешение `POST_NOTIFICATIONS`;
- доступ к выбранным папкам через SAF.

Для Google Drive — проект в Google Cloud Console, экран согласия OAuth в режиме Testing,
scope `drive.readonly`, OAuth client для Android (см. `openspec/changes/add-storage-providers/design.md`).
