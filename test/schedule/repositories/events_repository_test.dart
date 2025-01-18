import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';

import '../../notifier_tester.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Events>();
  const testEvent = Event(prefix: 'b.', year: '1000', isCE: false);
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    final tester = await getAsyncNotifierTester(eventsProvider);

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to the asset', () async {
    final tester = await getAsyncNotifierTester(eventsProvider);
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
