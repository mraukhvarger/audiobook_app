import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/audio/audio_metadata.dart';
import 'package:player_book/features/library/domain/usecases/import_book_from_folder.dart';
import 'package:player_book/features/storage/data/webdav/webdav_audio_source.dart';
import 'package:player_book/features/storage/domain/models/remote_entry.dart';

import '../../library/support/fake_audio_source.dart';
import '../support/fakes.dart';

void main() {
  final entries = {
    '/book': const [
      RemoteEntry(ref: '/book', name: 'book', isFolder: true),
      RemoteEntry(
        ref: '/book/11book.mp3',
        name: '11book.mp3',
        isFolder: false,
        sizeBytes: 30,
      ),
      RemoteEntry(
        ref: '/book/1book.mp3',
        name: '1book.mp3',
        isFolder: false,
        sizeBytes: 10,
      ),
      RemoteEntry(
        ref: '/book/2book.mp3',
        name: '2book.mp3',
        isFolder: false,
        sizeBytes: 20,
      ),
      RemoteEntry(ref: '/book/cover.jpg', name: 'cover.jpg', isFolder: false),
    ],
  };

  test('lists only supported audio files', () async {
    final provider = FakeStorageProvider(entries: entries);
    final source = WebDavAudioSource(
      provider: provider,
      mediaProbe: FakeMediaProbe(),
    );

    final files = await source.listAudioFiles('/book');

    expect(
      files.map((file) => file.fileName),
      ['11book.mp3', '1book.mp3', '2book.mp3'],
    );
    expect(files.first.ref, 'https://webdav.example.ru/book/11book.mp3');
    expect(files.first.sourceRef, '/book/11book.mp3');
    expect(files.first.sizeBytes, 30);
  });

  test('probes duration and metadata with authorization headers', () async {
    final provider = FakeStorageProvider(entries: entries);
    final probe = FakeMediaProbe(
      durations: {'/book/1book.mp3': const Duration(minutes: 5)},
      metadata: const AudioMetadata(title: 'T', author: 'A'),
    );
    final source = WebDavAudioSource(provider: provider, mediaProbe: probe);

    final files = await source.listAudioFiles('/book');
    final file = files.firstWhere((item) => item.fileName == '1book.mp3');
    final duration = await source.probeDuration(file);
    final metadata = await source.readMetadata(file);

    expect(duration, const Duration(minutes: 5));
    expect(metadata?.title, 'T');
    expect(
      probe.durationCalls.first.headers,
      provider.authHeaders,
    );
    expect(probe.metadataCalls.first.headers, provider.authHeaders);
  });

  test('imports a remote book in natural order as webdav source', () async {
    final provider = FakeStorageProvider(entries: entries);
    final source = WebDavAudioSource(
      provider: provider,
      mediaProbe: FakeMediaProbe(
        durations: {
          '/book/1book.mp3': const Duration(minutes: 1),
          '/book/2book.mp3': const Duration(minutes: 2),
          '/book/11book.mp3': const Duration(minutes: 3),
        },
      ),
    );
    final import = ImportBookFromFolder(
      audioSource: source,
      sourceProvider: 'webdav',
      idGenerator: sequentialIds(),
    );

    final result = await import(folderRef: '/book', folderName: 'Книга');

    expect(
      result.tracks.map((track) => track.fileName),
      ['1book.mp3', '2book.mp3', '11book.mp3'],
    );
    expect(result.book.sourceProvider, 'webdav');
    expect(result.book.sourceRef, '/book');
    expect(result.tracks.first.sourceProvider, 'webdav');
    expect(result.tracks.first.sourceRef, '/book/1book.mp3');
    expect(result.totalDuration, const Duration(minutes: 6));
  });
}
