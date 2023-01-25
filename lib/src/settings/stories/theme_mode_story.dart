import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
    ThemeModeNotifier.new,
    name: 'themeMode');

class ThemeModeNotifier extends IncompleteNotifier<ThemeMode> {
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await update((previousThemeMode) => themeMode);
  }
}
