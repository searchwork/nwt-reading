import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../incomplete_notifier_tester.dart';

const preferenceKey = 'themeMode';
const asyncLoadingValue = AsyncLoading<ThemeMode>();
final tester = IncompleteNotifierTester<ThemeMode>(themeModeProvider);

void main() async {
  test('Stays on AsyncLoading<ThemeMode>() before init', () async {
    tester.reset();
    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Defaults to ThemeMode.system', () async {
    tester.reset();
    SharedPreferences.setMockInitialValues({});
    tester.container.read(themeModeRepositoryProvider);
    await tester.container.read(themeModeProvider.future);
    const data = AsyncData<ThemeMode>(ThemeMode.system);

    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, data),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to Shared Preferences', () async {
    tester.reset();
    SharedPreferences.setMockInitialValues(
        {preferenceKey: ThemeMode.dark.index});
    const data = AsyncData<ThemeMode>(ThemeMode.dark);
    tester.container.read(themeModeRepositoryProvider);
    await tester.container.read(themeModeProvider.future);

    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, data),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updated value', () async {
    tester.reset();
    SharedPreferences.setMockInitialValues({});
    tester.container.read(themeModeRepositoryProvider);
    for (var themeMode in ThemeMode.values) {
      await tester.container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
    }

    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(
          asyncLoadingValue, AsyncData<ThemeMode>(ThemeMode.values[0])),
      () => tester.listener(AsyncData<ThemeMode>(ThemeMode.values[0]),
          AsyncData<ThemeMode>(ThemeMode.values[0])),
      () => tester.listener(AsyncData<ThemeMode>(ThemeMode.values[0]),
          AsyncData<ThemeMode>(ThemeMode.values[1])),
      () => tester.listener(AsyncData<ThemeMode>(ThemeMode.values[1]),
          AsyncData<ThemeMode>(ThemeMode.values[2])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Shared Preferences are set to updated value', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer();
    container.read(themeModeRepositoryProvider);
    for (var themeMode in ThemeMode.values) {
      await container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
      final actualThemeIndex = sharedPreferences.getInt(preferenceKey);

      expect(ThemeMode.values[actualThemeIndex!], themeMode);
    }
  });
}
