# Tasks: add-webdav-storage

## 1. Abstraction
- [x] 1.1 Интерфейс `StorageProvider` (auth, listEntries, getMetadata, openStream, download).
- [x] 1.2 Модель `RemoteEntry` (ref, name, isFolder, size, modifiedAt, mimeType).
- [x] 1.3 Реестр провайдеров и выбор активного; конфигурация подключения.
- [x] 1.4 Ошибки/исключения провайдера (сеть, авторизация, не найдено).

## 2. WebDAV (Яндекс.Диск)
- [x] 2.1 Клиент WebDAV поверх `webdav_client`: PROPFIND Depth:1, разбор `207`, кодировки имён.
- [x] 2.2 Basic-auth (логин + пароль приложения), проверка соединения.
- [x] 2.3 Стриминг с Range и скачивание файла с прогрессом.
- [x] 2.4 Ретраи/таймауты и понятные ошибки (401 → «проверьте пароль приложения»).

## 3. Import
- [x] 3.1 `WebDavAudioSource implements AudioSource`: список аудио, фильтр, сортировка.
- [x] 3.2 Длительность и метаданные через `MediaMetadataRetriever.setDataSource(url, headers)` + fallback.
- [x] 3.3 Импорт книги из удалённой папки, запись `sourceProvider`/`sourceRef` в `Book`/`Track`.
- [x] 3.4 Обложка из метаданных (кэш в каталог приложения).

## 4. Playback & cache
- [x] 4.1 Выбор источника: кэш → облако.
- [x] 4.2 Стриминг трека через `just_audio` с заголовком авторизации.
- [x] 4.3 Скачивание книги в кэш с прогрессом, докачка по Range.
- [x] 4.4 Очистка кэша (по книге/полностью), лимит размера и вытеснение.
- [x] 4.5 Статус кэша в UI (доступно офлайн / скачивается / нужна сеть).

## 5. Data / schema
- [x] 5.1 Миграция drift: `Book.sourceProvider/sourceRef`, `Track.sourceProvider/sourceRef/cachePath`.
- [x] 5.2 Таблица индекса кэша (bookId, trackId, path, size, lastPlayedAt).
- [x] 5.3 Хранение учётных данных: `flutter_secure_storage` для пароля, настройки — для URL/логина.

## 6. UI
- [x] 6.1 Экран подключения хранилища (URL, логин, пароль; вход/выход, статус).
- [x] 6.2 Обзор удалённых папок и импорт книги.
- [x] 6.3 Индикатор загрузки/кэша книги.

## 7. Tests
- [x] 7.1 Unit: маппинг ответа WebDAV-клиента в `RemoteEntry`.
- [x] 7.2 Unit: фильтр и естественная сортировка удалённых аудио.
- [x] 7.3 Unit: `StorageProvider` на фейковом провайдере (импорт end-to-end без сети).
- [x] 7.4 Unit: выбор источника (кэш vs облако) и логика очистки.
- [x] 7.5 Widget: экран подключения и список удалённых папок (mocked).
