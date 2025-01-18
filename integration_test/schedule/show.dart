import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';

import '../app_test.dart';

void testShowSchedule() {
  testWidgets('Show schedule of last plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final lastPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans.last.id}'));
    await tester.scrollUntilVisible(lastPlanCardFinder, 500.0);
    await tester.pumpAndSettle();

    expect(find.byType(Card).last.evaluate(), lastPlanCardFinder.evaluate());

    await tester.tap(lastPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard), findsWidgets);
  });
}
