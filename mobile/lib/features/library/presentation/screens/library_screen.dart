import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../domain/errors.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_summary.dart';
import '../format_duration.dart';
import '../providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(libraryBookSummariesProvider);
    final hasBooks = summaries.valueOrNull?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_outlined),
            tooltip: l10n.storageTitle,
            onPressed: () => context.push('/storage'),
          ),
        ],
      ),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: '$error'),
        data: (items) => items.isEmpty
            ? _EmptyState(onImport: () => _importBook(context, ref))
            : _BookList(
                items: items,
                onDelete: (book) => _confirmDelete(context, ref, book),
              ),
      ),
      floatingActionButton: hasBooks
          ? FloatingActionButton.extended(
              onPressed: () => _importBook(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.add),
            )
          : null,
    );
  }
}

Future<void> _importBook(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final picker = ref.read(folderPickerProvider);
  if (picker == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.folderPickerAndroidOnly)),
    );
    return;
  }

  final folder = await picker.pickFolder();
  if (folder == null || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ImportDialog(),
  );

  final import = ref.read(importBookFromFolderProvider);
  final repository = ref.read(libraryRepositoryProvider);

  try {
    final imported = await import(
      folderRef: folder.ref,
      folderName: folder.name.isEmpty ? l10n.untitled : folder.name,
    );
    await repository.saveImportedBook(imported);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ref.invalidate(libraryBookSummariesProvider);
    ref.invalidate(libraryBooksProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.addedBook(imported.book.title))),
    );
  } on NoAudioFilesException {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.importNoAudioFiles)),
    );
  } catch (error) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.importFailed('$error'))),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteBookTitle),
      content: Text(l10n.deleteBookMessage(book.title)),
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
  await ref.read(libraryRepositoryProvider).deleteBook(book.id);
  ref.invalidate(libraryBookSummariesProvider);
  ref.invalidate(libraryBooksProvider);
}

class _BookList extends StatelessWidget {
  const _BookList({required this.items, required this.onDelete});

  final List<BookSummary> items;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final summary = items[index];
        return BookListTile(
          summary: summary,
          onDelete: () => onDelete(summary.book),
        );
      },
    );
  }
}

class BookListTile extends StatelessWidget {
  const BookListTile(
      {super.key, required this.summary, required this.onDelete});

  final BookSummary summary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = summary.book;
    final author = book.author;
    return ListTile(
      leading: _Cover(path: book.coverPath),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author == null
                ? formatDuration(l10n, summary.totalDuration)
                : '$author · ${formatDuration(l10n, summary.totalDuration)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: summary.progress, minHeight: 3),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
        ],
      ),
      onTap: () => context.push('/book/${book.id}'),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 48,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_books_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.libraryEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.libraryEmptyHint, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add),
              label: Text(l10n.addBook),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDialog extends StatelessWidget {
  const _ImportDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(child: Text(l10n.importingBook)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.errorWithMessage(message),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
