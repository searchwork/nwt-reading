import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';

Future<IncompleteNotifierTester<BibleLanguages>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester = IncompleteNotifierTester<BibleLanguages>(
      bibleLanguagesNotifier,
      overrides: [
        sharedPreferencesRepository.overrideWith((ref) => sharedPreferences),
      ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<BibleLanguages>();
  const testBibleLanguage = BibleLanguage(
      name: 'English',
      wtCode: 'E',
      urlPath: '/en/library/bible/study-bible/books/',
      books: [
        Book(name: 'Genesis', urlSegment: 'genesis'),
        Book(name: 'Exodus', urlSegment: 'exodus'),
        Book(name: 'Leviticus', urlSegment: 'leviticus'),
        Book(name: 'Numbers', urlSegment: 'numbers'),
        Book(name: 'Deuteronomy', urlSegment: 'deuteronomy'),
        Book(name: 'Joshua', urlSegment: 'joshua'),
        Book(name: 'Judges', urlSegment: 'judges'),
        Book(name: 'Ruth', urlSegment: 'ruth'),
        Book(name: '1 Samuel', urlSegment: '1-samuel'),
        Book(name: '2 Samuel', urlSegment: '2-samuel'),
        Book(name: '1 Kings', urlSegment: '1-kings'),
        Book(name: '2 Kings', urlSegment: '2-kings'),
        Book(name: '1 Chronicles', urlSegment: '1-chronicles'),
        Book(name: '2 Chronicles', urlSegment: '2-chronicles'),
        Book(name: 'Ezra', urlSegment: 'ezra'),
        Book(name: 'Nehemiah', urlSegment: 'nehemiah'),
        Book(name: 'Esther', urlSegment: 'esther'),
        Book(name: 'Job', urlSegment: 'job'),
        Book(name: 'Psalm', urlSegment: 'psalms'),
        Book(name: 'Proverbs', urlSegment: 'proverbs'),
        Book(name: 'Ecclesiastes', urlSegment: 'ecclesiastes'),
        Book(name: 'Song of Solomon', urlSegment: 'song-of-solomon'),
        Book(name: 'Isaiah', urlSegment: 'isaiah'),
        Book(name: 'Jeremiah', urlSegment: 'jeremiah'),
        Book(name: 'Lamentations', urlSegment: 'lamentations'),
        Book(name: 'Ezekiel', urlSegment: 'ezekiel'),
        Book(name: 'Daniel', urlSegment: 'daniel'),
        Book(name: 'Hosea', urlSegment: 'hosea'),
        Book(name: 'Joel', urlSegment: 'joel'),
        Book(name: 'Amos', urlSegment: 'amos'),
        Book(name: 'Obadiah', urlSegment: 'obadiah'),
        Book(name: 'Jonah', urlSegment: 'jonah'),
        Book(name: 'Micah', urlSegment: 'micah'),
        Book(name: 'Nahum', urlSegment: 'nahum'),
        Book(name: 'Habakkuk', urlSegment: 'habakkuk'),
        Book(name: 'Zephaniah', urlSegment: 'zephaniah'),
        Book(name: 'Haggai', urlSegment: 'haggai'),
        Book(name: 'Zechariah', urlSegment: 'zechariah'),
        Book(name: 'Malachi', urlSegment: 'malachi'),
        Book(name: 'Matthew', urlSegment: 'matthew'),
        Book(name: 'Mark', urlSegment: 'mark'),
        Book(name: 'Luke', urlSegment: 'luke'),
        Book(name: 'John', urlSegment: 'john'),
        Book(name: 'Acts', urlSegment: 'acts'),
        Book(name: 'Romans', urlSegment: 'romans'),
        Book(name: '1 Corinthians', urlSegment: '1-corinthians'),
        Book(name: '2 Corinthians', urlSegment: '2-corinthians'),
        Book(name: 'Galatians', urlSegment: 'galatians'),
        Book(name: 'Ephesians', urlSegment: 'ephesians'),
        Book(name: 'Philippians', urlSegment: 'philippians'),
        Book(name: 'Colossians', urlSegment: 'colossians'),
        Book(name: '1 Thessalonians', urlSegment: '1-thessalonians'),
        Book(name: '2 Thessalonians', urlSegment: '2-thessalonians'),
        Book(name: '1 Timothy', urlSegment: '1-timothy'),
        Book(name: '2 Timothy', urlSegment: '2-timothy'),
        Book(name: 'Titus', urlSegment: 'titus'),
        Book(name: 'Philemon', urlSegment: 'philemon'),
        Book(name: 'Hebrews', urlSegment: 'hebrews'),
        Book(name: 'James', urlSegment: 'james'),
        Book(name: '1 Peter', urlSegment: '1-peter'),
        Book(name: '2 Peter', urlSegment: '2-peter'),
        Book(name: '1 John', urlSegment: '1-john'),
        Book(name: '2 John', urlSegment: '2-john'),
        Book(name: '3 John', urlSegment: '3-john'),
        Book(name: 'Jude', urlSegment: 'jude'),
        Book(name: 'Revelation', urlSegment: 'revelation')
      ]);
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    final tester = await getTester();

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to the asset', () async {
    final tester = await getTester();
    tester.container.read(bibleLanguagesRepository);
    final result = await tester.container.read(bibleLanguagesNotifier.future);

    expect(result.bibleLanguages.length, greaterThanOrEqualTo(192));
    expect(deepCollectionEquals(result.bibleLanguages['en'], testBibleLanguage),
        true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () =>
          tester.listener(asyncLoadingValue, AsyncData<BibleLanguages>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });
}
