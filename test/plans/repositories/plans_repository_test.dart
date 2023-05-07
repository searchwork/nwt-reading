import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';
import '../../test_plans.dart';

Future<IncompleteNotifierTester<Plans>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester = IncompleteNotifierTester<Plans>(plansNotifier, overrides: [
    sharedPreferencesRepository.overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asyncLoadingValue = AsyncLoading<Plans>();
  final emptyPlans = Plans(const []);
  final deepCollectionEquals = const DeepCollectionEquality().equals;

  test('Stays on AsyncLoading before init', () async {
    final tester = await getTester();

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Defaults to the empty entity', () async {
    final tester = await getTester();
    tester.container.read(plansRepository);
    final result = await tester.container.read(plansNotifier.future);

    expect(deepCollectionEquals(result.plans, emptyPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Imports legacy settings', () async {
    for (var testLegacyExport in testLegacyExports) {
      final tester = await getTester(testLegacyExport.preferences);
      tester.container.read(plansRepository);
      final result = await tester.container.read(plansNotifier.future);

      expect(deepCollectionEquals(result.plans, testLegacyExport.plans.plans),
          true);
      verifyInOrder([
        () => tester.listener(null, asyncLoadingValue),
        () => tester.listener(asyncLoadingValue, AsyncData<Plans>(result)),
      ]);
      verifyNoMoreInteractions(tester.listener);
    }
  });

  test('Resolves to Shared Preferences', () async {
    final tester = await getTester(testPlansPreferences);
    tester.container.read(plansRepository);
    final result = await tester.container.read(plansNotifier.future);

    expect(deepCollectionEquals(result.plans, testPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updated value', () async {
    final tester = await getTester();
    tester.container.read(plansRepository);
    List<Plans> results = [await tester.container.read(plansNotifier.future)];
    for (var plan in testPlans.plans) {
      await tester.container.read(plansNotifier.notifier).addPlan(plan);
      results.add(await tester.container.read(plansNotifier.future));
    }

    expect(deepCollectionEquals(results[4].plans, testPlans.plans), true);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Plans>(results[0])),
      () => tester.listener(
          AsyncData<Plans>(results[0]), AsyncData<Plans>(results[1])),
      () => tester.listener(
          AsyncData<Plans>(results[1]), AsyncData<Plans>(results[2])),
      () => tester.listener(
          AsyncData<Plans>(results[2]), AsyncData<Plans>(results[3])),
      () => tester.listener(
          AsyncData<Plans>(results[3]), AsyncData<Plans>(results[4])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Shared Preferences are set to updated value', () async {
    final tester = await getTester();
    tester.container.read(plansRepository);
    for (var plan in testPlans.plans) {
      await tester.container.read(plansNotifier.notifier).addPlan(plan);
    }
    final actualPlansSerialized = tester.container
        .read(sharedPreferencesRepository)
        .getStringList(plansPreferenceKey);

    expect(actualPlansSerialized, testPlansSerialized);
  });
}
