import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_deserializer.dart';

final bibleLanguagesRepository = Provider<BibleLanguagesRepository>(
    (ref) => BibleLanguagesRepository(ref),
    name: 'bibleLanguagesRepository');

class BibleLanguagesRepository {
  BibleLanguagesRepository(this.ref) {
    _setBibleLanguagesFromJsonFiles();
  }

  final Ref ref;

  void _setBibleLanguagesFromJsonFiles() async {
    final json =
        await rootBundle.loadString('assets/repositories/bible_languages.json');
    final bibleLanguages =
        BibleLanguagesDeserializer().convertJsonToBibleLanguages(json);
    ref.read(bibleLanguagesNotifier.notifier).init(bibleLanguages);
  }
}
