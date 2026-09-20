import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../../../../core/logging/app_log_level.dart';
import '../../../../core/logging/log_entry.dart';
import '../providers/log_providers.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(logEntriesProvider);
    final level = ref.watch(logDisplayLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.logsRefresh,
            onPressed: () => ref.invalidate(logEntriesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.logsClear,
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(l10n.logsLevelLabel),
                const SizedBox(width: 12),
                DropdownButton<AppLogLevel>(
                  value: level,
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(logDisplayLevelProvider.notifier).state = value;
                  },
                  items: [
                    for (final option in AppLogLevel.values)
                      DropdownMenuItem(
                        value: option,
                        child: Text(_levelLabel(l10n, option)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(l10n.errorWithMessage('$error'))),
              data: (items) {
                final visible = [
                  for (final entry in items.reversed)
                    if (level.includes(entry.level)) entry,
                ];
                if (visible.isEmpty) {
                  return Center(child: Text(l10n.logsEmpty));
                }
                return ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _LogTile(entry: visible[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _levelLabel(AppLocalizations l10n, AppLogLevel level) {
    return switch (level) {
      AppLogLevel.debug => l10n.logsLevelDebug,
      AppLogLevel.info => l10n.logsLevelInfo,
      AppLogLevel.error => l10n.logsLevelError,
    };
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logsClearTitle),
        content: Text(l10n.logsClearMessage),
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
    await ref.read(appLoggerProvider).clear();
    ref.invalidate(logEntriesProvider);
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.level) {
      AppLogLevel.debug => Theme.of(context).colorScheme.outline,
      AppLogLevel.info => Theme.of(context).colorScheme.primary,
      AppLogLevel.error => Theme.of(context).colorScheme.error,
    };
    final details = entry.error;
    return ListTile(
      dense: true,
      leading: Text(
        entry.level.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
      title: Text(entry.message),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(entry.time),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (details != null)
            Text(
              details,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    final millis = time.millisecond.toString().padLeft(3, '0');
    return '${two(time.day)}.${two(time.month)}.${time.year} '
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}.$millis';
  }
}
