import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/repositories/events_repository.dart';

import '../../incomplete_notifier_tester.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Events>();
  const testEvent = Event(prefix: 'b.', year: '1000', isCE: false);
  final tester = IncompleteNotifierTester<Events>(eventsProvider);
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
    tester.container.read(eventsRepositoryProvider);
    final result = await tester.container.read(eventsProvider.future);

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
