import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/domain/audio/audio_file_ref.dart';
import 'package:player_book/features/library/domain/audio/audio_metadata.dart';
import 'package:player_book/features/library/domain/errors.dart';
import 'package:player_book/features/library/domain/usecases/import_book_from_folder.dart';

import '../support/fake_audio_source.dart';

void main() {
  group('ImportBookFromFolder', () {
    test('sorts 1book, 2book, 11book in natural order', () async {
      final source = FakeAudioSource([
        const AudioFileRef(ref: '/b/11book.mp3', fileName: '11book.mp3'),
        const AudioFileRef(ref: '/b/1book.mp3', fileName: '1book.mp3'),
        const AudioFileRef(ref: '/b/2book.mp3', fileName: '2book.mp3'),
      ]);

      final import = ImportBookFromFolder(
        audioSource: source,
        idGenerator: sequentialIds(),
      );
      final result = await import(folderRef: '/b', folderName: 'My Book');

      expect(
        result.tracks.map((track) => track.fileName),
        ['1book.mp3', '2book.mp3', '11book.mp3'],
      );
      expect(result.tracks.map((track) => track.order), [0, 1, 2]);
    });

    test('filters out non-audio files', () async {
      final source = FakeAudioSource([
        const AudioFileRef(ref: '/b/1.mp3', fileName: '1.mp3'),
        const AudioFileRef(ref: '/b/cover.jpg', fileName: 'cover.jpg'),
        const AudioFileRef(ref: '/b/notes.txt', fileName: 'notes.txt'),
      ]);

      final import = ImportBookFromFolder(
        audioSource: source,
        idGenerator: sequentialIds(),
      );
      final result = await import(folderRef: '/b', folderName: 'Book');

      expect(result.tracks.map((track) => track.fileName), ['1.mp3']);
    });

    test('throws when folder has no audio files', () async {
      final source = FakeAudioSource([
        const AudioFileRef(ref: '/b/cover.jpg', fileName: 'cover.jpg'),
      ]);

      final import = ImportBookFromFolder(audioSource: source);

      expect(
        () => import(folderRef: '/b', folderName: 'Book'),
        throwsA(isA<NoAudioFilesException>()),
      );
    });

    test('sums track durations into total duration', () async {
      final source = FakeAudioSource(
        [
          const AudioFileRef(ref: '/b/1.mp3', fileName: '1.mp3'),
          const AudioFileRef(ref: '/b/2.mp3', fileName: '2.mp3'),
        ],
        durations: {
          '1.mp3': const Duration(minutes: 10),
          '2.mp3': const Duration(minutes: 20),
        },
      );

      final import = ImportBookFromFolder(
        audioSource: source,
        idGenerator: sequentialIds(),
      );
      final result = await import(folderRef: '/b', folderName: 'Book');

      expect(result.totalDuration, const Duration(minutes: 30));
      expect(result.tracks.first.duration, const Duration(minutes: 10));
    });

    test('falls back to folder name when no tags are present', () async {
      final source = FakeAudioSource([
        const AudioFileRef(ref: '/b/1.mp3', fileName: '1.mp3', sizeBytes: 512),
      ]);

      final import = ImportBookFromFolder(
        audioSource: source,
        idGenerator: sequentialIds(),
      );
      final result = await import(folderRef: '/b', folderName: 'Folder Name');

      expect(result.book.title, 'Folder Name');
      expect(result.book.author, isNull);
      expect(result.book.sourceProvider, localSourceProvider);
      expect(result.book.sourceRef, '/b');
      expect(result.tracks.single.sizeBytes, 512);
    });

    test('uses tags from the first matching audio file', () async {
      final source = FakeAudioSource(
        [const AudioFileRef(ref: '/b/1.mp3', fileName: '1.mp3')],
        metadata: const AudioMetadata(
          title: 'Tagged Title',
          author: 'Tagged Author',
        ),
      );

      final import = ImportBookFromFolder(
        audioSource: source,
        idGenerator: sequentialIds(),
      );
      final result = await import(folderRef: '/b', folderName: 'Folder Name');

      expect(result.book.title, 'Tagged Title');
      expect(result.book.author, 'Tagged Author');
    });

    test('stores the provided source provider', () async {
      final source = FakeAudioSource([
        const AudioFileRef(ref: '/b/1.mp3', fileName: '1.mp3'),
      ]);

      final import = ImportBookFromFolder(
        audioSource: source,
        sourceProvider: 'webdav',
        idGenerator: sequentialIds(),
      );
      final result =
          await import(folderRef: '/remote/book', folderName: 'Book');

      expect(result.book.sourceProvider, 'webdav');
      expect(result.book.sourceRef, '/remote/book');
    });
  });
}
