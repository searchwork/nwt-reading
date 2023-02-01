import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';
import '../../test_plans.dart';

void main() async {
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
    SharedPreferences.setMockInitialValues(testPlansPreferences);
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
        sharedPreferences.getStringList(plansPreferenceKey);

    expect(actualPlansSerialized, testPlansSerialized);
  });
}
