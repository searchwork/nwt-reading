import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';

const _themeModePreferenceKey = 'themeModeSetting';
const _seenWhatsNewVersionPreferenceKey = 'seenWhatsNewVersionSetting';

final settingsRepositoryProvider = Provider<void>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesRepositoryProvider);
  final themeModeSerialized =
      sharedPreferences.getInt(_themeModePreferenceKey) ??
          ThemeMode.system.index;
  final seenWhatsNewVersion =
      sharedPreferences.getString(_seenWhatsNewVersionPreferenceKey);
  ref.read(settingsProvider.notifier).init(Settings(
      themeMode: ThemeMode.values[themeModeSerialized],
      seenWhatsNewVersion: seenWhatsNewVersion));

  ref.listen(
      settingsProvider,
      (previousSettings, currentSettings) =>
          currentSettings.whenData((settings) {
            sharedPreferences.setInt(
                _themeModePreferenceKey, settings.themeMode.index);
            if (settings.seenWhatsNewVersion != null) {
              sharedPreferences.setString(_seenWhatsNewVersionPreferenceKey,
                  settings.seenWhatsNewVersion!);
            }
          }));
}, name: 'settingsRepositoryProvider');
