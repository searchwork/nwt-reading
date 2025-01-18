import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';

import '../app_test.dart';

void testSettings() {
  testWidgets('Settings', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('version')), findsOneWidget);
    expect(find.byKey(const Key('copyright')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.byIcon(Icons.auto_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness,
        SchedulerBinding.instance.platformDispatcher.platformBrightness);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.byIcon(Icons.auto_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness,
        SchedulerBinding.instance.platformDispatcher.platformBrightness);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(
        find.byKey(
            Key('plan-${providerContainer.read(plansProvider).plans[1].id}')),
        findsOneWidget);
  });
}
