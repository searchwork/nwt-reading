import 'dart:convert';

import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';

class BibleLanguagesDeserializer {
  BibleLanguages convertJsonToBibleLanguages(String json) {
    final bibleLanguagesMap = jsonDecode(json) as Map<String, dynamic>;
    final bibleLanguages = Map<String, BibleLanguage>.from(
        bibleLanguagesMap.map((bibleLanguageKey, bibleLanguageMap) => MapEntry(
            bibleLanguageKey,
            _convertMapToBibleLanguage(
                bibleLanguageMap as Map<String, dynamic>))));

    return BibleLanguages(bibleLanguages);
  }

  BibleLanguage _convertMapToBibleLanguage(
      Map<String, dynamic> bibleLanguageMap) {
    final name = bibleLanguageMap['name'] as String;
    final wtCode = bibleLanguageMap['wtCode'] as String;
    final urlPath = bibleLanguageMap['urlPath'] as String;
    final books = List<Book>.from((bibleLanguageMap['books'] as List<dynamic>)
        .map((bookMap) => _convertMapToBook(bookMap as Map<String, dynamic>)));

    return BibleLanguage(
        name: name, wtCode: wtCode, urlPath: urlPath, books: books);
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
