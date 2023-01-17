import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/domains/bible_languages.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_deserializer.dart';

final bibleLanguagesRepositoryProvider = Provider<BibleLanguagesRepository>(
    (ref) => BibleLanguagesRepository(ref),
    name: 'bibleLanguagesRepository');

class BibleLanguagesRepository {
  BibleLanguagesRepository(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() async {
    _setBibleLanguagesFromJsonFiles();
  }

  void _setBibleLanguagesFromJsonFiles() async {
    final json =
        await rootBundle.loadString('assets/repositories/bible_languages.json');
    final bibleLanguages =
        BibleLanguagesDeserializer().convertJsonToBibleLanguages(json);
    ref.read(bibleLanguagesProvider.notifier).init(bibleLanguages);
  }
}
