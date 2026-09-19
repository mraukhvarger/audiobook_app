import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/features/library/domain/models/book.dart';
import 'package:player_book/features/library/domain/models/book_summary.dart';
import 'package:player_book/features/library/domain/models/track.dart';
import 'package:player_book/features/library/presentation/providers/library_providers.dart';
import 'package:player_book/features/library/presentation/screens/book_screen.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

final _book = Book(
  id: 'book-1',
  title: 'Моя книга',
  author: 'Автор',
  coverPath: null,
  sourceProvider: 'local',
  sourceRef: '/books/my-book',
  createdAt: DateTime(2026, 1, 1),
);

const _tracks = [
  Track(
    id: 'track-1',
    bookId: 'book-1',
    order: 0,
    fileName: '1.mp3',
    uri: '/books/my-book/1.mp3',
    durationMs: 60000,
    sizeBytes: 1,
  ),
];

Widget _wrap({BookSummary? summary}) {
  final router = GoRouter(
    initialLocation: '/book/book-1',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Library Home'))),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (_, state) => BookScreen(bookId: state.pathParameters['id']!),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      bookProvider('book-1').overrideWith((ref) async => _book),
      bookTracksProvider('book-1').overrideWith((ref) async => _tracks),
      bookSummaryProvider('book-1').overrideWith((ref) async => summary),
    ],
    child: MaterialApp.router(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('back button returns to the library', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Моя книга'), findsWidgets);
    expect(find.textContaining('1 треков'), findsOneWidget);
    expect(find.byTooltip('Назад в библиотеку'), findsOneWidget);

    await tester.tap(find.byTooltip('Назад в библиотеку'));
    await tester.pumpAndSettle();

    expect(find.text('Library Home'), findsOneWidget);
  });

  testWidgets('offers to continue when progress exists', (tester) async {
    await tester.pumpWidget(
      _wrap(
        summary: BookSummary(
          book: _book,
          totalDurationMs: 60000,
          progress: 0.5,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Продолжить'), findsOneWidget);
    expect(find.text('Прослушано 50%'), findsOneWidget);
  });
}
