import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Settings'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButton<ThemeMode>(
            value: themeMode,
            onChanged: (value) => ref
                .read(themeModeProvider.notifier)
                .updateThemeMode(value ?? ThemeMode.system),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark Theme'),
              )
            ],
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
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'Version: ${snapshot.data?.version}',
                    key: Key('version'),
                  );
                }
              },
            ),
            const Text(
              'Copyright © 2024 searchwork.org',
              style: TextStyle(height: 3),
              key: Key('copyright'),
            ),
          ],
        )),
      ]),
    );
  }
}
