import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/library/presentation/screens/book_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/player/presentation/screens/player_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        name: 'book',
        builder: (context, state) => BookScreen(
          bookId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'player',
            name: 'player',
            builder: (context, state) => PlayerScreen(
              bookId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});
