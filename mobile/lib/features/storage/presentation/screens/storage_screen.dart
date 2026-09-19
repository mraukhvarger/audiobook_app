import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:player_book/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/storage_connection.dart';
import '../providers/storage_providers.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  static const String yandexWebDavUrl = 'https://webdav.yandex.ru';
  static const String webdavHelpUrl =
      'https://yandex.ru/support/yandex-360/customers/disk/web/ru/webdav';
  static const String appPasswordUrl =
      'https://id.yandex.ru/security/app-passwords';

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  final _urlController = TextEditingController(
    text: StorageScreen.yandexWebDavUrl,
  );
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _providerId = StorageConnection.webDavProviderId;

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
    setState(() => _providerId = connection.providerId);
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
          DropdownButtonFormField<String>(
            initialValue: _providerId,
            decoration: InputDecoration(
              labelText: l10n.storageProviderLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: StorageConnection.webDavProviderId,
                child: Text(l10n.storageProviderYandex),
              ),
            ],
            onChanged: connected
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _providerId = value;
                      _urlController.text = StorageScreen.yandexWebDavUrl;
                    });
                  },
          ),
          if (!connected) ...[
            const SizedBox(height: 8),
            Text(
              l10n.storageDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            enabled: !connected,
            decoration: InputDecoration(
              labelText: l10n.storageUrlLabel,
              hintText: StorageScreen.yandexWebDavUrl,
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
          if (!connected) ...[
            const SizedBox(height: 16),
            Text(
              l10n.storageHelpSectionTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            _HelpLink(
              label: l10n.storageHelpWebdav,
              onPressed: () => _openLink(StorageScreen.webdavHelpUrl),
            ),
            _HelpLink(
              label: l10n.storageHelpAppPassword,
              onPressed: () => _openLink(StorageScreen.appPasswordUrl),
            ),
          ],
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

  Future<void> _openLink(String url) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // Fall through to the message below.
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.storageLinkFailed)));
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

class _HelpLink extends StatelessWidget {
  const _HelpLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
