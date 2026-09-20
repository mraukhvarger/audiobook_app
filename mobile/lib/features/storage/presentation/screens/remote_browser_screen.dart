import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../../library/domain/errors.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../logs/presentation/providers/log_providers.dart';
import '../../domain/models/remote_entry.dart';
import '../../domain/storage_provider.dart';
import '../providers/storage_providers.dart';

class RemoteBrowserScreen extends ConsumerStatefulWidget {
  const RemoteBrowserScreen({super.key});

  @override
  ConsumerState<RemoteBrowserScreen> createState() =>
      _RemoteBrowserScreenState();
}

class _RemoteBrowserScreenState extends ConsumerState<RemoteBrowserScreen> {
  final List<String> _stack = ['/'];

  String get _current => _stack.last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(remoteEntriesProvider(_current));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storageBrowse),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: () {
            if (_stack.length > 1) {
              setState(_stack.removeLast);
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is StorageException
              ? l10n.remoteLoadFailed(error.message)
              : l10n.remoteLoadFailed('$error'),
        ),
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.storageEmptyFolder))
            : _EntryList(entries: items, onFolder: _openFolder),
      ),
      floatingActionButton: _current == '/'
          ? null
          : FloatingActionButton.extended(
              onPressed: _importFolder,
              icon: const Icon(Icons.download),
              label: Text(l10n.remoteImportFolder),
            ),
    );
  }

  void _openFolder(RemoteEntry entry) {
    setState(() => _stack.add(entry.ref));
  }

  Future<void> _importFolder() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final import = ref.read(remoteImportProvider);
    if (import == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.storageNotConnected)));
      return;
    }
    final repository = ref.read(libraryRepositoryProvider);
    final folderName = _folderName(_current, l10n);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ImportDialog(message: l10n.importingBook),
    );
    try {
      final imported = await import(
        folderRef: _current,
        folderName: folderName,
      );
      await repository.saveImportedBook(imported);
      ref.invalidate(libraryBookSummariesProvider);
      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.addedBook(imported.book.title))),
      );
      context.go('/');
    } on NoAudioFilesException {
      ref
          .read(appLoggerProvider)
          .info('Remote import skipped: no audio in $_current');
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.remoteImportNoAudio)),
      );
    } catch (error) {
      ref.read(appLoggerProvider).error('Remote import failed', error: error);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importFailed('$error'))),
      );
    }
  }

  String _folderName(String ref, AppLocalizations l10n) {
    final segments = ref.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return l10n.storageTitle;
    return segments.last;
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries, required this.onFolder});

  final List<RemoteEntry> entries;
  final ValueChanged<RemoteEntry> onFolder;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) {
        if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = sorted[index];
        return ListTile(
          leading: Icon(entry.isFolder ? Icons.folder : Icons.audio_file),
          title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: entry.isFolder ? null : Text(_formatSize(entry.sizeBytes)),
          onTap: entry.isFolder ? () => onFolder(entry) : null,
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(child: Text(message)),
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
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
