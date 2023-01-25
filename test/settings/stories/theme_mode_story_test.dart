import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

const preferenceKey = 'themeMode';
const asyncLoadingValue = AsyncLoading<ThemeMode>();

class MockIntSharedPreferencesRepository extends Mock
    implements ThemeModeRepository {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() async {
  test('Stays on AsyncLoading<ThemeMode>() before init', () async {
    final listener = Listener<AsyncValue<ThemeMode>>();
    final container = ProviderContainer();
    container.listen(
      themeModeProvider,
      listener,
      fireImmediately: true,
    );

    verify(
      () => listener(null, asyncLoadingValue),
    );
    verifyNoMoreInteractions(listener);
  });

  test('Defaults to ThemeMode.system', () async {
    SharedPreferences.setMockInitialValues({});
    final listener = Listener<AsyncValue<ThemeMode>>();
    final container = ProviderContainer();
    container.listen(
      themeModeProvider,
      listener,
      fireImmediately: true,
    );
    const data = AsyncData<ThemeMode>(ThemeMode.system);
    container.read(themeModeRepositoryProvider);
    await container.read(themeModeProvider.future);

    verifyInOrder([
      () => listener(null, asyncLoadingValue),
      () => listener(asyncLoadingValue, data),
    ]);
    verifyNoMoreInteractions(listener);
  });

  test('Resolves to Shared Preferences', () async {
    SharedPreferences.setMockInitialValues(
        {preferenceKey: ThemeMode.dark.index});
    final listener = Listener<AsyncValue<ThemeMode>>();
    final container = ProviderContainer();
    container.listen(
      themeModeProvider,
      listener,
      fireImmediately: true,
    );
    const data = AsyncData<ThemeMode>(ThemeMode.dark);
    container.read(themeModeRepositoryProvider);
    await container.read(themeModeProvider.future);

    verifyInOrder([
      () => listener(null, asyncLoadingValue),
      () => listener(asyncLoadingValue, data),
    ]);
    verifyNoMoreInteractions(listener);
  });

  test('Resolves to updated value', () async {
    SharedPreferences.setMockInitialValues({});
    final listener = Listener<AsyncValue<ThemeMode>>();
    final container = ProviderContainer();
    container.listen(
      themeModeProvider,
      listener,
      fireImmediately: true,
    );
    container.read(themeModeRepositoryProvider);
    for (var themeMode in ThemeMode.values) {
      await container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
    }

    verifyInOrder([
      () => listener(null, asyncLoadingValue),
      () => listener(
          asyncLoadingValue, AsyncData<ThemeMode>(ThemeMode.values[0])),
      () => listener(AsyncData<ThemeMode>(ThemeMode.values[0]),
          AsyncData<ThemeMode>(ThemeMode.values[0])),
      () => listener(AsyncData<ThemeMode>(ThemeMode.values[0]),
          AsyncData<ThemeMode>(ThemeMode.values[1])),
      () => listener(AsyncData<ThemeMode>(ThemeMode.values[1]),
          AsyncData<ThemeMode>(ThemeMode.values[2])),
    ]);
    verifyNoMoreInteractions(listener);
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
