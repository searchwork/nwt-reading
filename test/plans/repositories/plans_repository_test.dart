import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';

void main() async {
  const preferenceKey = 'plans';
  final Plans testPlans = Plans(const [
    Plan(
        id: "5aa4de9e-036b-42cd-8bcb-a92cae46db27",
        name: "Chronological",
        scheduleKey: ScheduleKey(
            type: ScheduleType.chronological,
            duration: ScheduleDuration.y1,
            version: "1.0"),
        language: "en",
        bookmark: Bookmark(dayIndex: 16, sectionIndex: 0),
        withEndDate: true,
        showEvents: true,
        showLocations: true),
    Plan(
        id: "0da6b8a7-ccd4-4270-8058-9e30a3f55ceb",
        name: "Sequential",
        scheduleKey: ScheduleKey(
            type: ScheduleType.sequential,
            duration: ScheduleDuration.y1,
            version: "1.0"),
        language: "en",
        bookmark: Bookmark(dayIndex: 115, sectionIndex: 0),
        withEndDate: true,
        showEvents: true,
        showLocations: true),
    Plan(
        id: "2dab49f3-aecf-4aba-9e91-d75c297d4b7e",
        name: "Written",
        scheduleKey: ScheduleKey(
            type: ScheduleType.written,
            duration: ScheduleDuration.y1,
            version: "1.0"),
        language: "en",
        bookmark: Bookmark(dayIndex: 364, sectionIndex: 1),
        withEndDate: true,
        showEvents: true,
        showLocations: true)
  ]);
  const List<String> testPlansSerialized = [
    '{"id":"5aa4de9e-036b-42cd-8bcb-a92cae46db27","name":"Chronological","scheduleKey":{"type":0,"duration":2,"version":"1.0"},"language":"en","bookmark":{"dayIndex":16,"sectionIndex":0},"withEndDate":true,"showEvents":true,"showLocations":true}',
    '{"id":"0da6b8a7-ccd4-4270-8058-9e30a3f55ceb","name":"Sequential","scheduleKey":{"type":1,"duration":2,"version":"1.0"},"language":"en","bookmark":{"dayIndex":115,"sectionIndex":0},"withEndDate":true,"showEvents":true,"showLocations":true}',
    '{"id":"2dab49f3-aecf-4aba-9e91-d75c297d4b7e","name":"Written","scheduleKey":{"type":2,"duration":2,"version":"1.0"},"language":"en","bookmark":{"dayIndex":364,"sectionIndex":1},"withEndDate":true,"showEvents":true,"showLocations":true}'
  ];
  const asyncLoadingValue = AsyncLoading<Plans>();
  final emptyPlans = Plans(const []);
  final tester = IncompleteNotifierTester<Plans>(plansProvider);
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    tester.reset();
    addTearDown(tester.container.dispose);

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Defaults to the empty entity', () async {
    tester.reset();
    addTearDown(tester.container.dispose);
    SharedPreferences.setMockInitialValues({});
    tester.container.read(plansRepositoryProvider);
    final result = await tester.container.read(plansProvider.future);

    expect(deepCollectionEquals(result.plans, emptyPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to Shared Preferences', () async {
    tester.reset();
    addTearDown(tester.container.dispose);
    SharedPreferences.setMockInitialValues(
        {preferenceKey: testPlansSerialized});
    tester.container.read(plansRepositoryProvider);
    final result = await tester.container.read(plansProvider.future);

    expect(deepCollectionEquals(result.plans, testPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updated value', () async {
    tester.reset();
    addTearDown(tester.container.dispose);
    SharedPreferences.setMockInitialValues({});
    tester.container.read(plansRepositoryProvider);
    List<Plans> results = [await tester.container.read(plansProvider.future)];
    for (var plan in testPlans.plans) {
      await tester.container.read(plansProvider.notifier).addPlan(plan);
      results.add(await tester.container.read(plansProvider.future));
    }

    expect(deepCollectionEquals(results[3].plans, testPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(results[0])),
      () => tester.listener(
          AsyncData<Plans>(results[0]), AsyncData<Plans>(results[1])),
      () => tester.listener(
          AsyncData<Plans>(results[1]), AsyncData<Plans>(results[2])),
      () => tester.listener(
          AsyncData<Plans>(results[2]), AsyncData<Plans>(results[3])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Shared Preferences are set to updated value', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer();
    container.read(plansRepositoryProvider);
    for (var plan in testPlans.plans) {
      await container.read(plansProvider.notifier).addPlan(plan);
    }
    final actualPlansSerialized =
        sharedPreferences.getStringList(preferenceKey);

    expect(actualPlansSerialized, testPlansSerialized);
  });
}
