import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/book_summary.dart';
import 'package:player_book/features/library/presentation/providers/library_providers.dart';
import 'package:player_book/features/library/presentation/screens/library_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

Widget _wrap(List<BookSummary> items) {
  return ProviderScope(
    overrides: [
      libraryBookSummariesProvider.overrideWith((ref) async => items),
      folderPickerProvider.overrideWithValue(null),
    ],
    child: const MaterialApp(
      locale: Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LibraryScreen(),
    ),
  );
}

void main() {
  testWidgets('shows empty state when library is empty', (tester) async {
    await tester.pumpWidget(_wrap([]));
    await tester.pumpAndSettle();

    expect(find.text('Библиотека пуста'), findsOneWidget);
    expect(find.text('Добавить книгу'), findsOneWidget);
  });

  testWidgets('renders a book with author and total duration', (tester) async {
    final summary = BookSummary(
      book: Book(
        id: 'book-1',
        title: 'Моя книга',
        author: 'Иван Петров',
        coverPath: null,
        sourceProvider: 'local',
        sourceRef: '/books/my-book',
        createdAt: DateTime(2026, 1, 1),
      ),
      totalDurationMs: const Duration(minutes: 90).inMilliseconds,
    );

    await tester.pumpWidget(_wrap([summary]));
    await tester.pumpAndSettle();

    expect(find.text('Моя книга'), findsOneWidget);
    expect(find.textContaining('Иван Петров'), findsOneWidget);
    expect(find.textContaining('1 ч 30 мин'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
