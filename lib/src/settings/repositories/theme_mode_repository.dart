import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

const _preferenceKey = 'themeMode';

final themeModeRepositoryProvider = Provider<void>((ref) {
  final preferences = ref.watch(sharedPreferencesRepositoryProvider);
  final themeModeSerialized =
      preferences.getInt(_preferenceKey) ?? ThemeMode.system.index;
  ref
      .read(themeModeProvider.notifier)
      .init(ThemeMode.values[themeModeSerialized]);

  ref.listen(
      themeModeProvider,
      (previousThemeMode, currentThemeMode) => currentThemeMode.whenData(
          (themeMode) => preferences.setInt(_preferenceKey, themeMode.index)));
}, name: 'themeModeRepositoryProvider');
