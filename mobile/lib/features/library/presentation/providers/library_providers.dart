import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/database/library_dao.dart';
import '../../data/repositories/drift_library_repository.dart';
import '../../data/sources/local_file_audio_source.dart';
import '../../data/sources/saf_audio_source.dart';
import '../../domain/audio/audio_source.dart';
import '../../domain/audio/folder_picker.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_summary.dart';
import '../../domain/models/track.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/import_book_from_folder.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return DriftLibraryRepository(LibraryDao(ref.watch(appDatabaseProvider)));
});

final folderPickerProvider = Provider<FolderPicker?>((ref) {
  if (Platform.isAndroid) return const SafAudioSource();
  return null;
});

final audioSourceProvider = Provider<AudioSource>((ref) {
  if (Platform.isAndroid) return const SafAudioSource();
  return const LocalFileAudioSource();
});

final importBookFromFolderProvider = Provider<ImportBookFromFolder>((ref) {
  return ImportBookFromFolder(audioSource: ref.watch(audioSourceProvider));
});

final libraryBookSummariesProvider = FutureProvider<List<BookSummary>>((ref) {
  return ref.watch(libraryRepositoryProvider).getBookSummaries();
});

final libraryBooksProvider = FutureProvider<List<Book>>((ref) {
  return ref.watch(libraryRepositoryProvider).getBooks();
});

final bookProvider = FutureProvider.family<Book?, String>((ref, id) async {
  final books = await ref.watch(libraryBooksProvider.future);
  for (final book in books) {
    if (book.id == id) return book;
  }
  return null;
});

final bookSummaryProvider =
    FutureProvider.family<BookSummary?, String>((ref, id) async {
  final summaries = await ref.watch(libraryBookSummariesProvider.future);
  for (final summary in summaries) {
    if (summary.book.id == id) return summary;
  }
  return null;
});

final bookTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, id) {
  return ref.watch(libraryRepositoryProvider).getTracks(id);
});
