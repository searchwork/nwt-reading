import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsPageTitle),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(context.loc.settingsPageSystemLabel),
                  icon: Icon(Icons.auto_mode)),
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(context.loc.settingsPageLightLabel),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(context.loc.settingsPageDarkLabel),
                  icon: Icon(Icons.dark_mode)),
            ],
            selected: {themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) => ref
                .read(themeModeProvider.notifier)
                .updateThemeMode(newSelection.single),
          ),
        ),
        ListTile(
            subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Text(
                    '${context.loc.settingsPageVersionLabel}: ${snapshot.data?.version}',
                    key: Key('version'),
                  );
                }
              },
            ),
            Text(
              '${context.loc.settingsPageCopyrightLabel} © 2024 searchwork.org',
              style: TextStyle(height: 3),
              key: Key('copyright'),
            ),
          ],
        )),
      ]),
    );
  }
}
