import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/domains/incomplete_notifier.dart';

final bibleLanguagesProvider =
    AsyncNotifierProvider<IncompleteNotifier<BibleLanguages>, BibleLanguages>(
        IncompleteNotifier.new,
        name: 'bibleLanguages');

class BibleLanguages {
  BibleLanguages({required this.bibleLanguages});

  final Map<BibleLanguageCode, BibleLanguage> bibleLanguages;

  int get length => bibleLanguages.keys.length;

  Iterable<BibleLanguageCode> get keys => bibleLanguages.keys;
}

typedef BibleLanguageCode = String;

class BibleLanguage {
  BibleLanguage(
      {required this.name, required this.urlPath, required this.books});

  final String name;
  final String urlPath;
  final List<Book> books;
}

class Book {
  Book({required this.name, required this.urlSegment});

  final String name;
  final String urlSegment;
}
