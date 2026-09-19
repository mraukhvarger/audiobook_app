import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/errors.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_summary.dart';
import '../format_duration.dart';
import '../providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(libraryBookSummariesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Библиотека')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importBook(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

Future<void> _importBook(BuildContext context, WidgetRef ref) async {
  final picker = ref.read(folderPickerProvider);
  if (picker == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор папки доступен только на Android')),
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
      folderName: folder.name.isEmpty ? 'Без названия' : folder.name,
    );
    await repository.saveImportedBook(imported);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ref.invalidate(libraryBookSummariesProvider);
    ref.invalidate(libraryBooksProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлено: ${imported.book.title}')),
    );
  } on NoAudioFilesException catch (error) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$error')),
    );
  } catch (error) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Не удалось импортировать: $error')),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Удалить книгу?'),
      content: Text(
        '«${book.title}» будет удалена из библиотеки. '
        'Исходные файлы останутся на устройстве.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Удалить'),
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
                ? formatDuration(summary.totalDuration)
                : '$author · ${formatDuration(summary.totalDuration)}',
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
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'delete', child: Text('Удалить')),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_books_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Библиотека пуста',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Добавьте папку с аудиокнигой',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add),
              label: const Text('Добавить книгу'),
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
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(child: Text('Импорт книги...')),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Ошибка: $message', textAlign: TextAlign.center),
      ),
    );
  }
}
