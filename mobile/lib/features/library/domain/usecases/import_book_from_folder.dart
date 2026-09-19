import '../audio/audio_file_ref.dart';
import '../audio/audio_formats.dart';
import '../audio/audio_metadata.dart';
import '../audio/audio_source.dart';
import '../audio/natural_sort.dart';
import '../errors.dart';
import '../models/book.dart';
import '../models/imported_book.dart';
import '../models/track.dart';

typedef IdGenerator = String Function();

const String localSourceProvider = 'local';

class ImportBookFromFolder {
  ImportBookFromFolder({
    required AudioSource audioSource,
    IdGenerator? idGenerator,
    DateTime Function()? now,
  })  : _audioSource = audioSource,
        _idGenerator = idGenerator ?? _defaultId,
        _now = now ?? DateTime.now;

  final AudioSource _audioSource;
  final IdGenerator _idGenerator;
  final DateTime Function() _now;

  Future<ImportedBook> call({
    required String folderRef,
    required String folderName,
  }) async {
    final files = await _audioSource.listAudioFiles(folderRef);
    final audioFiles = files
        .where((file) => AudioFormats.isSupported(file.fileName))
        .toList()
      ..sort((a, b) => naturalCompare(a.fileName, b.fileName));

    if (audioFiles.isEmpty) {
      throw NoAudioFilesException(folderRef);
    }

    final bookId = _idGenerator();
    final tracks = <Track>[];
    for (var index = 0; index < audioFiles.length; index++) {
      final file = audioFiles[index];
      final duration = await _audioSource.probeDuration(file);
      tracks.add(
        Track(
          id: _idGenerator(),
          bookId: bookId,
          order: index,
          fileName: file.fileName,
          uri: file.ref,
          durationMs: duration.inMilliseconds,
          sizeBytes: file.sizeBytes,
        ),
      );
    }

    final metadata = await _readMetadata(audioFiles);

    final book = Book(
      id: bookId,
      title: metadata?.title ?? folderName,
      author: metadata?.author,
      coverPath: metadata?.coverPath,
      sourceProvider: localSourceProvider,
      sourceRef: folderRef,
      createdAt: _now(),
    );

    return ImportedBook(book: book, tracks: tracks);
  }

  Future<AudioMetadata?> _readMetadata(List<AudioFileRef> files) async {
    for (final file in files) {
      final metadata = await _audioSource.readMetadata(file);
      if (metadata != null && !metadata.isEmpty) return metadata;
    }
    return null;
  }
}

String _defaultId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  _counter = (_counter + 1) & 0xFFFF;
  return '$now-$_counter';
}

int _counter = 0;
