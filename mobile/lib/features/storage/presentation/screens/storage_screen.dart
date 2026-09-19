import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';

import '../providers/storage_providers.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final controller = ref.read(storageConnectionControllerProvider);
    await controller.load();
    final connection = controller.connection;
    if (connection == null || !mounted) return;
    _urlController.text = connection.baseUrl.toString();
    _usernameController.text = connection.username;
    _passwordController.text = connection.password;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(storageConnectionControllerProvider);
    final connected = controller.isConnected;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(
                connected ? Icons.cloud_done : Icons.cloud_off,
                color: connected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Text(
                connected ? l10n.storageConnected : l10n.storageNotConnected,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            enabled: !connected,
            decoration: InputDecoration(
              labelText: l10n.storageUrlLabel,
              hintText: 'https://webdav.yandex.ru',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            enabled: !connected,
            decoration: InputDecoration(
              labelText: l10n.storageUsernameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            enabled: !connected,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.storagePasswordLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 16),
            Text(
              controller.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          if (connected)
            FilledButton.icon(
              onPressed: () => context.push('/storage/browse'),
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.storageBrowse),
            ),
          if (connected) const SizedBox(height: 12),
          if (connected)
            OutlinedButton.icon(
              onPressed: controller.connecting ? null : _disconnect,
              icon: const Icon(Icons.logout),
              label: Text(l10n.storageDisconnect),
            )
          else
            FilledButton.icon(
              onPressed: controller.connecting ? null : _connect,
              icon: controller.connecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(l10n.storageConnect),
            ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final rawUrl = _urlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (rawUrl.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.storageUrlRequired)));
      return;
    }
    if (username.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageCredentialsRequired)),
      );
      return;
    }
    final baseUrl = Uri.tryParse(rawUrl);
    if (baseUrl == null || !baseUrl.hasScheme) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.storageUrlRequired)));
      return;
    }
    final controller = ref.read(storageConnectionControllerProvider);
    final ok = await controller.connect(
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    if (!mounted) return;
    if (ok) {
      ref.invalidate(storageConnectionProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageConnectedSuccess)),
      );
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(storageConnectionControllerProvider);
    await controller.disconnect();
    ref.invalidate(storageConnectionProvider);
    if (!mounted) return;
    _passwordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.storageDisconnected)),
    );
  }
}
