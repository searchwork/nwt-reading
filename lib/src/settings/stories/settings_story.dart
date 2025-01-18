import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  void markWhatsNewAsSeen() async {
    final version = (await PackageInfo.fromPlatform()).version;

    updateSeenWhatsNewVersion(version);
  }

  Future<bool> shouldShowWhatsNew() async {
    final version = (await PackageInfo.fromPlatform()).version;
    final majorVersion = version.split('.')[0];

    while (state.isLoading) {
      await Future<void>.delayed(Duration(milliseconds: 100));
    }

    return state.maybeWhen(
      data: (state) => state.seenWhatsNewVersion?.split('.')[0] != majorVersion,
      orElse: () => false,
    );
  }
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
