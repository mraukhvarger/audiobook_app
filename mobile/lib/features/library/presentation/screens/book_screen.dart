import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/book.dart';
import '../../domain/models/track.dart';
import '../format_duration.dart';
import '../providers/library_providers.dart';

class BookScreen extends ConsumerWidget {
  const BookScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    final tracks = ref.watch(bookTracksProvider(bookId));
    final summary = ref.watch(bookSummaryProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад в библиотеку',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(book.valueOrNull?.title ?? 'Книга'),
      ),
      body: book.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Книга не найдена'));
          }
          return tracks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Ошибка: $error')),
            data: (trackList) => _BookDetails(
              book: value,
              tracks: trackList,
              progress: summary.valueOrNull?.progress ?? 0,
            ),
          );
        },
      ),
    );
  }
}

class _BookDetails extends StatelessWidget {
  const _BookDetails({
    required this.book,
    required this.tracks,
    required this.progress,
  });

  final Book book;
  final List<Track> tracks;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final total = Duration(
      milliseconds: tracks.fold(0, (sum, track) => sum + track.durationMs),
    );
    final author = book.author;
    final started = progress > 0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(child: _BigCover(path: book.coverPath)),
        const SizedBox(height: 24),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (author != null) ...[
          const SizedBox(height: 8),
          Text(
            author,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          '${tracks.length} треков · ${formatDuration(total)}',
          textAlign: TextAlign.center,
        ),
        if (started) ...[
          const SizedBox(height: 24),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            'Прослушано ${(progress * 100).round()}%',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.push('/book/${book.id}/player'),
          icon: const Icon(Icons.play_arrow),
          label: Text(started ? 'Продолжить' : 'Слушать'),
        ),
      ],
    );
  }
}

class _BigCover extends StatelessWidget {
  const _BigCover({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book, size: 64),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 180,
        height: 180,
        child: path == null
            ? placeholder
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}
