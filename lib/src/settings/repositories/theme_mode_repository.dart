import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeRepository, ThemeMode>(
    ThemeModeRepository.new,
    name: 'themeMode');

class ThemeModeRepository extends AsyncNotifier<ThemeMode> {
  final _preferenceKey = 'themeMode';

  @override
  Future<ThemeMode> build() async {
    final preferences = await SharedPreferences.getInstance();
    final themeModeIndex = preferences.getInt(_preferenceKey);

    return ThemeMode.values[themeModeIndex ?? 0];
  }

  void _writeSharedPreference() async {
    final preferences = await SharedPreferences.getInstance();
    await future;
    if (state.valueOrNull != null) {
      preferences.setInt(_preferenceKey, state.valueOrNull?.index ?? 0);
    }
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await update((previousThemeMode) => themeMode);
    _writeSharedPreference();
  }
}
