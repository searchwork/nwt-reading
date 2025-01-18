import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';

import '../app_test.dart';

void testStartsAtBookmark() {
  testWidgets('Schedule starts at bookmark', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final lastPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans.last.id}'));
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-75')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-0')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(lastPlanCardFinder, 500.0);
    await tester.pumpAndSettle();
    await tester.tap(lastPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).last.evaluate(),
        find.byKey(const Key('day-182')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });
}
