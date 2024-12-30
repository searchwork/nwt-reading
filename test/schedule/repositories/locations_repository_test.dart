import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifier_tester.dart';

Future<IncompleteNotifierTester<Locations>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester =
      IncompleteNotifierTester<Locations>(locationsProvider, overrides: [
    sharedPreferencesRepositoryProvider
        .overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Locations>();
  const testLocation = Location(
      key: 'location_Bethlehem_Ephrath_Judah',
      refs: '7; 15 E8; 17 E9; 18; 19 D10; 29 D10');
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
    tester.container.read(locationsRepositoryProvider);
    final result = await tester.container.read(locationsProvider.future);

    expect(result.locations.length, greaterThanOrEqualTo(634));
    expect(
        deepCollectionEquals(
            result.locations['Bethlehem (Ephrath) [Judah]'], testLocation),
        true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Locations>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });
}
