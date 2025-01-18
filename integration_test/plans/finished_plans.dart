import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../app_test.dart';

void testFinishedPlans() {
  testWidgets('Plans showing if finished', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified), findsOneWidget);

    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('day-365')), 500.0,
        maxScrolls: 300);
    await tester.pumpAndSettle();
    await Future<void>.delayed(Duration(seconds: 2));
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-365')),
            matching: find.byType(IconButton))
        .last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        366);
    expect(providerContainer.read(plansProvider).plans.first.lastDate,
        DateUtils.dateOnly(DateTime.now()));
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified), findsExactly(2));
  });
}
