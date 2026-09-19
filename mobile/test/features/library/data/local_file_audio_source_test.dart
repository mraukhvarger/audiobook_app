import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:player_book/features/library/data/sources/local_file_audio_source.dart';
import 'package:player_book/features/library/domain/usecases/import_book_from_folder.dart';

import '../support/fake_audio_source.dart';

void main() {
  group('LocalFileAudioSource', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('player_book_test');
    });

    tearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    test('lists only supported audio files', () async {
      for (final name in ['1book.mp3', 'cover.jpg', 'notes.txt']) {
        await File(p.join(directory.path, name)).writeAsBytes([0, 1, 2]);
      }

      final files =
          await const LocalFileAudioSource().listAudioFiles(directory.path);

      expect(files.map((f) => f.fileName), ['1book.mp3']);
      expect(files.single.sizeBytes, 3);
    });

    test('imports real files 1book, 2book, 11book in natural order', () async {
      for (final name in ['11book.mp3', '1book.mp3', '2book.mp3']) {
        await File(p.join(directory.path, name)).writeAsBytes([0]);
      }

      final import = ImportBookFromFolder(
        audioSource: const LocalFileAudioSource(),
        idGenerator: sequentialIds(),
      );
      final result =
          await import(folderRef: directory.path, folderName: 'Book');

      expect(
        result.tracks.map((track) => track.fileName),
        ['1book.mp3', '2book.mp3', '11book.mp3'],
      );
    });

    test('throws when folder does not exist', () async {
      final missing = p.join(directory.path, 'missing');
      expect(
        () => const LocalFileAudioSource().listAudioFiles(missing),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
