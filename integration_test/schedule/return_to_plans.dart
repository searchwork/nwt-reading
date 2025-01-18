import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';

import '../app_test.dart';

void testReturnToPlans() {
  testWidgets('Return to plans page', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard), findsWidgets);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(
        find.byKey(
            Key('plan-${providerContainer.read(plansProvider).plans[1].id}')),
        findsOneWidget);
  });
}
