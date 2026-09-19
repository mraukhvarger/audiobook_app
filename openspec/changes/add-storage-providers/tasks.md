# Tasks: add-storage-providers

## 1. Abstraction
> Абстракция (`StorageProvider`, `RemoteEntry`, реестр) введена change'ом `add-webdav-storage` (архив `2026-09-19`).
- [x] 1.1 Интерфейс `StorageProvider` (auth, listFolders, listAudio, metadata, openStream, download).
- [x] 1.2 Модель `RemoteEntry` (id, name, isFolder, size, modifiedAt).
- [x] 1.3 Реестр провайдеров и конфигурация активного провайдера.
- [x] 1.4 Поле `sourceProvider`/`sourceRef` в `Book` и `Track`.

## 2. Google Drive
- [ ] 2.1 Настройка проекта Google Cloud Console, экран согласия, OAuth client ID для Android.
- [ ] 2.2 Авторизация через `google_sign_in` со scope `drive.readonly`.
- [ ] 2.3 Листинг папок и аудиофайлов, метаданные.
- [ ] 2.4 Скачивание и потоковое чтение файлов.
- [ ] 2.5 Обработка истёкших токенов и повторная авторизация.

## 3. Offline cache
> Реализовано в `add-webdav-storage` поверх абстракции `StorageProvider`.
- [x] 3.1 Каталог кэша через `path_provider`.
- [x] 3.2 Скачивание трека книги с прогрессом и возобновлением.
- [x] 3.3 Выбор источника: кэш → облако.
- [x] 3.4 Очистка кэша: по книге, полностью; лимит размера и автоочистка.
- [x] 3.5 Статус кэша (доступно офлайн / скачивается / требуется сеть) в UI.

## 4. UI
> Реализовано в `add-webdav-storage`; переиспользуется для Drive по реестру провайдеров.
- [x] 4.1 Экран подключения и управления хранилищем (вход/выход, статус).
- [x] 4.2 Обзор облачного хранилища и импорт книги.
- [x] 4.3 Экран/индикатор загрузки и кэша книги.

## 5. Tests
- [x] 5.1 Unit: `StorageProvider` на фейковом провайдере.
- [x] 5.2 Unit: выбор источника (кэш vs облако) и логика очистки.
- [ ] 5.3 Integration: цикл авторизации Drive (mocked).
