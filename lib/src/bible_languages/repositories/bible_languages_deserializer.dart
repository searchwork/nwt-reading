import 'dart:convert';

import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';

class BibleLanguagesDeserializer {
  BibleLanguages convertJsonToBibleLanguages(String json) {
    final bibleLanguagesMap = jsonDecode(json);
    final bibleLanguages = Map<String, BibleLanguage>.from(
        bibleLanguagesMap.map((bibleLanguageKey, bibleLanguageMap) => MapEntry(
            bibleLanguageKey, _convertMapToBibleLanguage(bibleLanguageMap))));

    return BibleLanguages(bibleLanguages);
  }

  BibleLanguage _convertMapToBibleLanguage(
      Map<String, dynamic> bibleLanguageMap) {
    final name = bibleLanguageMap['name'] as String;
    final urlPath = bibleLanguageMap['urlPath'] as String;
    final books = List<Book>.from(
        bibleLanguageMap['books'].map((bookMap) => _convertMapToBook(bookMap)));

    return BibleLanguage(name: name, urlPath: urlPath, books: books);
  }

  Book _convertMapToBook(Map<String, dynamic> bookMap) {
    final name = bookMap['name'] as String;
    final urlSegment = bookMap['urlSegment'] as String;

    return Book(
      name: name,
      urlSegment: urlSegment,
    );
  }
}
