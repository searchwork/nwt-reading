import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../app_test.dart';

void testChangePlanWithTargetDate() {
  testWidgets('Change plan with target date setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-74')),
      -500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('date')), findsWidgets);
    expect(find.byKey(const Key('day-index')), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-74')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    final dayOfMonth = DateTime.now().day;
    expect(find.byKey(const Key('date')), findsWidgets);
    expect(find.byKey(const Key('day-index')), findsNothing);
    expect((tester.firstWidget(find.byKey(const Key('date'))) as Text).data,
        dayOfMonth.toString());

    await tester.scrollUntilVisible(
        find.byKey(Key('day-${(74 - dayOfMonth).toString()}')), -200.0,
        maxScrolls: 200);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('month')), -200.0,
        maxScrolls: 200);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, true);

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, false);
    expect(find.byKey(const Key('month')), findsNothing);
    expect(find.byKey(const Key('date')), findsNothing);
    expect(find.byKey(const Key('day-index')), findsWidgets);
    expect(
        (tester.firstWidget(find
                .descendant(
                    of: find.byKey(Key('day-${(74 - dayOfMonth).toString()}')),
                    matching: find.byKey(const Key('day-index')))
                .last) as Text)
            .data,
        (75 - dayOfMonth).toString());

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, true);
  });
}
