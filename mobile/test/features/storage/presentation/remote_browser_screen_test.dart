import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/storage/domain/models/remote_entry.dart';
import 'package:player_book/features/storage/presentation/providers/storage_providers.dart';
import 'package:player_book/features/storage/presentation/screens/remote_browser_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  final provider = FakeStorageProvider(
    entries: const {
      '/': [
        RemoteEntry(ref: '/Книги', name: 'Книги', isFolder: true),
        RemoteEntry(ref: '/readme.txt', name: 'readme.txt', isFolder: false),
      ],
      '/Книги': [
        RemoteEntry(ref: '/Книги/Книга', name: 'Книга', isFolder: true),
      ],
    },
  );

  Widget wrap() {
    return ProviderScope(
      overrides: [
        activeStorageProviderProvider.overrideWithValue(provider),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RemoteBrowserScreen(),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('lists folders and files from the root', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    expect(find.text('Книги'), findsOneWidget);
    expect(find.text('readme.txt'), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.text('Импортировать папку'), findsNothing);
  });

  testWidgets('opens a folder and shows the import action', (tester) async {
    await tester.pumpWidget(wrap());
    await settle(tester);

    await tester.tap(find.text('Книги'));
    await settle(tester);

    expect(find.text('Книга'), findsOneWidget);
    expect(find.text('Импортировать папку'), findsOneWidget);
    expect(provider.listCalls, contains('/Книги'));
  });
}
