import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/settings/repositories/settings_repository.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifier_tester.dart';

Future<IncompleteNotifierTester<Settings>> getTester(
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester =
      IncompleteNotifierTester<Settings>(settingsProvider, overrides: [
    sharedPreferencesRepositoryProvider
        .overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

void main() async {
  const themeModePreferenceKey = 'themeModeSetting';
  const seenWhatsNewVersionPreferenceKey = 'seenWhatsNewVersionSetting';
  const asyncLoadingValue = AsyncLoading<Settings>();

  test('Stays on AsyncLoading before init', () async {
    final tester = await getTester();

    verify(
      () => tester.listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(tester.listener);
  });

  test('Defaults to ThemeMode.system', () async {
    final tester = await getTester();
    tester.container.read(settingsRepositoryProvider);
    final result = await tester.container.read(settingsProvider.future);

    expect(result, Settings(themeMode: ThemeMode.system));
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Settings>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to Shared Preferences', () async {
    final tester = await getTester({
      themeModePreferenceKey: ThemeMode.dark.index,
      seenWhatsNewVersionPreferenceKey: '1.0'
    });
    tester.container.read(settingsRepositoryProvider);
    final result = await tester.container.read(settingsProvider.future);

    expect(result,
        Settings(themeMode: ThemeMode.dark, seenWhatsNewVersion: '1.0'));
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Settings>(result)),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to setThemeMode value', () async {
    final tester = await getTester();
    tester.container.read(settingsRepositoryProvider);
    List<Settings> results = [
      await tester.container.read(settingsProvider.future)
    ];
    for (var themeMode in ThemeMode.values) {
      tester.container
          .read(settingsProvider.notifier)
          .updateThemeMode(themeMode);
      results.add(await tester.container.read(settingsProvider.future));
    }

    expect(results, [
      Settings(themeMode: ThemeMode.system),
      ...ThemeMode.values
          .map<Settings>((themeMode) => Settings(themeMode: themeMode))
    ]);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Settings>(results[0])),
      () => tester.listener(
          AsyncData<Settings>(results[0]), AsyncData<Settings>(results[1])),
      () => tester.listener(
          AsyncData<Settings>(results[1]), AsyncData<Settings>(results[2])),
      () => tester.listener(
          AsyncData<Settings>(results[2]), AsyncData<Settings>(results[3])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updateSeenWhatsNewVersion value', () async {
    final tester = await getTester();
    tester.container.read(settingsRepositoryProvider);
    List<Settings> results = [
      await tester.container.read(settingsProvider.future)
    ];
    tester.container
        .read(settingsProvider.notifier)
        .updateSeenWhatsNewVersion('1.0');
    results.add(await tester.container.read(settingsProvider.future));
    tester.container
        .read(settingsProvider.notifier)
        .updateSeenWhatsNewVersion('2.0');
    results.add(await tester.container.read(settingsProvider.future));

    expect(results, [
      Settings(themeMode: ThemeMode.system),
      Settings(themeMode: ThemeMode.system, seenWhatsNewVersion: '1.0'),
      Settings(themeMode: ThemeMode.system, seenWhatsNewVersion: '2.0'),
    ]);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Settings>(results[0])),
      () => tester.listener(
          AsyncData<Settings>(results[0]), AsyncData<Settings>(results[1])),
      () => tester.listener(
          AsyncData<Settings>(results[1]), AsyncData<Settings>(results[2])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Resolves to updateSettings value', () async {
    final tester = await getTester();
    tester.container.read(settingsRepositoryProvider);
    List<Settings> results = [
      await tester.container.read(settingsProvider.future)
    ];
    for (var themeMode in ThemeMode.values) {
      tester.container.read(settingsProvider.notifier).updateSettings(
          themeMode: themeMode, seenWhatsNewVersion: themeMode.name);
      results.add(await tester.container.read(settingsProvider.future));
    }

    expect(results, [
      Settings(themeMode: ThemeMode.system),
      ...ThemeMode.values.map<Settings>((themeMode) =>
          Settings(themeMode: themeMode, seenWhatsNewVersion: themeMode.name))
    ]);
    verifyInOrder([
      () => tester.listener(null, asyncLoadingValue),
      () => tester.listener(asyncLoadingValue, AsyncData<Settings>(results[0])),
      () => tester.listener(
          AsyncData<Settings>(results[0]), AsyncData<Settings>(results[1])),
      () => tester.listener(
          AsyncData<Settings>(results[1]), AsyncData<Settings>(results[2])),
      () => tester.listener(
          AsyncData<Settings>(results[2]), AsyncData<Settings>(results[3])),
    ]);
    verifyNoMoreInteractions(tester.listener);
  });

  test('Shared Preferences are set to updated value', () async {
    final tester = await getTester();
    tester.container.read(settingsRepositoryProvider);

    for (var themeMode in ThemeMode.values) {
      await tester.container.read(settingsProvider.notifier).updateSettings(
          themeMode: themeMode, seenWhatsNewVersion: themeMode.name);
      final sharedPreferences =
          tester.container.read(sharedPreferencesRepositoryProvider);
      final actualThemeIndex = sharedPreferences.getInt(themeModePreferenceKey);
      final actualSeenWhatsNewVersion =
          sharedPreferences.getString(seenWhatsNewVersionPreferenceKey);

      expect(ThemeMode.values[actualThemeIndex!], themeMode);
      expect(actualSeenWhatsNewVersion, themeMode.name);
    }
  });
}
