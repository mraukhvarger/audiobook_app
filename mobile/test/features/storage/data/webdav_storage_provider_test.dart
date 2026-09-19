import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/storage/data/webdav/webdav_config.dart';
import 'package:player_book/features/storage/data/webdav/webdav_storage_provider.dart';
import 'package:player_book/features/storage/domain/models/remote_entry.dart';
import 'package:player_book/features/storage/domain/storage_provider.dart';

import '../support/fakes.dart';

void main() {
  WebDavConfig config() => WebDavConfig(
        baseUrl: Uri.parse('https://webdav.yandex.ru'),
        username: 'user',
        password: 'pass',
      );

  test('connect pings the server and marks the provider connected', () async {
    final client = FakeWebDavClientAdapter();
    final provider = WebDavStorageProvider(config(), client: client);

    await provider.connect();

    expect(provider.isConnected, isTrue);
    expect(provider.providerId, 'webdav');
  });

  test('disconnect closes the underlying client', () async {
    final client = FakeWebDavClientAdapter();
    final provider = WebDavStorageProvider(config(), client: client);

    await provider.connect();
    await provider.disconnect();

    expect(provider.isConnected, isFalse);
    expect(client.closed, isTrue);
  });

  test('propagates authorization errors from connect', () async {
    final client = FakeWebDavClientAdapter(
      pingError: const StorageAuthException(),
    );
    final provider = WebDavStorageProvider(config(), client: client);

    expect(provider.connect, throwsA(isA<StorageAuthException>()));
  });

  test('lists entries from the requested folder', () async {
    const entry = RemoteEntry(
      ref: '/books/a.mp3',
      name: 'a.mp3',
      isFolder: false,
      sizeBytes: 42,
    );
    final client = FakeWebDavClientAdapter(dir: {
      '/books': [entry]
    });
    final provider = WebDavStorageProvider(config(), client: client);

    final entries = await provider.listEntries('/books');

    expect(entries, [entry]);
    expect(client.dirCalls, ['/books']);
  });

  test('builds an encoded absolute uri for a ref', () {
    final provider = WebDavStorageProvider(
      config(),
      client: FakeWebDavClientAdapter(),
    );

    final uri = provider.uriFor('/Книги/01 книга.mp3');

    expect(
      uri,
      Uri.parse('https://webdav.yandex.ru')
          .replace(pathSegments: ['Книги', '01 книга.mp3']),
    );
    expect(uri.toString(), contains('%'));
  });

  test('exposes basic authorization headers', () {
    final provider = WebDavStorageProvider(
      config(),
      client: FakeWebDavClientAdapter(),
    );

    expect(provider.authHeaders['Authorization'], 'Basic dXNlcjpwYXNz');
  });
}
