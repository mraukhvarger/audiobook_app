import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/library/data/sources/saf_audio_source.dart';
import 'package:player_book/features/library/domain/audio/audio_file_ref.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.playerbook/audio_source');
  const source = SafAudioSource();
  const file = AudioFileRef(ref: 'content://doc/1', fileName: '1book.mp3');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockHandler(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('maps listFiles response to AudioFileRef list', () async {
    mockHandler((call) async {
      expect(call.method, 'listFiles');
      expect(call.arguments, {'uri': 'content://tree/book'});
      return [
        {'uri': 'content://doc/1', 'name': '1book.mp3', 'size': 12},
        {'uri': 'content://doc/2', 'name': 'cover.jpg', 'size': 34},
      ];
    });

    final files = await source.listAudioFiles('content://tree/book');

    expect(files, hasLength(2));
    expect(files.first.ref, 'content://doc/1');
    expect(files.first.fileName, '1book.mp3');
    expect(files.first.sizeBytes, 12);
  });

  test('maps pickFolder result', () async {
    mockHandler((call) async {
      expect(call.method, 'pickFolder');
      return {'uri': 'content://tree/book', 'name': 'My Book'};
    });

    final folder = await source.pickFolder();

    expect(folder, isNotNull);
    expect(folder!.ref, 'content://tree/book');
    expect(folder.name, 'My Book');
  });

  test('returns null when folder picking is cancelled', () async {
    mockHandler((call) async => null);

    expect(await source.pickFolder(), isNull);
  });

  test('maps duration to Duration', () async {
    mockHandler((call) async {
      expect(call.method, 'duration');
      expect(call.arguments, {'uri': 'content://doc/1'});
      return 90000;
    });

    expect(
      await source.probeDuration(file),
      const Duration(milliseconds: 90000),
    );
  });

  test('maps metadata response', () async {
    mockHandler((call) async {
      expect(call.method, 'metadata');
      return {
        'title': 'Tagged',
        'author': 'Author',
        'coverPath': '/cache/cover.jpg',
      };
    });

    final metadata = await source.readMetadata(file);

    expect(metadata!.title, 'Tagged');
    expect(metadata.author, 'Author');
    expect(metadata.coverPath, '/cache/cover.jpg');
  });

  test('returns null metadata when channel returns null', () async {
    mockHandler((call) async => null);

    expect(await source.readMetadata(file), isNull);
  });
}
