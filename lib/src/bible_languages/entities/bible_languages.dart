import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final bibleLanguagesProvider =
    AsyncNotifierProvider<IncompleteNotifier<BibleLanguages>, BibleLanguages>(
        IncompleteNotifier.new,
        name: 'bibleLanguages');

@immutable
class BibleLanguages {
  const BibleLanguages._internal(this.bibleLanguages);
  factory BibleLanguages(
          Map<BibleLanguageCode, BibleLanguage> bibleLanguages) =>
      BibleLanguages._internal(Map.unmodifiable(bibleLanguages));

  final Map<BibleLanguageCode, BibleLanguage> bibleLanguages;

  int get length => bibleLanguages.keys.length;

  Iterable<BibleLanguageCode> get keys => bibleLanguages.keys;
}

typedef BibleLanguageCode = String;

@immutable
class BibleLanguage {
  const BibleLanguage(
      {required this.name, required this.urlPath, required this.books});

  final String name;
  final String urlPath;
  final List<Book> books;
}

@immutable
class Book {
  const Book({required this.name, required this.urlSegment});

  final String name;
  final String urlSegment;
}
