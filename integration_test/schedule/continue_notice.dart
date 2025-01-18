import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';

import '../app_test.dart';

void testContinueNotice() {
  testWidgets('Show continue notice on new plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final secondPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans[1].id}'));
    await tester.scrollUntilVisible(secondPlanCardFinder, 500.0);
    await tester.pumpAndSettle();
    await tester.tap(secondPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue-notice')), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-2')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue-notice')), findsNothing);
  });
}
