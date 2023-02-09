import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/repositories/events_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';

Future<IncompleteNotifierTester<Events>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester = IncompleteNotifierTester<Events>(eventsNotifier, overrides: [
    sharedPreferencesRepository.overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Events>();
  const testEvent = Event(prefix: 'b.', year: '1000', isCE: false);
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
    tester.container.read(eventsRepository);
    final result = await tester.container.read(eventsNotifier.future);

    expect(result.events.length, greaterThanOrEqualTo(244));
    expect(deepCollectionEquals(result.events['b. 1000 B.C.E.-z'], testEvent),
        true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Events>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });
}
