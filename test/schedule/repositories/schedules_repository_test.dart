import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';

import '../../notifier_tester.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Schedules>();
  const testSections = [
    Section(
        bookIndex: 58,
        chapter: 1,
        endChapter: 3,
        ref: '1-3',
        startIndex: 59001001,
        endIndex: 59003018,
        url: '59001001-59003018',
        events: [],
        locations: ['Gehenna (Hinnom)'])
  ];
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    final tester = await getAsyncNotifierTester(schedulesProvider);

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to the asset', () async {
    final tester = await getAsyncNotifierTester(schedulesProvider);
    tester.container.read(schedulesRepositoryProvider);
    final result = await tester.container.read(schedulesProvider.future);

    expect(result.schedules.length, greaterThanOrEqualTo(3));
    expect(
        deepCollectionEquals(
            result
                .schedules[const ScheduleKey(
                    type: ScheduleType.chronological,
                    duration: ScheduleDuration.y1,
                    version: '1.0')]
                ?.days[320]
                .sections,
            testSections),
        true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Schedules>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });
}
