import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/storage/domain/storage_connection.dart';
import 'package:player_book/features/storage/presentation/providers/storage_providers.dart';
import 'package:player_book/features/storage/presentation/screens/storage_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  Widget wrap({required FakeStorageSettingsRepository repository}) {
    return ProviderScope(
      overrides: [
        storageSettingsRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StorageScreen(),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('shows a saved connection and its credentials', (tester) async {
    final repository = FakeStorageSettingsRepository(
      connection: StorageConnection(
        providerId: StorageConnection.webDavProviderId,
        baseUrl: Uri.parse('https://webdav.yandex.ru'),
        username: 'user',
        password: 'secret',
      ),
    );

    await tester.pumpWidget(wrap(repository: repository));
    await settle(tester);

    expect(find.text('Подключено'), findsOneWidget);
    expect(find.text('https://webdav.yandex.ru'), findsWidgets);
    expect(find.text('user'), findsWidgets);
    expect(find.text('Обзор хранилища'), findsOneWidget);
  });

  testWidgets('disconnecting clears the stored connection', (tester) async {
    final repository = FakeStorageSettingsRepository(
      connection: StorageConnection(
        providerId: StorageConnection.webDavProviderId,
        baseUrl: Uri.parse('https://webdav.yandex.ru'),
        username: 'user',
        password: 'secret',
      ),
    );

    await tester.pumpWidget(wrap(repository: repository));
    await settle(tester);

    await tester.tap(find.text('Отключить'));
    await settle(tester);

    expect(repository.cleared, isTrue);
    expect(find.text('Не подключено'), findsOneWidget);
  });

  testWidgets('requires a server address before connecting', (tester) async {
    final repository = FakeStorageSettingsRepository();

    await tester.pumpWidget(wrap(repository: repository));
    await settle(tester);

    await tester.tap(find.text('Подключить'));
    await settle(tester);

    expect(find.text('Укажите адрес сервера'), findsOneWidget);
  });
}
