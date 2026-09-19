# Tasks: add-audio-limiter

## 1. Domain
- [ ] 1.1 Модель `LimiterSettings` (enabled, ceilingDb, attackMs, releaseMs) с границами и дефолтами.
- [ ] 1.2 Интерфейс `AudioLimiter` (применить/снять, обновить настройки, привязать сессию).
- [ ] 1.3 No-op реализация для платформ/версий без поддержки.

## 2. Platform (Android)
- [ ] 2.1 Kotlin platform channel: `DynamicsProcessing` на переданный audio session id.
- [ ] 2.2 Настройка LIMITER: ceiling, attack, release; приоритет после `LoudnessEnhancer`.
- [ ] 2.3 Переприкрепление при смене audio session id и release при освобождении.
- [ ] 2.4 Проверка поддержки API 28+ и корректный отказ.

## 3. Integration
- [ ] 3.1 Прокинуть session id из `just_audio` в лимитер.
- [ ] 3.2 Связать с boost (`volume-controls`): лимитер активен при включённом лимитере, независимо от boost.
- [ ] 3.3 Сохранение/восстановление настроек (SharedPreferences).

## 4. UI
- [ ] 4.1 В экране настроек воспроизведения: тумблер лимитера и потолок.
- [ ] 4.2 Индикация недоступности на неподдерживаемых устройствах.

## 5. Tests
- [ ] 5.1 Unit: клампы и дефолты `LimiterSettings`.
- [ ] 5.2 Unit: лимитер включается/выключается и получает настройки (fake-канал).
- [ ] 5.3 Unit: при смене session id эффект переприкрепляется.
- [ ] 5.4 Widget: тумблер и настройки в UI.
