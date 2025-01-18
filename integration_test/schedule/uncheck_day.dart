import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../app_test.dart';

void testUncheckDay() {
  testWidgets('Uncheck day', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      -500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-33')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reject-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        75);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-33')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        33);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });
}
