import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repositories.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

final themeModeRepository = Provider<ThemeModeRepository>(
    (ref) => ThemeModeRepository(ref),
    name: 'themeModeRepository');

class ThemeModeRepository
    extends AbstractIntSharedPreferencesRepository<ThemeMode> {
  ThemeModeRepository(ref)
      : super(
            ref: ref,
            stateProvider: themeModeProvider,
            preferenceKey: 'themeMode');

  @override
  int serialize(ThemeMode state) => state.index;

  @override
  ThemeMode deserialize(int? serialized) =>
      ThemeMode.values[serialized ?? ThemeMode.system.index];
}
