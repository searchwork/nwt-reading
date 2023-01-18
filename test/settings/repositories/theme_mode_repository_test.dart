import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const preferenceKey = 'themeMode';

void main() {
  test('Defaults to ThemeMode.system', () async {
    SharedPreferences.setMockInitialValues({});
    final actualTheme =
        await ProviderContainer().read(themeModeProvider.future);

    expect(actualTheme, ThemeMode.system);
  });

  test('Builds to Shared Preferences', () async {
    SharedPreferences.setMockInitialValues(
        {preferenceKey: ThemeMode.dark.index});
    final actualTheme =
        await ProviderContainer().read(themeModeProvider.future);

    expect(actualTheme, ThemeMode.dark);
  });

  test('Shared Preferences are set to updated value', () async {
    final sharedPreferences = await SharedPreferences.getInstance();

    for (var themeMode in ThemeMode.values) {
      await ProviderContainer()
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
      final actualThemeIndex = sharedPreferences.getInt(preferenceKey);

      expect(ThemeMode.values[actualThemeIndex!], themeMode);
    }
  });

  test('Reports correct state on update', () async {
    final container = ProviderContainer();
    for (var themeMode in ThemeMode.values) {
      await container
          .read(themeModeProvider.notifier)
          .updateThemeMode(themeMode);
      final actualTheme = await container.read(themeModeProvider.future);

      expect(actualTheme, themeMode);
    }
  });
}
