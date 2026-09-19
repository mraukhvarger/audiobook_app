import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/models/book_summary.dart';
import 'package:player_book/features/library/presentation/providers/library_providers.dart';
import 'package:player_book/features/library/presentation/screens/library_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

Widget _wrap(Locale locale) {
  return ProviderScope(
    overrides: [
      libraryBookSummariesProvider.overrideWith(
        (ref) async => <BookSummary>[],
      ),
      folderPickerProvider.overrideWithValue(null),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LibraryScreen(),
    ),
  );
}

void main() {
  testWidgets('renders English strings when the locale is en', (tester) async {
    await tester.pumpWidget(_wrap(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Library is empty'), findsOneWidget);
    expect(find.text('Add book'), findsOneWidget);
  });

  testWidgets('renders Russian strings when the locale is ru', (tester) async {
    await tester.pumpWidget(_wrap(const Locale('ru')));
    await tester.pumpAndSettle();

    expect(find.text('Библиотека'), findsOneWidget);
    expect(find.text('Библиотека пуста'), findsOneWidget);
  });
}
