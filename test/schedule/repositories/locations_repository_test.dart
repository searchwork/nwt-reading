import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/repositories/locations_repository.dart';

import '../../incomplete_notifier_tester.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Locations>();
  const testLocation =
      Location(name: 'Bethlehem', refs: '7; 15 E8; 17 E9; 18; 19 D10; 29 D10');
  final tester = IncompleteNotifierTester<Locations>(locationsProvider);
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    tester.reset();
    addTearDown(tester.container.dispose);

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to the asset', () async {
    tester.reset();
    addTearDown(tester.container.dispose);
    tester.container.read(locationsRepositoryProvider);
    final result = await tester.container.read(locationsProvider.future);

    expect(result.locations.length, greaterThanOrEqualTo(639));
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
