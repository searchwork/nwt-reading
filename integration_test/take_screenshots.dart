import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../test/test_data.dart';
import 'settled_tester.dart';

// Consider implementing
// https://medium.com/@mregnauld/generate-screenshots-for-a-flutter-app-with-golden-testing-and-upload-them-to-the-stores-1-2-45f8df777aef.

Future<ProviderContainer> getDefaultProviderContainer(
        WidgetTester tester) async =>
    SettledTester(tester, sharedPreferences: {
      ...testPlansPreferences,
      ...await getWhatsNewSeenPreference()
    }).providerContainer;

final os = Platform.operatingSystem;

Future<void> takeScreenshot(
    {required IntegrationTestWidgetsFlutterBinding binding,
    required String filename}) async {
  await binding
      .takeScreenshot('assets/store_presence/screenshots/$os-$filename.png');
  await Future<void>.delayed(const Duration(seconds: 3));
}

void main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('Take the plans list screenshot', (tester) async {
    await getDefaultProviderContainer(tester);
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '1-plans');
  });

  testWidgets('Take the schedule screenshot', (tester) async {
    await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      -500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-34')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-70')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '2-schedule');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '3-schedule-dark');
  });

  testWidgets('Take the new plan screenshot', (tester) async {
    await SettledTester(tester,
            sharedPreferences: await getWhatsNewSeenPreference())
        .providerContainer;
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '4-new');
  });

  testWidgets('Take the plan edit screenshot', (tester) async {
    await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '5-edit');
  });

  testWidgets('Take the settings screenshot', (tester) async {
    await getDefaultProviderContainer(tester);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await takeScreenshot(binding: binding, filename: '6-settings');
  });
}
