import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';

Future<IncompleteNotifierTester<ThemeMode>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester =
      IncompleteNotifierTester<ThemeMode>(themeModeProvider, overrides: [
    sharedPreferencesRepository.overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  const preferenceKey = 'themeMode';
  const asyncLoadingValue = AsyncLoading<ThemeMode>();

  test('Stays on AsyncLoading before init', () async {
    final tester = await getTester();

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Defaults to ThemeMode.system', () async {
    final tester = await getTester();
    tester.container.read(themeModeRepository);
    final result = await tester.container.read(themeModeProvider.future);

    expect(result, ThemeMode.system);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<ThemeMode>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to Shared Preferences', () async {
    final tester = await getTester({preferenceKey: ThemeMode.dark.index});
    tester.container.read(themeModeRepository);
    final result = await tester.container.read(themeModeProvider.future);

    expect(result, ThemeMode.dark);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<ThemeMode>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updated value', () async {
    final tester = await getTester();
    tester.container.read(themeModeRepository);
    List<ThemeMode> results = [
      await tester.container.read(themeModeProvider.future)
    ];
    for (var themeMode in ThemeMode.values) {
      tester.container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
      results.add(await tester.container.read(themeModeProvider.future));
    }

    expect(results, [ThemeMode.system, ...ThemeMode.values]);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () =>
          tester.listener(asyncLoadingValue, AsyncData<ThemeMode>(results[0])),
      () => tester.listener(
          AsyncData<ThemeMode>(results[0]), AsyncData<ThemeMode>(results[1])),
      () => tester.listener(
          AsyncData<ThemeMode>(results[1]), AsyncData<ThemeMode>(results[2])),
      () => tester.listener(
          AsyncData<ThemeMode>(results[2]), AsyncData<ThemeMode>(results[3])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Shared Preferences are set to updated value', () async {
    final tester = await getTester();
    tester.container.read(themeModeRepository);
    for (var themeMode in ThemeMode.values) {
      tester.container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
      final actualThemeIndex = tester.container
          .read(sharedPreferencesRepository)
          .getInt(preferenceKey);

      expect(ThemeMode.values[actualThemeIndex!], themeMode);
    }
  });
}
