import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_book/features/storage/data/media/android_media_probe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.playerbook/media_probe');
  const probe = AndroidMediaProbe();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockHandler(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('maps duration response', () async {
    mockHandler((call) async {
      expect(call.method, 'duration');
      expect(call.arguments, {
        'uri': 'https://webdav.example.ru/book/1.mp3',
        'headers': {'Authorization': 'Basic x'},
      });
      return 123000;
    });

    final duration = await probe.probeDuration(
      Uri.parse('https://webdav.example.ru/book/1.mp3'),
      {'Authorization': 'Basic x'},
    );

    expect(duration, const Duration(milliseconds: 123000));
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

    final metadata = await probe.readMetadata(
      Uri.parse('https://webdav.example.ru/book/1.mp3'),
      {'Authorization': 'Basic x'},
    );

    expect(metadata!.title, 'Tagged');
    expect(metadata.author, 'Author');
    expect(metadata.coverPath, '/cache/cover.jpg');
  });

  test('returns zero duration on missing result', () async {
    mockHandler((call) async => null);

    final duration = await probe.probeDuration(
      Uri.parse('https://webdav.example.ru/book/1.mp3'),
      const {},
    );

    expect(duration, Duration.zero);
  });
}
