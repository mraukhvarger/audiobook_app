import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../../storage/domain/cache/audio_cache.dart';
import '../../../storage/presentation/controllers/book_cache_controller.dart';
import '../../../storage/presentation/providers/storage_providers.dart';
import '../../domain/models/book.dart';
import '../../domain/models/track.dart';
import '../format_duration.dart';
import '../providers/library_providers.dart';

class BookScreen extends ConsumerWidget {
  const BookScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(bookProvider(bookId));
    final tracks = ref.watch(bookTracksProvider(bookId));
    final summary = ref.watch(bookSummaryProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.backToLibrary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(book.valueOrNull?.title ?? l10n.bookFallback),
      ),
      body: book.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.errorWithMessage('$error'))),
        data: (value) {
          if (value == null) {
            return Center(child: Text(l10n.bookNotFound));
          }
          return tracks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text(l10n.errorWithMessage('$error'))),
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

class _BookDetails extends ConsumerWidget {
  const _BookDetails({
    required this.book,
    required this.tracks,
    required this.progress,
  });

  final Book book;
  final List<Track> tracks;
  final double progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
          l10n.bookTracksCount(tracks.length, formatDuration(l10n, total)),
          textAlign: TextAlign.center,
        ),
        if (started) ...[
          const SizedBox(height: 24),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            l10n.listenedPercent((progress * 100).round()),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.push('/book/${book.id}/player'),
          icon: const Icon(Icons.play_arrow),
          label: Text(started ? l10n.continueListening : l10n.listen),
        ),
        if (book.sourceProvider != 'local') ...[
          const SizedBox(height: 24),
          _CacheSection(book: book, tracks: tracks),
        ],
      ],
    );
  }
}

class _CacheSection extends ConsumerWidget {
  const _CacheSection({required this.book, required this.tracks});

  final Book book;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(bookCacheStatusProvider(book.id));
    final controller = ref.watch(bookCacheControllerProvider(book.id));
    final cached = status.valueOrNull == CacheStatus.cached;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              cached ? Icons.offline_pin : Icons.cloud_download_outlined,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _statusLabel(l10n, status.valueOrNull ?? CacheStatus.none),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (controller.busy) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: controller.progress?.fraction),
          const SizedBox(height: 8),
          Text(
            l10n.cacheDownloading(
              ((controller.progress?.fraction ?? 0) * 100).round(),
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (controller.error != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        if (cached)
          OutlinedButton.icon(
            onPressed: controller.busy ? null : () => _clear(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.cacheClear),
          )
        else
          OutlinedButton.icon(
            onPressed: controller.busy
                ? null
                : () => _download(context, ref, controller),
            icon: const Icon(Icons.download),
            label: Text(l10n.cacheDownload),
          ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, CacheStatus status) {
    return switch (status) {
      CacheStatus.cached => l10n.cacheCached,
      CacheStatus.partial => l10n.cachePartial,
      CacheStatus.downloading => l10n.cacheDownloading(0),
      CacheStatus.none => l10n.cacheNone,
    };
  }

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    BookCacheController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await controller.download(book, tracks);
    ref.invalidate(bookCacheStatusProvider(book.id));
    ref.invalidate(bookTracksProvider(book.id));
    if (controller.error == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cacheDownloaded)),
      );
    }
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cacheClearTitle),
        content: Text(l10n.cacheClearMessage(book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final controller = ref.read(bookCacheControllerProvider(book.id));
    await controller.clear();
    ref.invalidate(bookCacheStatusProvider(book.id));
    ref.invalidate(bookTracksProvider(book.id));
    if (controller.error == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
    }
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
