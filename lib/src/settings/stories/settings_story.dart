import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(
    SettingsNotifier.new,
    name: 'settingsProvider');

class SettingsNotifier extends IncompleteNotifier<Settings> {
  Future<void> updateSettings({
    ThemeMode? themeMode,
    String? seenWhatsNewVersion,
  }) async {
    state = AsyncValue.data(state.asData?.value == null
        ? Settings(
            themeMode: themeMode ?? ThemeMode.system,
            seenWhatsNewVersion: seenWhatsNewVersion)
        : state.asData!.value.copyWith(
            themeMode: themeMode, seenWhatsNewVersion: seenWhatsNewVersion));
  }

  void updateThemeMode(ThemeMode themeMode) =>
      updateSettings(themeMode: themeMode);

  void updateSeenWhatsNewVersion(String seenWhatsNewVersion) =>
      updateSettings(seenWhatsNewVersion: seenWhatsNewVersion);
}

@immutable
class Settings extends Equatable {
  const Settings({
    required this.themeMode,
    this.seenWhatsNewVersion,
  });

  final ThemeMode themeMode;
  final String? seenWhatsNewVersion;

  Settings copyWith({
    ThemeMode? themeMode,
    String? seenWhatsNewVersion,
  }) =>
      Settings(
        themeMode: themeMode ?? this.themeMode,
        seenWhatsNewVersion: seenWhatsNewVersion ?? this.seenWhatsNewVersion,
      );

  @override
  List<Object?> get props => [themeMode, seenWhatsNewVersion];
}
