# AGENTS.md

## Repository layout
- `mobile/` — Flutter-приложение (Android, позже iOS).
- `server/` — будущая серверная часть (фаза 4, заглушка).
- `openspec/` — спеки и change proposals (источник правды).

## OpenSpec workflow
- `openspec/project.md` — стек, архитектура, конвенции.
- `openspec/specs/<capability>/spec.md` — текущее зафиксированное поведение.
- `openspec/changes/<change-id>/` — предлагаемые изменения: `proposal.md`, `tasks.md`, `design.md`, `specs/<capability>/spec.md`.
- `openspec/archive/` — завершённые изменения.
- Новое поведение описывается change proposal'ом и только потом реализуется.

## Commands
```powershell
# mobile
cd mobile
flutter pub get
flutter run
flutter test
flutter analyze
dart format lib test
```

## Environment
- Flutter SDK: `C:\Users\jerde\Documents\flutter` (в User PATH, нужен новый терминал).
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`, `ANDROID_HOME` задан. JDK — встроенный JBR из Android Studio (настроен через `flutter config --jdk-dir`).
- Эмулятор: AVD `pixel8` (Android 37.0, google_apis, x86_64).
- `mobile/` содержит сгенерированную папку `android/`. iOS не настроен (Windows).
- В Android SDK 37 устаревший `sdkmanager.bat` крэшится (0xC0000409) при авто-установке компонентов; используй новый CLI: `android sdk install <pkg>`.
