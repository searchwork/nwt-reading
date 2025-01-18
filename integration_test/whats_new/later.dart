import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/test_data.dart';
import '../settled_tester.dart';

void testLaterOnWhatsNew() {
  testWidgets('Later on What\'s New dialog does not change settings',
      (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('whats-new-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('later')));
    await tester.pumpAndSettle();

    final seenWhatsNewVersion = (await SharedPreferences.getInstance())
        .getString(seenWhatsNewVersionPreferenceKey);
    expect(seenWhatsNewVersion, null);
    expect(await providerContainer.read(settingsProvider.future),
        Settings(themeMode: ThemeMode.system));
    expect(find.byKey(const Key('whats-new-dialog')), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  });

  testWidgets('Got It on What\'s New dialog changes settings', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('whats-new-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('got-it')));
    await tester.pumpAndSettle();

    final version = (await PackageInfo.fromPlatform()).version;
    final seenWhatsNewVersion = (await SharedPreferences.getInstance())
        .getString(seenWhatsNewVersionPreferenceKey);
    expect(seenWhatsNewVersion, version);
    expect(await providerContainer.read(settingsProvider.future),
        Settings(themeMode: ThemeMode.system, seenWhatsNewVersion: version));
    expect(find.byKey(const Key('whats-new-dialog')), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  });
}
